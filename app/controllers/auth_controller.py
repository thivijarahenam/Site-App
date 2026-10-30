"""Thin HTTP controllers for authentication routes."""

from uuid import UUID

from fastapi import BackgroundTasks
from sqlalchemy.orm import Session

from app.models.account import Account
from app.schemas.auth import (
    AccountCreateRequest,
    AccountResponse,
    EmployeeSignupRequest,
    LoginRequest,
    MessageResponse,
    PasswordChangeRequest,
    ResendOTPRequest,
    SignupRequest,
    SignupResponse,
    SupplierSignupRequest,
    TokenResponse,
    UserProfileResponse,
    VerifyOTPRequest,
    VerifyOTPResponse,
)
from app.services import account_link_service, auth_service, otp_service


def login(db: Session, request: LoginRequest) -> TokenResponse:
    return auth_service.login(db, request)


def refresh(db: Session, raw_refresh_token: str) -> TokenResponse:
    return auth_service.refresh(db, raw_refresh_token)


def logout(db: Session, raw_refresh_token: str) -> MessageResponse:
    auth_service.logout(db, raw_refresh_token)
    return MessageResponse(message="Logged out")


def current_account(account: Account) -> AccountResponse:
    return AccountResponse.model_validate(account)


def current_profile(db: Session, account: Account) -> UserProfileResponse:
    return auth_service.get_unified_user_profile(db, account)


def signup(db: Session, request: SignupRequest) -> SignupResponse:
    account, _ = auth_service.signup(db, request)
    profile = auth_service.get_unified_user_profile(db, account)
    return SignupResponse(
        message="Registration successful. A 6-digit verification code has been sent to your email.",
        account_id=account.id,
        email=account.email,
        role=account.role,
        verification_status=account.verification_status,
        user_profile=profile,
    )


def signup_employee(db: Session, request: EmployeeSignupRequest) -> SignupResponse:
    account, _ = auth_service.signup_employee(db, request)
    return SignupResponse(
        message="Registration successful. A 6-digit verification code has been sent to your email.",
        account_id=account.id,
        email=account.email,
        role=account.role,
        verification_status=account.verification_status,
    )


def signup_supplier(db: Session, request: SupplierSignupRequest) -> SignupResponse:
    account, _ = auth_service.signup_supplier(db, request)
    return SignupResponse(
        message="Registration successful. A 6-digit verification code has been sent to your email.",
        account_id=account.id,
        email=account.email,
        role=account.role,
        verification_status=account.verification_status,
    )


def verify_otp(db: Session, request: VerifyOTPRequest) -> VerifyOTPResponse:
    account = otp_service.verify_registration_otp(db, str(request.email), request.otp)
    tokens = auth_service._token_pair(db, account)
    return VerifyOTPResponse(
        message="Account verified successfully.",
        account=AccountResponse.model_validate(account),
        tokens=tokens,
    )


def resend_otp(db: Session, request: ResendOTPRequest) -> MessageResponse:
    otp_service.resend_registration_otp(db, str(request.email))
    return MessageResponse(
        message="If an unverified account exists for that email, a new verification code has been sent."
    )


def create_account(
    db: Session, request: AccountCreateRequest, background_tasks: BackgroundTasks
) -> AccountResponse:
    account, link = auth_service.create_account(db, request)
    background_tasks.add_task(
        account_link_service.deliver_invitation, account.email, account.role, link
    )
    return AccountResponse.model_validate(account)


def resend_invitation(
    db: Session, account_id: UUID, background_tasks: BackgroundTasks
) -> MessageResponse:
    delivery = account_link_service.resend_invitation(db, account_id)
    if delivery is not None:
        background_tasks.add_task(account_link_service.deliver_invitation, *delivery)
    return MessageResponse(message="If the account is awaiting setup, an invitation will be sent.")


def accept_invitation(db: Session, token: str, new_password: str) -> MessageResponse:
    account_link_service.consume_link(db, token, account_link_service.INVITATION, new_password)
    return MessageResponse(message="Account setup complete; sign in with your email and password.")


def change_password(
    db: Session, account: Account, request: PasswordChangeRequest
) -> MessageResponse:
    auth_service.change_password(db, account, request.current_password, request.new_password)
    return MessageResponse(message="Password changed; sign in again")


def request_password_reset(
    db: Session, email: str, background_tasks: BackgroundTasks
) -> MessageResponse:
    delivery = account_link_service.request_password_reset(db, email)
    if delivery is not None:
        background_tasks.add_task(account_link_service.deliver_password_reset, *delivery)
    return MessageResponse(
        message="If an active account exists for that email, a password reset link will be sent."
    )


def confirm_password_reset(db: Session, token: str, new_password: str) -> MessageResponse:
    account_link_service.consume_link(db, token, account_link_service.PASSWORD_RESET, new_password)
    return MessageResponse(message="Password reset successfully; sign in again")
