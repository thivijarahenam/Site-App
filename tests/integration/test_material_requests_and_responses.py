"""Integration tests for Material Request requisition & Supplier Quotation response workflow."""

from fastapi.testclient import TestClient
from sqlalchemy.orm import Session


def test_procurement_workflow(test_env: tuple[TestClient, Session, dict[str, str]]) -> None:
    client, _, headers = test_env

    # 1. Admin creates site
    site_resp = client.post(
        "/api/v1/sites",
        json={
            "site_name": "Colombo Apartment Project",
            "project_name": "Skyline Residences",
            "site_address": "Kollupitiya, Colombo 03",
            "client_name": "Skyline Properties Ltd",
            "start_date": "2026-04-01",
            "expected_completion_date": "2027-10-31",
            "status": "Active",
            "description": "25-storey residential tower",
        },
        headers=headers["admin"],
    )
    assert site_resp.status_code == 201
    site_id = site_resp.json()["id"]

    # 2. Admin creates a supplier
    sup_resp = client.post(
        "/api/v1/suppliers",
        json={
            "email": "orders@tokyocement.lk",
            "password": "tokyo-cement-pass-1234",
            "company_name": "Tokyo Super Cement",
            "contact_person": "Ruwan Jayasinghe",
            "phone_number": "+94119876543",
            "address": "469 Sri Sangaraja Mawatha, Colombo 10",
            "company_registration_details": "PV-998877",
            "materials_supplied": "Cement, Ready Mix, Mortar",
            "company_status": "Active",
        },
        headers=headers["admin"],
    )
    assert sup_resp.status_code == 201

    # Login as supplier
    sup_login = client.post(
        "/api/v1/auth/login",
        json={"email": "orders@tokyocement.lk", "password": "tokyo-cement-pass-1234"},
    )
    assert sup_login.status_code == 200
    sup_headers = {"Authorization": f"Bearer {sup_login.json()['access_token']}"}

    # 3. Admin creates Material Request: Cement - 100 Bags
    req_resp = client.post(
        "/api/v1/material-requests",
        json={
            "site_id": site_id,
            "material_name": "Cement OPC 42.5N",
            "material_category": "Cement",
            "required_quantity": 100.0,
            "unit": "Bags",
            "required_date": "2026-05-15",
            "description": "High early strength ordinary portland cement",
            "additional_notes": "Deliver in palletized bags to Colombo site",
        },
        headers=headers["admin"],
    )
    assert req_resp.status_code == 201
    req_id = req_resp.json()["id"]
    assert req_resp.json()["status"] == "Pending"

    # 4. Supplier sees notification and open material request
    notifs = client.get("/api/v1/notifications", headers=sup_headers)
    assert notifs.status_code == 200
    assert any("Cement" in n["message"] for n in notifs.json())

    sup_requests = client.get("/api/v1/material-requests", headers=sup_headers)
    assert sup_requests.status_code == 200
    assert any(r["id"] == req_id for r in sup_requests.json())

    # 5. Supplier submits quotation response
    quotation_resp = client.post(
        f"/api/v1/material-requests/{req_id}/responses",
        json={
            "available_quantity": 100.0,
            "unit_price": 2450.00,
            "total_price": 245000.00,
            "delivery_date": "2026-05-14",
            "delivery_details": "Direct transport via 10-wheel flatbed lorry",
            "availability_status": "Available",
            "additional_notes": "Prices valid for 14 days from quotation date",
        },
        headers=sup_headers,
    )
    assert quotation_resp.status_code == 201
    quotation_data = quotation_resp.json()
    resp_id = quotation_data["id"]
    assert quotation_data["status"] == "Submitted"
    assert float(quotation_data["total_price"]) == 245000.00

    # 6. Admin checks responses for this request
    admin_responses = client.get(
        f"/api/v1/material-requests/{req_id}/responses", headers=headers["admin"]
    )
    assert admin_responses.status_code == 200
    assert len(admin_responses.json()) == 1
    assert admin_responses.json()[0]["supplier"]["company_name"] == "Tokyo Super Cement"

    # 7. Admin accepts the quotation
    review_resp = client.post(
        f"/api/v1/supplier-responses/{resp_id}/review",
        json={"action": "Accepted", "admin_notes": "Best price and delivery timeframe confirmed"},
        headers=headers["admin"],
    )
    assert review_resp.status_code == 200
    assert review_resp.json()["status"] == "Accepted"

    # 8. Check that Material Request status became Approved
    updated_req = client.get(f"/api/v1/material-requests/{req_id}", headers=headers["admin"])
    assert updated_req.status_code == 200
    assert updated_req.json()["status"] == "Approved"

    # 9. Supplier checks own submitted responses history
    my_responses = client.get("/api/v1/supplier-responses/me", headers=sup_headers)
    assert my_responses.status_code == 200
    assert len(my_responses.json()) == 1
    assert my_responses.json()[0]["status"] == "Accepted"

    # 10. Supplier received approval notification
    sup_notifs = client.get("/api/v1/notifications", headers=sup_headers)
    assert sup_notifs.status_code == 200
    assert any("Accepted" in n["title"] for n in sup_notifs.json())
