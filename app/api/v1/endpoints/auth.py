"""Authentication and account-management routes."""

from typing import Annotated
from uuid import UUID

from fastapi import APIRouter, BackgroundTasks, Depends, Response, status
from sqlalchemy.orm import Session

from app.controllers import auth_controller
from app.database.session import get_db
from app.models.account import Account, AccountRole
from app.schemas.auth import (
    AccountCreateRequest,
    AccountInvitationAccept,
    AccountResponse,
    EmployeeSignupRequest,
    LoginRequest,
    LogoutRequest,
    MessageResponse,
    PasswordChangeRequest,
    PasswordResetConfirm,
    PasswordResetRequest,
    ResendOTPRequest,
    SignupRequest,
    SignupResponse,
    SupplierSignupRequest,
    TokenRefreshRequest,
    TokenResponse,
    UserProfileResponse,
    VerifyOTPRequest,
    VerifyOTPResponse,
)
from app.security.dependencies import get_current_account, require_roles

router = APIRouter(prefix="/auth", tags=["authentication"])
DbSession = Annotated[Session, Depends(get_db)]
CurrentAccount = Annotated[Account, Depends(get_current_account)]
AdminAccount = Annotated[Account, Depends(require_roles(AccountRole.ADMIN))]


@router.post("/signup", response_model=SignupResponse, status_code=status.HTTP_201_CREATED)
def signup(request: SignupRequest, db: DbSession) -> SignupResponse:
    """Self-registration endpoint for both Employees and Suppliers."""
    return auth_controller.signup(db, request)


@router.post("/signup/employee", response_model=SignupResponse, status_code=status.HTTP_201_CREATED)
def signup_employee(request: EmployeeSignupRequest, db: DbSession) -> SignupResponse:
    """Self-registration endpoint for Employees / Site Leaders."""
    return auth_controller.signup_employee(db, request)


@router.post("/signup/supplier", response_model=SignupResponse, status_code=status.HTTP_201_CREATED)
def signup_supplier(request: SupplierSignupRequest, db: DbSession) -> SignupResponse:
    """Self-registration endpoint for Suppliers."""
    return auth_controller.signup_supplier(db, request)


@router.post("/verify-otp", response_model=VerifyOTPResponse)
def verify_otp(request: VerifyOTPRequest, db: DbSession) -> VerifyOTPResponse:
    """Verify 6-digit OTP to activate account and receive authentication tokens."""
    return auth_controller.verify_otp(db, request)


@router.post("/resend-otp", response_model=MessageResponse)
def resend_otp(request: ResendOTPRequest, db: DbSession) -> MessageResponse:
    """Resend a 6-digit verification code with rate-limit cooldown protection."""
    return auth_controller.resend_otp(db, request)


@router.post("/login", response_model=TokenResponse)
def login(request: LoginRequest, db: DbSession) -> TokenResponse:
    return auth_controller.login(db, request)


@router.post("/refresh", response_model=TokenResponse)
def refresh(request: TokenRefreshRequest, db: DbSession) -> TokenResponse:
    return auth_controller.refresh(db, request.refresh_token)


@router.post("/logout", status_code=status.HTTP_204_NO_CONTENT)
def logout(request: LogoutRequest, db: DbSession) -> Response:
    auth_controller.logout(db, request.refresh_token)
    return Response(status_code=status.HTTP_204_NO_CONTENT)


@router.get("/me", response_model=AccountResponse)
def me(account: CurrentAccount) -> AccountResponse:
    return auth_controller.current_account(account)


@router.get("/profile", response_model=UserProfileResponse)
def get_my_profile(account: CurrentAccount, db: DbSession) -> UserProfileResponse:
    """Return unified Flutter AppUser profile representation for authenticated user."""
    return auth_controller.current_profile(db, account)



@router.post("/users", response_model=AccountResponse, status_code=status.HTTP_201_CREATED)
def create_user(
    request: AccountCreateRequest,
    db: DbSession,
    background_tasks: BackgroundTasks,
    _: AdminAccount,
) -> AccountResponse:
    return auth_controller.create_account(db, request, background_tasks)


@router.post("/users/{account_id}/invitation", response_model=MessageResponse, status_code=202)
def resend_invitation(
    account_id: UUID,
    db: DbSession,
    background_tasks: BackgroundTasks,
    _: AdminAccount,
) -> MessageResponse:
    return auth_controller.resend_invitation(db, account_id, background_tasks)


@router.post("/invitations/accept", response_model=MessageResponse)
def accept_invitation(request: AccountInvitationAccept, db: DbSession) -> MessageResponse:
    return auth_controller.accept_invitation(db, request.token, request.new_password)


@router.post("/password", response_model=MessageResponse)
def change_password(
    request: PasswordChangeRequest, db: DbSession, account: CurrentAccount
) -> MessageResponse:
    return auth_controller.change_password(db, account, request)


@router.post("/password-reset/request", response_model=MessageResponse, status_code=202)
def request_password_reset(
    request: PasswordResetRequest, db: DbSession, background_tasks: BackgroundTasks
) -> MessageResponse:
    return auth_controller.request_password_reset(db, str(request.email), background_tasks)


@router.post("/password-reset/confirm", response_model=MessageResponse)
def confirm_password_reset(request: PasswordResetConfirm, db: DbSession) -> MessageResponse:
    return auth_controller.confirm_password_reset(db, request.token, request.new_password)
