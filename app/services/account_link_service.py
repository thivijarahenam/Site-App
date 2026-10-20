"""One-time invitation and password-reset link workflows."""

import hashlib
import hmac
import logging
import secrets
from datetime import UTC, datetime, timedelta
from uuid import UUID

from fastapi import HTTPException
from sqlalchemy import delete, select
from sqlalchemy.orm import Session

from app.core.config import settings
from app.models.account import Account, AccountActionToken
from app.repositories import account_repository as accounts
from app.security.password import hash_password
from app.security.tokens import as_utc

logger = logging.getLogger(__name__)

INVITATION = "account_invitation"
PASSWORD_RESET = "password_reset"


def _secret() -> bytes:
    secret = settings.account_link_token_secret
    if secret is None:
        raise HTTPException(status_code=503, detail="Account links are not configured")
    return secret.get_secret_value().encode("utf-8")


def _digest(raw_token: str, purpose: str) -> str:
    return hmac.new(_secret(), f"{purpose}:{raw_token}".encode(), hashlib.sha256).hexdigest()


def _link(path: str, raw_token: str) -> str:
    return f"{settings.app_link_base_url.rstrip('/')}{path}?token={raw_token}"


def issue_token(
    db: Session, account: Account, purpose: str, *, commit: bool = True
) -> tuple[str, str]:
    """Create a random token, persist only its keyed digest, and return raw token plus link."""
    now = datetime.now(UTC)
    db.execute(
        delete(AccountActionToken).where(
            AccountActionToken.account_id == account.id,
            AccountActionToken.created_at < now - timedelta(days=30),
        )
    )
    current = db.scalars(
        select(AccountActionToken)
        .where(
            AccountActionToken.account_id == account.id,
            AccountActionToken.purpose == purpose,
            AccountActionToken.consumed_at.is_(None),
        )
        .with_for_update()
    ).all()
    for old in current:
        old.consumed_at = now

    raw = secrets.token_urlsafe(32)
    if purpose == INVITATION:
        expires = now + timedelta(hours=settings.account_invitation_link_hours)
        path = "/auth/accept-invitation"
    else:
        expires = now + timedelta(minutes=settings.password_reset_link_minutes)
        path = "/auth/reset-password"
    db.add(
        AccountActionToken(
            account_id=account.id,
            token_hmac=_digest(raw, purpose),
            purpose=purpose,
            created_at=now,
            expires_at=expires,
        )
    )
    if commit:
        db.commit()
    return raw, _link(path, raw)


def create_invitation_token(db: Session, account: Account) -> str:
    """Issue an invitation as part of the admin account-creation transaction."""
    _, link = issue_token(db, account, INVITATION, commit=False)
    return link


def resend_invitation(db: Session, account_id: UUID) -> tuple[str, str, str] | None:
    """Reissue an invite for a pending account, subject to the resend cooldown."""
    _secret()
    account = db.scalar(select(Account).where(Account.id == account_id).with_for_update())
    if account is None or account.is_active:
        return None
    latest = db.scalar(
        select(AccountActionToken)
        .where(
            AccountActionToken.account_id == account.id,
            AccountActionToken.purpose == INVITATION,
        )
        .order_by(AccountActionToken.created_at.desc())
        .limit(1)
        .with_for_update()
    )
    now = datetime.now(UTC)
    if (
        latest is not None
        and (now - as_utc(latest.created_at)).total_seconds()
        < settings.account_action_resend_seconds
    ):
        return None
    _, link = issue_token(db, account, INVITATION)
    return account.email, account.role, link


def request_password_reset(db: Session, email: str) -> tuple[str, str] | None:
    """Issue a reset link for active accounts without revealing account existence."""
    _secret()
    account = accounts.get_account_by_email(db, email, for_update=True)
    if account is None or not account.is_active:
        return None
    latest = db.scalar(
        select(AccountActionToken)
        .where(
            AccountActionToken.account_id == account.id,
            AccountActionToken.purpose == PASSWORD_RESET,
        )
        .order_by(AccountActionToken.created_at.desc())
        .limit(1)
        .with_for_update()
    )
    now = datetime.now(UTC)
    if (
        latest is not None
        and (now - as_utc(latest.created_at)).total_seconds()
        < settings.account_action_resend_seconds
    ):
        return None
    _, link = issue_token(db, account, PASSWORD_RESET)
    return account.email, link


def deliver_invitation(recipient: str, role: str, link: str) -> None:
    from app.services.email_service import send_account_invitation_email

    try:
        send_account_invitation_email(recipient, role, link)
    except Exception:
        logger.exception("Account invitation email delivery failed")


def deliver_password_reset(recipient: str, link: str) -> None:
    from app.services.email_service import send_password_reset_email

    try:
        send_password_reset_email(recipient, link)
    except Exception:
        logger.exception("Password reset email delivery failed")


def consume_link(db: Session, raw_token: str, purpose: str, new_password: str) -> None:
    """Consume a valid link once and apply its account action."""
    digest = _digest(raw_token, purpose)
    token = db.scalar(
        select(AccountActionToken)
        .where(
            AccountActionToken.token_hmac == digest,
            AccountActionToken.purpose == purpose,
        )
        .with_for_update()
    )
    now = datetime.now(UTC)
    if token is None or token.consumed_at is not None or as_utc(token.expires_at) <= now:
        raise HTTPException(status_code=400, detail="Invalid or expired account link")

    account = db.scalar(select(Account).where(Account.id == token.account_id).with_for_update())
    if account is None or (purpose == INVITATION and account.is_active):
        raise HTTPException(status_code=400, detail="Invalid or expired account link")
    if purpose == PASSWORD_RESET and not account.is_active:
        raise HTTPException(status_code=400, detail="Invalid or expired account link")

    token.consumed_at = now
    account.password_hash = hash_password(new_password)
    account.failed_login_attempts = 0
    account.locked_until = None
    if purpose == INVITATION:
        account.is_active = True
        account.is_verified = True
        account.verification_status = "VERIFIED"
    else:
        account.token_version += 1
        accounts.revoke_account_refresh_tokens(db, account.id, now)
    db.commit()
