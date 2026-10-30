"""Integration tests for Project Logbook endpoints matching frontend workflows."""

from fastapi.testclient import TestClient
from sqlalchemy.orm import Session

from app.models.site import ConstructionSite, SiteStatus


def _create_test_site(client: TestClient, admin_headers: dict[str, str]) -> str:
    resp = client.post(
        "/api/v1/sites",
        headers=admin_headers,
        json={
            "site_name": "Logbook Test Project",
            "project_name": "Civil Diary Test",
            "site_address": "Kandy Road, Jaffna",
            "client_name": "Jaffna Municipal Council",
            "start_date": "2026-10-01",
            "expected_completion_date": "2027-05-30",
            "status": "Active",
            "description": "Logbook integration test site",
        },
    )
    assert resp.status_code == 201
    return resp.json()["id"]


def test_project_logbook_lifecycle(
    test_env: tuple[TestClient, Session, dict[str, str]],
) -> None:
    client, _, headers = test_env

    # 1. Create a site first
    site_id = _create_test_site(client, headers["admin"])

    # 2. Supervisor / Admin creates a logbook entry
    create_payload = {
        "site_id": site_id,
        "author_name": "K. Sivaram",
        "author_role": "Site Supervisor",
        "author_avatar": "https://example.com/avatar.jpg",
        "category": "inspectionQA",
        "title": "Level 1 Slab Reinforcement Inspection",
        "description": "Inspected bottom rebar cover and lap lengths. Everything aligns with structural drawings.",
        "photo_urls": ["https://example.com/photo1.jpg"],
        "attachments": [
            {"name": "Drawing_ST_04.pdf", "size": "2.4 MB", "extension": "pdf"}
        ],
        "linked_items": ["ST-04 Structural Sheet", "Concrete Pour Approval"],
    }

    create_resp = client.post(
        "/api/v1/logbook",
        headers=headers["supervisor"],
        json=create_payload,
    )
    assert create_resp.status_code == 201, create_resp.text
    entry_data = create_resp.json()
    entry_id = entry_data["id"]
    assert entry_data["site_id"] == site_id
    assert entry_data["title"] == "Level 1 Slab Reinforcement Inspection"
    assert entry_data["category"] == "inspectionQA"
    assert entry_data["is_acknowledged"] is False
    assert len(entry_data["attachments"]) == 1

    # 3. List logbook entries with site_id filter
    list_resp = client.get(
        f"/api/v1/logbook?site_id={site_id}",
        headers=headers["supervisor"],
    )
    assert list_resp.status_code == 200
    entries = list_resp.json()
    assert len(entries) >= 1
    assert any(e["id"] == entry_id for e in entries)

    # Filter by category
    cat_resp = client.get(
        f"/api/v1/logbook?category=inspectionQA",
        headers=headers["supervisor"],
    )
    assert cat_resp.status_code == 200
    assert any(e["id"] == entry_id for e in cat_resp.json())

    # 4. Get single logbook entry
    get_resp = client.get(f"/api/v1/logbook/{entry_id}")
    assert get_resp.status_code == 200
    assert get_resp.json()["id"] == entry_id

    # 5. Add a comment to the entry
    comment_payload = {
        "author_name": "Jana Kumaran",
        "author_role": "Project Admin",
        "text": "Approved. Concrete pump scheduled for tomorrow at 8:00 AM.",
        "avatar_url": "https://example.com/admin.jpg",
    }
    comment_resp = client.post(
        f"/api/v1/logbook/{entry_id}/comments",
        json=comment_payload,
    )
    assert comment_resp.status_code == 201
    c_data = comment_resp.json()
    assert c_data["author_name"] == "Jana Kumaran"
    assert c_data["text"] == comment_payload["text"]

    # 6. Acknowledge the entry
    ack_payload = {
        "acknowledged_by": "Jana Kumaran (Project Admin)",
    }
    ack_resp = client.post(
        f"/api/v1/logbook/{entry_id}/acknowledge",
        headers=headers["admin"],
        json=ack_payload,
    )
    assert ack_resp.status_code == 200
    ack_data = ack_resp.json()
    assert ack_data["is_acknowledged"] is True
    assert ack_data["acknowledged_by"] == "Jana Kumaran (Project Admin)"
    assert ack_data["acknowledged_at"] is not None
    assert len(ack_data["comments"]) == 1
