"""Authentication workflows and business rules."""

import secrets
from datetime import UTC, datetime, timedelta
from uuid import UUID, uuid4

from fastapi import HTTPException, status
from pydantic import EmailStr, TypeAdapter, ValidationError
from sqlalchemy import select
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from app.models.account import Account, AccountRole, RefreshToken
from app.models.labour import LabourProfile
from app.models.supplier import SupplierProfile
from app.repositories import account_repository as accounts
from app.schemas.auth import (
    AccountCreateRequest,
    EmployeeSignupRequest,
    LoginRequest,
    SignupRequest,
    SupplierSignupRequest,
    TokenResponse,
)
from app.security.password import hash_password, verify_dummy_password, verify_password
from app.security.tokens import (
    as_utc,
    create_access_token,
    create_refresh_token,
    hash_refresh_token,
    new_refresh_expiry,
)
from app.services import account_link_service, otp_service

MAX_LOGIN_FAILURES = 5
LOGIN_LOCK_MINUTES = 15


def _token_pair(db: Session, account: Account, family_id: UUID | None = None) -> TokenResponse:
    access_token, expires_in = create_access_token(account)
    raw_refresh = create_refresh_token()
    db.add(
        RefreshToken(
            account_id=account.id,
            token_hash=hash_refresh_token(raw_refresh),
            family_id=family_id or uuid4(),
            expires_at=new_refresh_expiry(),
        )
    )
    db.commit()
    return TokenResponse(
        access_token=access_token,
        expires_in=expires_in,
        refresh_token=raw_refresh,
    )


def login(db: Session, request: LoginRequest) -> TokenResponse:
    """Authenticate by email and issue access and refresh tokens."""
    now = datetime.now(UTC)
    account = accounts.get_account_by_email(db, str(request.email), for_update=True)
    if account is None:
        verify_dummy_password(request.password)
        raise HTTPException(status_code=401, detail="Invalid email or password")

    if account.locked_until is not None and as_utc(account.locked_until) > now:
        db.commit()
        raise HTTPException(
            status_code=429,
            detail="Too many unsuccessful login attempts",
            headers={
                "Retry-After": str(
                    max(1, int((as_utc(account.locked_until) - now).total_seconds()))
                )
            },
        )
    if account.locked_until is not None and as_utc(account.locked_until) <= now:
        account.failed_login_attempts = 0
        account.locked_until = None

    password_ok = verify_password(request.password, account.password_hash)
    if not password_ok:
        account.failed_login_attempts += 1
        if account.failed_login_attempts >= MAX_LOGIN_FAILURES:
            account.locked_until = now + timedelta(minutes=LOGIN_LOCK_MINUTES)
            db.commit()
            raise HTTPException(
                status_code=429,
                detail="Too many unsuccessful login attempts",
                headers={"Retry-After": str(LOGIN_LOCK_MINUTES * 60)},
            )
        db.commit()
        raise HTTPException(status_code=401, detail="Invalid email or password")

    if not account.is_verified:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Account is not verified. Please verify your OTP to activate your account.",
        )

    if not account.is_active:
        raise HTTPException(status_code=401, detail="Account is inactive")

    account.failed_login_attempts = 0
    account.locked_until = None
    db.flush()
    return _token_pair(db, account)


def refresh(db: Session, raw_token: str) -> TokenResponse:
    """Rotate a refresh token; reuse revokes its whole token family."""
    now = datetime.now(UTC)
    token = accounts.get_refresh_token(db, hash_refresh_token(raw_token), for_update=True)
    if token is None:
        raise HTTPException(status_code=401, detail="Invalid or expired refresh token")
    if token.revoked_at is not None:
        accounts.revoke_refresh_family(db, token.family_id, now)
        db.commit()
        raise HTTPException(status_code=401, detail="Refresh token has been revoked")
    if as_utc(token.expires_at) <= now:
        raise HTTPException(status_code=401, detail="Refresh token has expired")

    token.revoked_at = now
    account = accounts.get_account(db, token.account_id)
    if account is None or not account.is_active:
        db.commit()
        raise HTTPException(status_code=401, detail="Account is unavailable")

    return _token_pair(db, account, family_id=token.family_id)


def logout(db: Session, raw_token: str) -> None:
    """Revoke a refresh token if it exists; safe to call more than once."""
    token = accounts.get_refresh_token(db, hash_refresh_token(raw_token), for_update=True)
    if token is not None and token.revoked_at is None:
        token.revoked_at = datetime.now(UTC)
        db.commit()


def signup_employee(db: Session, request: EmployeeSignupRequest) -> tuple[Account, str]:
    """Self-registration for employee/leader role with immediate strong OTP."""
    norm_email = str(request.email).strip().lower()
    existing = accounts.get_account_by_email(db, norm_email)
    if existing is not None:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="An account with this email already exists",
        )

    full_name = f"{request.first_name} {request.last_name}".strip()
    account = Account(
        email=norm_email,
        password_hash=hash_password(request.password),
        role=AccountRole.EMPLOYEE.value,
        is_active=False,
        is_verified=False,
        verification_status="PENDING",
    )
    accounts.add_account(db, account)

    profile = LabourProfile(
        account_id=account.id,
        first_name=request.first_name,
        last_name=request.last_name,
        full_name=full_name,
        phone_number=request.phone_number,
        address=request.address,
        job_role=request.job_role or "Employee / Leader",
        nic_number=request.nic_number,
        skills=request.skills,
        experience_years=request.experience_years,
        status="Active",
    )
    db.add(profile)
    try:
        db.commit()
    except IntegrityError as exc:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="An account or labour profile conflict occurred",
        ) from exc

    db.refresh(account)
    otp_code = otp_service.create_and_send_registration_otp(db, account)
    return account, otp_code


