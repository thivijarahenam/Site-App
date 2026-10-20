"""Integration tests for Dashboards, Reports, and Notifications."""

from fastapi.testclient import TestClient
from sqlalchemy.orm import Session


def test_dashboards_reports_and_notifications(
    test_env: tuple[TestClient, Session, dict[str, str]],
) -> None:
    client, _, headers = test_env

    # 1. Admin Dashboard
    admin_dash = client.get("/api/v1/dashboard/admin", headers=headers["admin"])
    assert admin_dash.status_code == 200
    data = admin_dash.json()
    assert "total_sites" in data
    assert "active_sites" in data
    assert "total_labourers" in data
    assert "active_labourers" in data
    assert "total_suppliers" in data
    assert "pending_material_requests" in data

    # 2. Labour Dashboard
    labour_dash = client.get("/api/v1/dashboard/labour", headers=headers["labour"])
    assert labour_dash.status_code == 200
    l_data = labour_dash.json()
    assert "profile" in l_data
    assert "unread_notifications_count" in l_data
    assert "recent_notifications" in l_data

    # 3. Supplier Dashboard
    supplier_dash = client.get("/api/v1/dashboard/supplier", headers=headers["supplier"])
    assert supplier_dash.status_code == 200
    s_data = supplier_dash.json()
    assert "open_material_requests_count" in s_data
    assert "submitted_responses_count" in s_data
    assert "unread_notifications_count" in s_data

    # 4. Notifications test
    count_resp = client.get("/api/v1/notifications/unread-count", headers=headers["admin"])
    assert count_resp.status_code == 200
    assert "unread_count" in count_resp.json()

    read_all_resp = client.post("/api/v1/notifications/read-all", headers=headers["admin"])
    assert read_all_resp.status_code == 200

    count_after = client.get("/api/v1/notifications/unread-count", headers=headers["admin"])
    assert count_after.status_code == 200
    assert count_after.json()["unread_count"] == 0

    # 5. Admin Reports
    reports_resp = client.get("/api/v1/reports/summary", headers=headers["admin"])
    assert reports_resp.status_code == 200
    r_data = reports_resp.json()
    assert "sites_by_status" in r_data
    assert "site_labour_distribution" in r_data
    assert "requests_by_category" in r_data
    assert "supplier_performance" in r_data
