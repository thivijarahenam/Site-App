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
    UserProfileResponse,
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
    """Authenticate by email or phone number and issue access and refresh tokens."""
    now = datetime.now(UTC)
    account = accounts.get_account_by_identifier(db, str(request.email), for_update=True)
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


def get_unified_user_profile(db: Session, account: Account) -> UserProfileResponse:
    """Return unified AppUser representation matching frontend data model."""
    user_name = account.email.split("@")[0].replace(".", " ").title()
    phone = ""
    address = None
    job_role = None
    skills: list[str] = []
    experience = None
    daily_wage: float | None = None
    linked_id = None
    avatar_url = None
    company_name = "Ahenam Technologies"
    materials_supplied: list[str] = []
    is_profile_incomplete = False

    if account.role in {
        AccountRole.LABOUR.value,
        AccountRole.EMPLOYEE.value,
        AccountRole.SUPERVISOR.value,
        AccountRole.ADMIN.value,
    }:
        labour = db.scalar(select(LabourProfile).where(LabourProfile.account_id == account.id))
        if labour is not None:
            user_name = labour.full_name
            phone = labour.phone_number
            address = labour.address
            job_role = labour.job_role
            if labour.skills:
                skills = [s.strip() for s in labour.skills.split(",") if s.strip()]
            experience = f"{labour.experience_years} years"
            daily_wage = labour.daily_wage
            linked_id = str(labour.id)
            avatar_url = labour.profile_photo
            if (not labour.skills or labour.skills == "General Site Work") and account.role != AccountRole.ADMIN.value:
                is_profile_incomplete = True
        else:
            if account.role != AccountRole.ADMIN.value:
                is_profile_incomplete = True

    elif account.role in {AccountRole.SUPPLIER.value, AccountRole.FOOD_SUPPLIER.value}:
        supplier = db.scalar(select(SupplierProfile).where(SupplierProfile.account_id == account.id))
        if supplier is not None:
            user_name = supplier.contact_person
            phone = supplier.phone_number
            address = supplier.address
            company_name = supplier.company_name
            if supplier.materials_supplied:
                materials_supplied = [m.strip() for m in supplier.materials_supplied.split(",") if m.strip()]
            linked_id = str(supplier.id)
            if not supplier.materials_supplied:
                is_profile_incomplete = True
        else:
            is_profile_incomplete = True

    return UserProfileResponse(
        id=f"u-{account.id}",
        name=user_name,
        email=account.email,
        phone=phone,
        role=account.role,
        linked_id=linked_id,
        avatar_url=avatar_url,
        company_name=company_name,
        is_profile_incomplete=is_profile_incomplete,
        address=address,
        experience=experience,
        skills=skills,
        daily_wage=daily_wage,
        materials_supplied=materials_supplied,
    )


def signup(db: Session, request: SignupRequest) -> tuple[Account, str]:
    """Unified self-registration handler dispatching all frontend roles."""
    norm_email = str(request.email).strip().lower()
    existing = accounts.get_account_by_email(db, norm_email)
    if existing is not None:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="An account with this email already exists",
        )

    # Resolve full name
    full_name = request.full_name or f"{request.first_name or ''} {request.last_name or ''}".strip()
    if not full_name:
        full_name = norm_email.split("@")[0].title()

    # Normalize skills and materials
    skills_str: str | None = None
    if isinstance(request.skills, list):
        skills_str = ", ".join(request.skills)
    elif isinstance(request.skills, str):
        skills_str = request.skills

    materials_str: str | None = None
    if isinstance(request.materials_supplied, list):
        materials_str = ", ".join(request.materials_supplied)
    elif isinstance(request.materials_supplied, str):
        materials_str = request.materials_supplied

    role_val = request.role
    if role_val == "labour" or role_val == "employee":
        target_role = AccountRole.LABOUR.value
    elif role_val == "supervisor":
        target_role = AccountRole.SUPERVISOR.value
    elif role_val == "supplier":
        target_role = AccountRole.SUPPLIER.value
    elif role_val == "foodSupplier":
        target_role = AccountRole.FOOD_SUPPLIER.value
    elif role_val == "admin":
        target_role = AccountRole.ADMIN.value
    else:
        target_role = role_val

    account = Account(
        email=norm_email,
        password_hash=hash_password(request.password),
        role=target_role,
        is_active=False,
        is_verified=False,
        verification_status="PENDING",
    )
    accounts.add_account(db, account)

    # Create associated profile
    if target_role in {AccountRole.LABOUR.value, AccountRole.EMPLOYEE.value, AccountRole.SUPERVISOR.value}:
        exp_years = request.experience_years or 0
        if not exp_years and request.experience:
            digits = "".join(c for c in request.experience if c.isdigit())
            exp_years = int(digits) if digits else 0

        profile = LabourProfile(
            account_id=account.id,
            first_name=request.first_name or full_name.split()[0],
            last_name=request.last_name or (full_name.split()[-1] if len(full_name.split()) > 1 else ""),
            full_name=full_name,
            phone_number=request.phone_number,
            address=request.address,
            job_role=request.job_role or ("Site Supervisor" if target_role == AccountRole.SUPERVISOR.value else "General Worker"),
            nic_number=request.nic_number or f"NIC-{account.id.hex[:8].upper()}",
            skills=skills_str or "General Construction",
            experience_years=exp_years,
            daily_wage=request.daily_wage or 3500.0,
            has_attended_today=True,
            emergency_contact=request.emergency_contact or request.phone_number,
            status="Active",
        )
        db.add(profile)

    elif target_role in {AccountRole.SUPPLIER.value, AccountRole.FOOD_SUPPLIER.value}:
        company_name = request.company_name or f"{full_name} Supplies"
        profile_supp = SupplierProfile(
            account_id=account.id,
            first_name=request.first_name or full_name.split()[0],
            last_name=request.last_name or (full_name.split()[-1] if len(full_name.split()) > 1 else ""),
            company_name=company_name,
            contact_person=full_name,
            phone_number=request.phone_number,
            email=norm_email,
            address=request.address,
            company_registration_details=request.company_registration_details or "Registered Supplier",
            materials_supplied=materials_str or ("Catering and Meals" if target_role == AccountRole.FOOD_SUPPLIER.value else "Building Materials"),
            bank_payment_info=request.bank_payment_info or "Commercial Bank - Verified",
            company_status="Active",
        )
        db.add(profile_supp)

    try:
        db.commit()
    except IntegrityError as exc:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="A conflict occurred during registration profile creation",
        ) from exc

    db.refresh(account)
    otp_code = otp_service.create_and_send_registration_otp(db, account)
    return account, otp_code



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