def signup_supplier(db: Session, request: SupplierSignupRequest) -> tuple[Account, str]:
    """Self-registration for supplier role with immediate strong OTP."""
    norm_email = str(request.email).strip().lower()
    existing = accounts.get_account_by_email(db, norm_email)
    if existing is not None:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="An account with this email already exists",
        )

    contact_person = f"{request.first_name} {request.last_name}".strip()
    company_name = request.company_name or f"{contact_person} Supplies"

    account = Account(
        email=norm_email,
        password_hash=hash_password(request.password),
        role=AccountRole.SUPPLIER.value,
        is_active=False,
        is_verified=False,
        verification_status="PENDING",
    )
    accounts.add_account(db, account)

    profile = SupplierProfile(
        account_id=account.id,
        first_name=request.first_name,
        last_name=request.last_name,
        company_name=company_name,
        contact_person=contact_person,
        phone_number=request.phone_number,
        email=norm_email,
        address=request.address,
        company_registration_details=request.company_registration_details or "Registered Supplier",
        materials_supplied=request.materials_supplied or "General Construction Materials",
        bank_payment_info=request.bank_payment_info,
        company_status="Active",
    )
    db.add(profile)
    try:
        db.commit()
    except IntegrityError as exc:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="An account or supplier profile conflict occurred",
        ) from exc

    db.refresh(account)
    otp_code = otp_service.create_and_send_registration_otp(db, account)
    return account, otp_code


def signup(db: Session, request: SignupRequest) -> tuple[Account, str]:
    """Unified self-registration handler dispatching by role."""
    if request.role in {"employee", "labour"}:
        employee_req = EmployeeSignupRequest(
            email=request.email,
            password=request.password,
            first_name=request.first_name,
            last_name=request.last_name,
            phone_number=request.phone_number,
            address=request.address,
            job_role=request.job_role or "Employee / Leader",
            nic_number=request.nic_number,
            skills=request.skills,
            experience_years=request.experience_years or 0,
        )
        return signup_employee(db, employee_req)
    elif request.role == "supplier":
        supplier_req = SupplierSignupRequest(
            email=request.email,
            password=request.password,
            first_name=request.first_name,
            last_name=request.last_name,
            phone_number=request.phone_number,
            address=request.address,
            company_name=request.company_name,
            company_registration_details=request.company_registration_details,
            materials_supplied=request.materials_supplied,
            bank_payment_info=request.bank_payment_info,
        )
        return signup_supplier(db, supplier_req)
    else:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Unsupported self-registration role: {request.role}. Supported: employee, supplier.",
        )


def create_account(db: Session, request: AccountCreateRequest) -> tuple[Account, str]:
    """Create a pending account and issue an invitation link for password setup."""
    account = Account(
        email=str(request.email),
        password_hash=hash_password(secrets.token_urlsafe(48)),
        role=request.role.value,
        is_active=False,
        is_verified=False,
        verification_status="PENDING",
    )
    accounts.add_account(db, account)
    invitation_link = account_link_service.create_invitation_token(db, account)
    try:
        db.commit()
    except IntegrityError as exc:
        db.rollback()
        raise HTTPException(
            status_code=409, detail="An account with this email already exists"
        ) from exc
    db.refresh(account)
    return account, invitation_link


def change_password(db: Session, account: Account, current: str, new: str) -> None:
    """Change the current account password and invalidate all prior sessions."""
    if not verify_password(current, account.password_hash):
        raise HTTPException(status_code=400, detail="Current password is incorrect")
    if current == new:
        raise HTTPException(
            status_code=422, detail="New password must differ from current password"
        )
    account.password_hash = hash_password(new)
    account.token_version += 1
    accounts.revoke_account_refresh_tokens(db, account.id, datetime.now(UTC))
    db.commit()


def create_initial_admin(db: Session, email: str, password: str) -> Account:
    """Create the first admin only; intended for the interactive CLI bootstrap."""
    if len(password) < 14 or len(password) > 128:
        raise ValueError("Admin password must be between 14 and 128 characters")
    try:
        email = str(TypeAdapter(EmailStr).validate_python(email)).strip().lower()
    except ValidationError as exc:
        raise ValueError("Enter a valid admin email address") from exc
    existing_admin = db.scalar(
        select(Account).where(Account.role == AccountRole.ADMIN.value).limit(1)
    )
    if existing_admin is not None:
        raise ValueError("An admin account already exists")
    account = Account(
        email=email.strip().lower(),
        password_hash=hash_password(password),
        role=AccountRole.ADMIN.value,
        is_active=True,
        is_verified=True,
        verification_status="VERIFIED",
    )
    accounts.add_account(db, account)
    try:
        db.commit()
    except IntegrityError as exc:
        db.rollback()
        raise ValueError("An account with this email already exists") from exc
    return account
