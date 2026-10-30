"""Integration tests for Marketplace Equipment Rentals and Food Supply Orders."""

from fastapi.testclient import TestClient
from sqlalchemy.orm import Session


def _create_test_site(client: TestClient, admin_headers: dict[str, str]) -> str:
    resp = client.post(
        "/api/v1/sites",
        headers=admin_headers,
        json={
            "site_name": "Marketplace Test Site",
            "project_name": "Commercial Complex",
            "site_address": "Beach Road, Jaffna",
            "client_name": "Northern Development Authority",
            "start_date": "2026-11-01",
            "expected_completion_date": "2027-11-30",
            "status": "Active",
            "description": "Marketplace integration test site",
        },
    )
    assert resp.status_code == 201
    return resp.json()["id"]


def test_marketplace_equipment_rentals(
    test_env: tuple[TestClient, Session, dict[str, str]],
) -> None:
    client, _, headers = test_env

    # 1. Admin adds equipment rental item
    rental_payload = {
        "name": "CAT 320 Hydraulic Excavator",
        "category": "Excavator",
        "daily_rate": 45000.00,
        "available_stock": 3,
        "on_rental_count": 1,
        "image_url": "https://example.com/cat320.jpg",
    }
    create_resp = client.post(
        "/api/v1/marketplace/rentals",
        headers=headers["admin"],
        json=rental_payload,
    )
    assert create_resp.status_code == 201
    r_data = create_resp.json()
    rental_id = r_data["id"]
    assert r_data["name"] == "CAT 320 Hydraulic Excavator"
    assert float(r_data["daily_rate"]) == 45000.00

    # 2. List rentals with category filter
    list_resp = client.get("/api/v1/marketplace/rentals?category=Excavator")
    assert list_resp.status_code == 200
    rentals = list_resp.json()
    assert len(rentals) >= 1
    assert any(r["id"] == rental_id for r in rentals)


def test_marketplace_food_supply_orders(
    test_env: tuple[TestClient, Session, dict[str, str]],
) -> None:
    client, _, headers = test_env

    site_id = _create_test_site(client, headers["admin"])

    # 1. Supervisor places food supply order
    order_payload = {
        "site_id": site_id,
        "meal_type": "Lunch",
        "portions": 30,
        "delivery_date": "2026-11-15",
        "delivery_time": "12:30 PM",
        "status": "Pending",
        "total_cost": 13500.00,
    }
    create_resp = client.post(
        "/api/v1/marketplace/food-orders",
        headers=headers["supervisor"],
        json=order_payload,
    )
    assert create_resp.status_code == 201
    o_data = create_resp.json()
    order_id = o_data["id"]
    assert o_data["site_id"] == site_id
    assert o_data["portions"] == 30
    assert o_data["status"] == "Pending"
    assert o_data["site_name"] == "Marketplace Test Site"

    # 2. Update food order status to "Delivered"
    patch_resp = client.patch(
        f"/api/v1/marketplace/food-orders/{order_id}",
        headers=headers["admin"],
        json={
            "status": "Delivered",
            "portions": 32,
            "total_cost": 14400.00,
        },
    )
    assert patch_resp.status_code == 200
    p_data = patch_resp.json()
    assert p_data["status"] == "Delivered"
    assert p_data["portions"] == 32
    assert float(p_data["total_cost"]) == 14400.00

    # 3. List food orders filtered by site
    list_resp = client.get(f"/api/v1/marketplace/food-orders?site_id={site_id}")
    assert list_resp.status_code == 200
    orders = list_resp.json()
    assert len(orders) >= 1
    assert any(o["id"] == order_id for o in orders)
