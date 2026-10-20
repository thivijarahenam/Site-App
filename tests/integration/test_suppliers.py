"""Integration tests for Supplier Management."""

from fastapi.testclient import TestClient
from sqlalchemy.orm import Session


def test_supplier_lifecycle_and_permissions(
    test_env: tuple[TestClient, Session, dict[str, str]],
) -> None:
    client, _, headers = test_env

    # 1. Admin creates a supplier
    create_resp = client.post(
        "/api/v1/suppliers",
        json={
            "email": "sales@lankacement.lk",
            "password": "supplier-super-password-123",
            "company_name": "Lanka Cement PLC",
            "contact_person": "Dhammika Silva",
            "phone_number": "+94112345678",
            "address": "100 Industrial Zone, Galle",
            "company_registration_details": "PV-123456",
            "materials_supplied": "Portland Cement, Ready Mix, Aggregates",
            "bank_payment_info": "Bank of Ceylon - 0012345678",
            "company_status": "Active",
        },
        headers=headers["admin"],
    )
    assert create_resp.status_code == 201
    supplier_data = create_resp.json()
    supplier_id = supplier_data["id"]
    assert supplier_data["company_name"] == "Lanka Cement PLC"

    # 2. Login as the new supplier
    login_resp = client.post(
        "/api/v1/auth/login",
        json={"email": "sales@lankacement.lk", "password": "supplier-super-password-123"},
    )
    assert login_resp.status_code == 200
    token = login_resp.json()["access_token"]
    sup_headers = {"Authorization": f"Bearer {token}"}

    # 3. Supplier views own profile
    me_resp = client.get("/api/v1/suppliers/me", headers=sup_headers)
    assert me_resp.status_code == 200
    assert me_resp.json()["company_name"] == "Lanka Cement PLC"

    # 4. Supplier updates own contact details
    patch_resp = client.patch(
        "/api/v1/suppliers/me",
        json={"contact_person": "Dhammika M. Silva", "phone_number": "+94112999999"},
        headers=sup_headers,
    )
    assert patch_resp.status_code == 200
    assert patch_resp.json()["contact_person"] == "Dhammika M. Silva"
    assert patch_resp.json()["phone_number"] == "+94112999999"

    # 5. Supplier cannot view all suppliers (Admin route)
    forbidden_resp = client.get("/api/v1/suppliers", headers=sup_headers)
    assert forbidden_resp.status_code == 403

    # 6. Admin toggles supplier active/inactive status
    toggle_resp = client.post(
        f"/api/v1/suppliers/{supplier_id}/toggle-status",
        headers=headers["admin"],
    )
    assert toggle_resp.status_code == 200
    assert toggle_resp.json()["company_status"] == "Inactive"
