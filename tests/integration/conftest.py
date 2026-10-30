"""Fixtures for Civil Construction Management integration tests."""

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
from app.models.account import Account, AccountRole
from app.models.base import Base
from app.security.password import hash_password
from app.security.tokens import create_access_token


@pytest.fixture
def test_env(
    monkeypatch: pytest.MonkeyPatch,
) -> Generator[tuple[TestClient, Session, dict[str, str]], None, None]:
    """Sets up an in-memory test database with seeded Admin, Labour, and Supplier accounts."""
    monkeypatch.setattr(settings, "jwt_secret_key", SecretStr("test-secret-key-" + "x" * 40))
    monkeypatch.setattr(
        settings, "account_link_token_secret", SecretStr("test-link-secret-" + "x" * 32)
    )

    engine = create_engine(
        "sqlite+pysqlite:///:memory:",
        connect_args={"check_same_thread": False},
        poolclass=StaticPool,
    )
    Base.metadata.create_all(engine)
    session = sessionmaker(bind=engine, expire_on_commit=False)()

    def override_get_db() -> Generator[Session, None, None]:
        yield session

    app.dependency_overrides[get_db] = override_get_db

    admin_acct = Account(
        email="admin@civilcorp.com",
        password_hash=hash_password("admin-secure-pass-123"),
        role=AccountRole.ADMIN.value,
        is_active=True,
    )
    supervisor_acct = Account(
        email="supervisor@civilcorp.com",
        password_hash=hash_password("supervisor-secure-pass-123"),
        role=AccountRole.SUPERVISOR.value,
        is_active=True,
    )
    labour_acct = Account(
        email="labour@civilcorp.com",
        password_hash=hash_password("labour-secure-pass-123"),
        role=AccountRole.LABOUR.value,
        is_active=True,
    )
    supplier_acct = Account(
        email="supplier@buildsupply.com",
        password_hash=hash_password("supplier-secure-pass-123"),
        role=AccountRole.SUPPLIER.value,
        is_active=True,
    )

    session.add_all([admin_acct, supervisor_acct, labour_acct, supplier_acct])
    session.commit()

    admin_token, _ = create_access_token(admin_acct)
    supervisor_token, _ = create_access_token(supervisor_acct)
    labour_token, _ = create_access_token(labour_acct)
    supplier_token, _ = create_access_token(supplier_acct)

    headers = {
        "admin": {"Authorization": f"Bearer {admin_token}"},
        "supervisor": {"Authorization": f"Bearer {supervisor_token}"},
        "labour": {"Authorization": f"Bearer {labour_token}"},
        "supplier": {"Authorization": f"Bearer {supplier_token}"},
        "admin_acct_id": str(admin_acct.id),
        "supervisor_acct_id": str(supervisor_acct.id),
        "labour_acct_id": str(labour_acct.id),
        "supplier_acct_id": str(supplier_acct.id),
    }

    with TestClient(app) as client:
        yield client, session, headers

    app.dependency_overrides.clear()
    session.close()
    engine.dispose()
