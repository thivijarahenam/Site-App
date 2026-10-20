"""JWT access-token and opaque refresh-token helpers."""

import hashlib
import secrets
from datetime import UTC, datetime, timedelta
from uuid import UUID

import jwt
from fastapi import HTTPException, status
from jwt.exceptions import InvalidTokenError

from app.core.config import settings
from app.models.account import Account

ALGORITHM = "HS256"


def _signing_key() -> str:
    key = settings.jwt_secret_key
    if key is None:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="Authentication is not configured",
        )
    return key.get_secret_value()


def create_access_token(account: Account) -> tuple[str, int]:
    """Create a short-lived, signed access token with fixed claims and algorithm."""
    expires_in = settings.access_token_minutes * 60
    now = datetime.now(UTC)
    payload = {
        "sub": str(account.id),
        "role": account.role,
        "ver": account.token_version,
        "iss": settings.jwt_issuer,
        "aud": settings.jwt_audience,
        "iat": now,
        "exp": now + timedelta(seconds=expires_in),
        "jti": secrets.token_urlsafe(16),
        "token_use": "access",
    }
    return jwt.encode(payload, _signing_key(), algorithm=ALGORITHM), expires_in


def decode_access_token(token: str) -> dict[str, object]:
    """Verify signature, algorithm, issuer, audience, and expiry."""
    try:
        claims = jwt.decode(
            token,
            _signing_key(),
            algorithms=[ALGORITHM],
            issuer=settings.jwt_issuer,
            audience=settings.jwt_audience,
            options={"require": ["sub", "exp", "iat", "jti", "ver", "token_use"]},
        )
    except HTTPException:
        raise
    except InvalidTokenError as exc:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired access token",
            headers={"WWW-Authenticate": "Bearer"},
        ) from exc
    if claims.get("token_use") != "access":
        raise HTTPException(status_code=401, detail="Invalid access token")
    return claims


def create_refresh_token() -> str:
    """Create a high-entropy opaque refresh token."""
    return secrets.token_urlsafe(48)


def hash_refresh_token(token: str) -> str:
    """Return a one-way digest suitable for database storage."""
    return hashlib.sha256(token.encode("utf-8")).hexdigest()


def new_refresh_expiry() -> datetime:
    return datetime.now(UTC) + timedelta(days=settings.refresh_token_days)


def as_utc(value: datetime) -> datetime:
    """Normalize database datetimes returned without timezone metadata."""
    if value.tzinfo is None:
        return value.replace(tzinfo=UTC)
    return value.astimezone(UTC)


def token_subject(claims: dict[str, object]) -> UUID:
    try:
        return UUID(str(claims["sub"]))
    except (KeyError, ValueError) as exc:
        raise HTTPException(status_code=401, detail="Invalid access token") from exc
