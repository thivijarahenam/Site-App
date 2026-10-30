"""Integration tests verifying full backend alignment with Flutter Civil-frontend requirements."""

from fastapi.testclient import TestClient
from sqlalchemy.orm import Session


def test_supervisor_dashboard_endpoint(
    test_env: tuple[TestClient, Session, dict[str, str]],
) -> None:
    client, _, headers = test_env

    resp = client.get("/api/v1/dashboard/supervisor", headers=headers["supervisor"])
    assert resp.status_code == 200
    data = resp.json()
    assert "active_sites" in data
    assert "active_labourers" in data
    assert "pending_material_requests" in data
    assert "pending_logbook_entries" in data
    assert "recent_activities" in data
    assert "today_tasks" in data
    assert "pending_approvals" in data


def test_site_frontend_fields(
    test_env: tuple[TestClient, Session, dict[str, str]],
) -> None:
    client, _, headers = test_env

    payload = {
        "site_name": "Jaffna Central Hospital Phase 2",
        "project_name": "Hospital Complex",
        "site_address": "Hospital Road, Jaffna",
        "client_name": "Ministry of Health",
        "start_date": "2026-10-15",
        "expected_completion_date": "2028-06-30",
        "status": "Active",
        "description": "Multi-storey emergency and pediatric unit",
        "progress": 0.42,
        "contract_value": "LKR 145,000,000",
        "cost_spent": "LKR 38.5M",
        "margin": 19.5,
        "labour_count": "28 / 50",
        "image_url": "https://example.com/site.jpg",
        "supervisor_name": "K. Sivaram",
        "supervisor_phone": "0772345678",
        "stages": [
            "Site Preparation",
            "Foundation",
            "Structural Work",
            "Block Work",
            "Finishing",
        ],
    }

    create_resp = client.post("/api/v1/sites", headers=headers["admin"], json=payload)
    assert create_resp.status_code == 201
    site = create_resp.json()
    assert site["site_name"] == payload["site_name"]
    assert site["progress"] == 0.42
    assert site["contract_value"] == "LKR 145,000,000"
    assert site["cost_spent"] == "LKR 38.5M"
    assert site["margin"] == 19.5
    assert site["supervisor_name"] == "K. Sivaram"
    assert len(site["stages"]) == 5

    # Update site progress
    patch_resp = client.patch(
        f"/api/v1/sites/{site['id']}",
        headers=headers["supervisor"],
        json={"progress": 0.48, "cost_spent": "LKR 42.1M"},
    )
    assert patch_resp.status_code == 200
    updated = patch_resp.json()
    assert updated["progress"] == 0.48
    assert updated["cost_spent"] == "LKR 42.1M"


def test_labour_attendance_toggle_and_self_update(
    test_env: tuple[TestClient, Session, dict[str, str]],
) -> None:
    client, _, headers = test_env

    # 1. Admin creates a site
    site_resp = client.post(
        "/api/v1/sites",
        headers=headers["admin"],
        json={
            "site_name": "Attendance Test Site",
            "project_name": "School Project",
            "site_address": "Point Pedro Road, Jaffna",
            "client_name": "Dept of Education",
            "start_date": "2026-11-01",
            "expected_completion_date": "2027-08-31",
            "status": "Active",
        },
    )
    site_id = site_resp.json()["id"]

    # 2. Admin creates a labourer
    labour_payload = {
        "email": "worker.attend@example.com",
        "password": "worker-secure-pass-123",
        "full_name": "S. Kanagaratnam",
        "nic_number": "199234567812",
        "phone_number": "0778889900",
        "address": "Navanthurai, Jaffna",
        "job_role": "Helper",
        "skills": "General Labour",
        "experience_years": 1,
        "joining_date": "2026-10-01",
        "emergency_contact": "0771112233",
        "current_site_id": site_id,
        "status": "Active",
        "daily_wage": 3000.0,
        "has_attended_today": True,
    }
    create_resp = client.post(
        "/api/v1/labour", headers=headers["admin"], json=labour_payload
    )
    assert create_resp.status_code == 201
    labour_data = create_resp.json()
    labour_id = labour_data["id"]
    assert labour_data["has_attended_today"] is True
    assert labour_data["daily_wage"] == 3000.0

    # 3. Toggle attendance
    toggle_resp = client.post(
        f"/api/v1/labour/{labour_id}/attendance-toggle",
        headers=headers["supervisor"],
    )
    assert toggle_resp.status_code == 200
    assert toggle_resp.json()["has_attended_today"] is False

    # Toggle back
    toggle_resp2 = client.post(
        f"/api/v1/labour/{labour_id}/attendance-toggle",
        headers=headers["supervisor"],
    )
    assert toggle_resp2.status_code == 200
    assert toggle_resp2.json()["has_attended_today"] is True


