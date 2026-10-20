"""Integration tests for Labour Management."""

from fastapi.testclient import TestClient
from sqlalchemy.orm import Session


def test_labour_lifecycle_and_isolation(
    test_env: tuple[TestClient, Session, dict[str, str]],
) -> None:
    client, _, headers = test_env

    # 1. Admin creates a site first
    site_resp = client.post(
        "/api/v1/sites",
        json={
            "site_name": "Kandy Expressway Project",
            "project_name": "Section II Highway",
            "site_address": "Kadawatha to Mirigama",
            "client_name": "RDA Sri Lanka",
            "start_date": "2026-03-01",
            "expected_completion_date": "2028-06-30",
            "status": "Active",
            "description": "Expressway civil works",
        },
        headers=headers["admin"],
    )
    assert site_resp.status_code == 201
    site_id = site_resp.json()["id"]

    # 2. Admin creates a new labourer
    labour_create_resp = client.post(
        "/api/v1/labour",
        json={
            "email": "kamal.fernando@civilcorp.com",
            "password": "kamal-secure-pwd-1234",
            "full_name": "Kamal Fernando",
            "nic_number": "199023456789",
            "phone_number": "+94719876543",
            "address": "45 Peradeniya Road, Kandy",
            "job_role": "Steel Fixer",
            "skills": "Rebar bending, Reinforcement tying",
            "experience_years": 4,
            "joining_date": "2026-01-10",
            "emergency_contact": "Kumari Fernando (+94719876540)",
            "current_site_id": site_id,
            "status": "Active",
        },
        headers=headers["admin"],
    )
    assert labour_create_resp.status_code == 201
    created_labour = labour_create_resp.json()
    labour_id = created_labour["id"]
    assert created_labour["full_name"] == "Kamal Fernando"
    assert created_labour["current_site_id"] == site_id

    # 3. Admin lists all labourers
    list_resp = client.get("/api/v1/labour", headers=headers["admin"])
    assert list_resp.status_code == 200
    assert any(worker["id"] == labour_id for worker in list_resp.json())

    # 4. Login as the newly created labourer
    login_resp = client.post(
        "/api/v1/auth/login",
        json={
            "email": "kamal.fernando@civilcorp.com",
            "password": "kamal-secure-pwd-1234",
        },
    )
    assert login_resp.status_code == 200
    kamal_token = login_resp.json()["access_token"]
    kamal_headers = {"Authorization": f"Bearer {kamal_token}"}

    # 5. Kamal views his own profile
    me_resp = client.get("/api/v1/labour/me", headers=kamal_headers)
    assert me_resp.status_code == 200
    assert me_resp.json()["full_name"] == "Kamal Fernando"
    assert me_resp.json()["current_site"]["site_name"] == "Kandy Expressway Project"

    # 6. Kamal updates his contact address and phone
    update_me_resp = client.patch(
        "/api/v1/labour/me",
        json={"phone_number": "+94719999999", "address": "77 Temple Road, Kandy"},
        headers=kamal_headers,
    )
    assert update_me_resp.status_code == 200
    assert update_me_resp.json()["phone_number"] == "+94719999999"
    assert update_me_resp.json()["address"] == "77 Temple Road, Kandy"

    # 7. Kamal cannot access Admin labour listing
    forbidden_list = client.get("/api/v1/labour", headers=kamal_headers)
    assert forbidden_list.status_code == 403

    # 8. Admin unassigns Kamal from site
    unassign_resp = client.post(
        f"/api/v1/labour/{labour_id}/assign-site",
        json={"site_id": None},
        headers=headers["admin"],
    )
    assert unassign_resp.status_code == 200
    assert unassign_resp.json()["current_site_id"] is None

    # Check notification received by Kamal
    notifs_resp = client.get("/api/v1/notifications", headers=kamal_headers)
    assert notifs_resp.status_code == 200
    assert len(notifs_resp.json()) >= 1
