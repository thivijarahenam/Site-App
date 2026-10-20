"""Cryptographically secure OTP generation, verification, and rate limiting."""

import hashlib
import hmac
import logging
import secrets
from datetime import UTC, datetime, timedelta
from uuid import UUID

from fastapi import HTTPException, status
from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.core.config import settings
from app.models.account import Account, AccountOTP
from app.services import email_service

from app.security.tokens import as_utc

logger = logging.getLogger(__name__)

OTP_EXPIRY_MINUTES = 10
OTP_RESEND_COOLDOWN_SECONDS = 60
OTP_MAX_HOURLY_ATTEMPTS = 5
OTP_MAX_VERIFICATION_ATTEMPTS = 5
PURPOSE_REGISTRATION = "REGISTRATION_VERIFICATION"


def _otp_signing_key() -> bytes:
    if settings.account_link_token_secret is not None:
        return settings.account_link_token_secret.get_secret_value().encode("utf-8")
    return b"default-otp-secret-key-salt-change-in-production"


def generate_secure_otp() -> str:
    """Generate a uniform cryptographically random 6-digit numerical OTP."""
    return f"{secrets.randbelow(1_000_000):06d}"


def hash_otp(code: str, account_id: UUID) -> str:
    """Compute HMAC-SHA256 digest of the OTP code salted with account_id."""
    key = _otp_signing_key()
    msg = f"{account_id}:{code}".encode("utf-8")
    return hmac.new(key, msg, hashlib.sha256).hexdigest()


def create_and_send_registration_otp(
    db: Session, account: Account, *, check_cooldown: bool = False
) -> str:
    """Create a new registration OTP, apply rate limits, hash and store it, and dispatch it."""
    now = datetime.now(UTC)

    # Check rate limits if requested (e.g. on resend)
    if check_cooldown:
        latest_otp = db.scalar(
            select(AccountOTP)
            .where(
                AccountOTP.account_id == account.id,
                AccountOTP.purpose == PURPOSE_REGISTRATION,
            )
            .order_by(AccountOTP.created_at.desc())
            .limit(1)
        )
        if latest_otp is not None:
            time_since_last = (now - as_utc(latest_otp.created_at)).total_seconds()
            if time_since_last < OTP_RESEND_COOLDOWN_SECONDS:
                remaining = int(OTP_RESEND_COOLDOWN_SECONDS - time_since_last)
                raise HTTPException(
                    status_code=status.HTTP_429_TOO_MANY_REQUESTS,
                    detail=f"Please wait {remaining} seconds before requesting a new OTP.",
                )

        one_hour_ago = now - timedelta(hours=1)
        hourly_count = (
            db.scalar(
                select(func.count(AccountOTP.id)).where(
                    AccountOTP.account_id == account.id,
                    AccountOTP.purpose == PURPOSE_REGISTRATION,
                    AccountOTP.created_at >= one_hour_ago,
                )
            )
            or 0
        )
        if hourly_count >= OTP_MAX_HOURLY_ATTEMPTS:
            raise HTTPException(
                status_code=status.HTTP_429_TOO_MANY_REQUESTS,
                detail="Maximum OTP request limit reached. Please try again after an hour.",
            )

    # Invalidate any prior unconsumed OTPs for this account
    prior_otps = db.scalars(
        select(AccountOTP).where(
            AccountOTP.account_id == account.id,
            AccountOTP.purpose == PURPOSE_REGISTRATION,
            AccountOTP.consumed_at.is_(None),
        )
    ).all()
    for prior in prior_otps:
        prior.consumed_at = now

    otp_code = generate_secure_otp()
    otp_record = AccountOTP(
        account_id=account.id,
        otp_hash=hash_otp(otp_code, account.id),
        purpose=PURPOSE_REGISTRATION,
        expires_at=now + timedelta(minutes=OTP_EXPIRY_MINUTES),
        failed_attempts=0,
    )
    db.add(otp_record)
    db.commit()

    # Log code securely in development/debug mode
    logger.info("Generated registration OTP for %s: %s", account.email, otp_code)

    # Deliver via email
    email_service.send_otp_email(
        recipient=account.email, otp_code=otp_code, expiry_minutes=OTP_EXPIRY_MINUTES
    )

    return otp_code


def verify_registration_otp(db: Session, email: str, code: str) -> Account:
    """Verify submitted OTP code against active record with brute-force protection."""
    now = datetime.now(UTC)
    norm_email = email.strip().lower()

    account = db.scalar(select(Account).where(Account.email == norm_email))
    if account is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Account not found",
        )

    if account.is_verified:
        return account

    otp_record = db.scalar(
        select(AccountOTP)
        .where(
            AccountOTP.account_id == account.id,
            AccountOTP.purpose == PURPOSE_REGISTRATION,
            AccountOTP.consumed_at.is_(None),
        )
        .order_by(AccountOTP.created_at.desc())
        .limit(1)
    )

    if otp_record is None:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="No active OTP found. Please request a new verification code.",
        )

    # Check if expired
    if now > as_utc(otp_record.expires_at):
        otp_record.consumed_at = now
        db.commit()
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="OTP code has expired. Please request a new verification code.",
        )

    # Check brute-force attempts
    if otp_record.failed_attempts >= OTP_MAX_VERIFICATION_ATTEMPTS:
        otp_record.consumed_at = now
        db.commit()
        raise HTTPException(
            status_code=status.HTTP_429_TOO_MANY_REQUESTS,
            detail="Too many invalid attempts. This OTP has been invalidated. Please request a new code.",
        )

    expected_hash = hash_otp(code.strip(), account.id)
    if not hmac.compare_digest(expected_hash, otp_record.otp_hash):
        otp_record.failed_attempts += 1
        remaining_attempts = OTP_MAX_VERIFICATION_ATTEMPTS - otp_record.failed_attempts
        db.commit()
        if remaining_attempts <= 0:
            otp_record.consumed_at = now
            db.commit()
            raise HTTPException(
                status_code=status.HTTP_429_TOO_MANY_REQUESTS,
                detail="Too many invalid attempts. Please request a new code.",
            )
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Invalid verification code. {remaining_attempts} attempt(s) remaining.",
        )

    # Successful verification
    otp_record.consumed_at = now
    account.is_verified = True
    account.verification_status = "VERIFIED"
    account.is_active = True
    db.commit()
    db.refresh(account)
    return account


def resend_registration_otp(db: Session, email: str) -> None:
    """Handle user request to resend OTP code with rate limiting."""
    norm_email = email.strip().lower()
    account = db.scalar(select(Account).where(Account.email == norm_email))
    if account is None:
        # Don't leak whether account exists to prevent account enumeration
        return

    if account.is_verified:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Account is already verified. Please sign in.",
        )

    create_and_send_registration_otp(db, account, check_cooldown=True)