def test_unified_signup_and_phone_login(
    test_env: tuple[TestClient, Session, dict[str, str]],
) -> None:
    client, session, _ = test_env

    # 1. Stepper registration for Labour
    signup_payload = {
        "role": "labour",
        "email": "new.worker@siteapp.lk",
        "password": "securepassword123",
        "full_name": "V. Sivalingam",
        "phone_number": "0779988112",
        "address": "Kopay, Jaffna",
        "job_role": "Mason",
        "skills": ["Bricklaying", "Plastering"],
        "experience": "3-5 years",
        "experience_years": 4,
        "daily_wage": 3800.0,
        "emergency_contact": "0770011223",
        "is_profile_incomplete": False,
    }

    signup_resp = client.post("/api/v1/auth/signup", json=signup_payload)
    assert signup_resp.status_code == 201
    reg_data = signup_resp.json()
    assert reg_data["email"] == "new.worker@siteapp.lk"
    assert reg_data["role"] == "labour"

    # Activate account directly in test session to test login
    from app.models.account import Account
    from sqlalchemy import select

    acc = session.scalar(select(Account).where(Account.email == "new.worker@siteapp.lk"))
    assert acc is not None
    acc.is_active = True
    acc.is_verified = True
    session.commit()

    # 2. Login by email
    login_resp = client.post(
        "/api/v1/auth/login",
        json={"email": "new.worker@siteapp.lk", "password": "securepassword123"},
    )
    assert login_resp.status_code == 200
    token = login_resp.json()["access_token"]

    # 3. Login by phone number
    login_phone_resp = client.post(
        "/api/v1/auth/login",
        json={"email": "0779988112", "password": "securepassword123"},
    )
    assert login_phone_resp.status_code == 200

    # 4. Login by international phone format
    login_intl_resp = client.post(
        "/api/v1/auth/login",
        json={"email": "+94779988112", "password": "securepassword123"},
    )
    assert login_intl_resp.status_code == 200

    # 5. Check unified profile endpoint
    profile_resp = client.get(
        "/api/v1/auth/profile",
        headers={"Authorization": f"Bearer {token}"},
    )
    assert profile_resp.status_code == 200
    prof = profile_resp.json()
    assert prof["name"] == "V. Sivalingam"
    assert prof["phone"] == "0779988112"
    assert prof["daily_wage"] == 3800.0
    assert "Bricklaying" in prof["skills"]
    assert prof["is_profile_incomplete"] is False


def test_material_request_assigned_supplier(
    test_env: tuple[TestClient, Session, dict[str, str]],
) -> None:
    client, _, headers = test_env

    # Create site
    site_resp = client.post(
        "/api/v1/sites",
        headers=headers["admin"],
        json={
            "site_name": "Supplier Assign Site",
            "project_name": "Bridge Works",
            "site_address": "A9 Highway, Jaffna",
            "client_name": "RDA",
            "start_date": "2026-10-01",
            "expected_completion_date": "2027-10-01",
            "status": "Active",
        },
    )
    site_id = site_resp.json()["id"]

    # Create supplier profile first
    supp_resp = client.post(
        "/api/v1/suppliers",
        headers=headers["admin"],
        json={
            "email": "hardware.orders@example.com",
            "password": "secure-pwd-hardware",
            "company_name": "Northern Cement Supplies",
            "contact_person": "M. Thamil",
            "phone_number": "0775554433",
            "address": "KKS Road, Jaffna",
            "company_registration_details": "PV-112233",
            "materials_supplied": "Cement, Concrete, Mortar",
            "company_status": "Active",
        },
    )
    assert supp_resp.status_code == 201
    supplier_id = supp_resp.json()["id"]

    # Create material request targeting this specific supplier
    req_resp = client.post(
        "/api/v1/material-requests",
        headers=headers["admin"],
        json={
            "site_id": site_id,
            "material_name": "Portland Composite Cement",
            "material_category": "Cement",
            "required_quantity": 200,
            "unit": "Bags",
            "required_date": "2026-11-20",
            "description": "Grade 42.5N bags for foundation columns",
            "assigned_supplier_id": supplier_id,
        },
    )
    assert req_resp.status_code == 201
    req_data = req_resp.json()
    assert req_data["assigned_supplier_id"] == supplier_id
    assert req_data["material_name"] == "Portland Composite Cement"
