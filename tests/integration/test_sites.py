"""Integration tests for Construction Site management."""

from fastapi.testclient import TestClient
from sqlalchemy.orm import Session

from app.models.labour import LabourProfile


def test_site_lifecycle_and_rbac(test_env: tuple[TestClient, Session, dict[str, str]]) -> None:
    client, session, headers = test_env

    # 1. Non-admin cannot create a site
    forbidden_resp = client.post(
        "/api/v1/sites",
        json={
            "site_name": "Lotus Tower",
            "project_name": "Telecom Infrastructure",
            "site_address": "D.R. Wijewardena Mawatha, Colombo",
            "client_name": "Telecommunications Ministry",
            "start_date": "2026-01-01",
            "expected_completion_date": "2027-01-01",
            "status": "Active",
            "description": "High-rise telecommunication tower",
        },
        headers=headers["labour"],
    )
    assert forbidden_resp.status_code == 403

    # 2. Admin creates a site
    create_resp = client.post(
        "/api/v1/sites",
        json={
            "site_name": "Colombo Port City",
            "project_name": "Financial Centre Phase 1",
            "site_address": "Port City, Colombo 01",
            "client_name": "CHEC Port City Colombo",
            "start_date": "2026-02-01",
            "expected_completion_date": "2028-12-31",
            "status": "Active",
            "description": "Modern coastal commercial complex",
        },
        headers=headers["admin"],
    )
    assert create_resp.status_code == 201
    site_data = create_resp.json()
    site_id = site_data["id"]
    assert site_data["site_name"] == "Colombo Port City"
    assert site_data["assigned_labourer_count"] == 0

    # 3. Admin lists sites
    list_resp = client.get("/api/v1/sites", headers=headers["admin"])
    assert list_resp.status_code == 200
    assert len(list_resp.json()) >= 1

    # 4. Admin updates site status to On Hold
    patch_resp = client.patch(
        f"/api/v1/sites/{site_id}",
        json={"status": "On Hold", "description": "Temporarily paused for weather review"},
        headers=headers["admin"],
    )
    assert patch_resp.status_code == 200
    assert patch_resp.json()["status"] == "On Hold"
    assert patch_resp.json()["description"] == "Temporarily paused for weather review"

    # 5. Labour views their assigned site when unassigned -> null
    me_resp = client.get("/api/v1/sites/assigned/me", headers=headers["labour"])
    assert me_resp.status_code == 200
    assert me_resp.json() is None

    # 6. Assign labourer to site in DB and check labour's view
    from datetime import date
    from uuid import UUID

    labour_profile = LabourProfile(
        account_id=UUID(headers["labour_acct_id"]),
        current_site_id=UUID(site_id),
        full_name="Sunil Perera",
        nic_number="198512345678",
        phone_number="+94771234567",
        address="12 Galle Road, Colombo",
        job_role="Mason",
        skills="Bricklaying, Plastering",
        experience_years=5,
        joining_date=date(2025, 1, 15),
        emergency_contact="Nimal Perera (+94777654321)",
        status="Active",
    )
    session.add(labour_profile)
    session.commit()

    me_assigned_resp = client.get("/api/v1/sites/assigned/me", headers=headers["labour"])
    assert me_assigned_resp.status_code == 200
    assigned_data = me_assigned_resp.json()
    assert assigned_data["id"] == site_id
    assert assigned_data["site_name"] == "Colombo Port City"

    # 7. Admin views labourers at site
    workers_resp = client.get(f"/api/v1/sites/{site_id}/labourers", headers=headers["admin"])
    assert workers_resp.status_code == 200
    assert len(workers_resp.json()) == 1
    assert workers_resp.json()[0]["full_name"] == "Sunil Perera"
