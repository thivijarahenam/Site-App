"""Authentication and role authorization behavior tests."""


def test_login_and_authenticated_profile(auth_client) -> None:
    client, _ = auth_client
    login = client.post(
        "/api/v1/auth/login",
        json={"email": "WORKER@example.com", "password": "a-strong-worker-password"},
    )

    assert login.status_code == 200
    tokens = login.json()
    assert tokens["token_type"] == "bearer"
    assert tokens["expires_in"] == 900
    assert tokens["refresh_token"]

    profile = client.get(
        "/api/v1/auth/me", headers={"Authorization": f"Bearer {tokens['access_token']}"}
    )
    assert profile.status_code == 200
    assert profile.json()["role"] == "labour"


def test_invalid_login_and_missing_authentication_are_rejected(auth_client) -> None:
    client, _ = auth_client
    response = client.post(
        "/api/v1/auth/login",
        json={"email": "worker@example.com", "password": "wrong-password-value"},
    )
    assert response.status_code == 401

    protected = client.get("/api/v1/auth/me")
    assert protected.status_code == 401


def test_only_admin_can_create_accounts(auth_client) -> None:
    client, _ = auth_client
    worker_token = client.post(
        "/api/v1/auth/login",
        json={"email": "worker@example.com", "password": "a-strong-worker-password"},
    ).json()["access_token"]
    response = client.post(
        "/api/v1/auth/users",
        headers={"Authorization": f"Bearer {worker_token}"},
        json={"email": "new@example.com", "role": "supplier"},
    )

    assert response.status_code == 403


def test_admin_can_create_an_account_without_exposing_password(auth_client) -> None:
    client, _ = auth_client
    admin_token = client.post(
        "/api/v1/auth/login",
        json={"email": "admin@example.com", "password": "a-strong-admin-password"},
    ).json()["access_token"]
    response = client.post(
        "/api/v1/auth/users",
        headers={"Authorization": f"Bearer {admin_token}"},
        json={
            "email": "new-supplier@example.com",
            "role": "supplier",
        },
    )

    assert response.status_code == 201
    assert response.json()["role"] == "supplier"
    assert response.json()["is_active"] is False
    assert "password" not in response.json()
    assert "password_hash" not in response.json()


def test_refresh_rotation_and_reuse_revokes_family(auth_client) -> None:
    client, _ = auth_client
    first = client.post(
        "/api/v1/auth/login",
        json={"email": "worker@example.com", "password": "a-strong-worker-password"},
    ).json()["refresh_token"]
    rotated = client.post("/api/v1/auth/refresh", json={"refresh_token": first})
    assert rotated.status_code == 200

    reused = client.post("/api/v1/auth/refresh", json={"refresh_token": first})
    assert reused.status_code == 401
    family_token = client.post(
        "/api/v1/auth/refresh", json={"refresh_token": rotated.json()["refresh_token"]}
    )
    assert family_token.status_code == 401


def test_password_change_invalidates_access_tokens(auth_client) -> None:
    client, _ = auth_client
    token = client.post(
        "/api/v1/auth/login",
        json={"email": "worker@example.com", "password": "a-strong-worker-password"},
    ).json()["access_token"]
    changed = client.post(
        "/api/v1/auth/password",
        headers={"Authorization": f"Bearer {token}"},
        json={
            "current_password": "a-strong-worker-password",
            "new_password": "a-new-strong-worker-password",
        },
    )
    assert changed.status_code == 200
    profile = client.get("/api/v1/auth/me", headers={"Authorization": f"Bearer {token}"})
    assert profile.status_code == 401


def test_repeated_login_failures_temporarily_lock_account(auth_client) -> None:
    client, _ = auth_client
    for attempt in range(5):
        response = client.post(
            "/api/v1/auth/login",
            json={"email": "worker@example.com", "password": f"wrong-password-{attempt}"},
        )

    assert response.status_code == 429
    assert response.headers["Retry-After"] == "900"
    correct_password = client.post(
        "/api/v1/auth/login",
        json={"email": "worker@example.com", "password": "a-strong-worker-password"},
    )
    assert correct_password.status_code == 429
