"""Tests for the public liveness endpoint."""

from fastapi.testclient import TestClient

from app.main import app


def test_health_returns_ok_without_database() -> None:
    """Health reports process liveness without touching the DB engine."""
    with TestClient(app) as client:
        response = client.get("/api/v1/health")

    assert response.status_code == 200
    assert response.json() == {"status": "ok"}


def test_unknown_path_uses_consistent_error_shape() -> None:
    with TestClient(app) as client:
        response = client.get("/api/v1/not-a-route")

    assert response.status_code == 404
    assert response.json()["error"]["code"] == "http_error"
