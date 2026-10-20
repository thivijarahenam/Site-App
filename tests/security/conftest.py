"""Fixtures for database-backed authentication security tests."""

from collections.abc import Generator

import pytest
from fastapi.testclient import TestClient
from pydantic import SecretStr
from sqlalchemy import create_engine
from sqlalchemy.orm import Session, sessionmaker
from sqlalchemy.pool import StaticPool

from app.core.config import settings
from app.database.session import get_db
from app.main import app
from app.models import Account
from app.models.account import AccountRole
from app.models.base import Base
from app.security.password import hash_password


@pytest.fixture
def auth_client(
    monkeypatch: pytest.MonkeyPatch,
) -> Generator[tuple[TestClient, Session], None, None]:
    """Run API requests against an isolated in-memory SQLite database."""
    monkeypatch.setattr(settings, "jwt_secret_key", SecretStr("test-only-signing-key-" + "x" * 40))
    monkeypatch.setattr(
        settings, "account_link_token_secret", SecretStr("test-only-account-link-key-" + "x" * 32)
    )
    from app.services import account_link_service

    monkeypatch.setattr(account_link_service, "deliver_invitation", lambda *_args: None)
    engine = create_engine(
        "sqlite+pysqlite:///:memory:",
        connect_args={"check_same_thread": False},
        poolclass=StaticPool,
    )
    Base.metadata.create_all(engine)
    test_session = sessionmaker(bind=engine, expire_on_commit=False)()

    def override_get_db() -> Generator[Session, None, None]:
        yield test_session

    app.dependency_overrides[get_db] = override_get_db
    test_session.add(
        Account(
            email="admin@example.com",
            password_hash=hash_password("a-strong-admin-password"),
            role=AccountRole.ADMIN.value,
            is_active=True,
        )
    )
    test_session.add(
        Account(
            email="worker@example.com",
            password_hash=hash_password("a-strong-worker-password"),
            role=AccountRole.LABOUR.value,
            is_active=True,
        )
    )
    test_session.commit()

    with TestClient(app) as client:
        yield client, test_session

    app.dependency_overrides.clear()
    test_session.close()
    engine.dispose()
