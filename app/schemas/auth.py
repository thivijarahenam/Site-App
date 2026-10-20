"""Authentication request and response schemas."""

from datetime import datetime
from typing import Literal
from uuid import UUID

from pydantic import BaseModel, ConfigDict, EmailStr, Field, field_validator

from app.models.account import AccountRole


class LoginRequest(BaseModel):
    email: EmailStr
    password: str = Field(min_length=8, max_length=128)

    @field_validator("email")
    @classmethod
    def normalize_email(cls, value: EmailStr) -> str:
        return str(value).strip().lower()


class TokenRefreshRequest(BaseModel):
    refresh_token: str = Field(min_length=40, max_length=256)


class LogoutRequest(BaseModel):
    refresh_token: str = Field(min_length=40, max_length=256)


class TokenResponse(BaseModel):
    access_token: str
    token_type: Literal["bearer"] = "bearer"
    expires_in: int
    refresh_token: str


class AccountResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    email: EmailStr
    role: str
    is_active: bool
    is_verified: bool = False
    verification_status: str = "PENDING"
    created_at: datetime


class AccountCreateRequest(BaseModel):
    model_config = ConfigDict(extra="forbid")

    email: EmailStr
    role: AccountRole

    @field_validator("email")
    @classmethod
    def normalize_email(cls, value: EmailStr) -> str:
        return str(value).strip().lower()


class EmployeeSignupRequest(BaseModel):
    """Self-registration request for Employees / Site Leaders."""

    email: EmailStr
    password: str = Field(min_length=8, max_length=128)
    first_name: str = Field(min_length=1, max_length=100)
    last_name: str = Field(min_length=1, max_length=100)
    phone_number: str = Field(min_length=7, max_length=30)
    address: str = Field(min_length=3, max_length=500)
    job_role: str = Field(default="Employee / Leader", max_length=100)
    nic_number: str | None = Field(None, max_length=50)
    skills: str | None = None
    experience_years: int = Field(default=0, ge=0)

    @field_validator("email")
    @classmethod
    def normalize_email(cls, value: EmailStr) -> str:
        return str(value).strip().lower()


class SupplierSignupRequest(BaseModel):
    """Self-registration request for Suppliers."""

    email: EmailStr
    password: str = Field(min_length=8, max_length=128)
    first_name: str = Field(min_length=1, max_length=100)
    last_name: str = Field(min_length=1, max_length=100)
    phone_number: str = Field(min_length=7, max_length=30)
    address: str = Field(min_length=3, max_length=500)
    company_name: str | None = Field(None, max_length=200)
    company_registration_details: str | None = Field(None, max_length=200)
    materials_supplied: str | None = None
    bank_payment_info: str | None = None

    @field_validator("email")
    @classmethod
    def normalize_email(cls, value: EmailStr) -> str:
        return str(value).strip().lower()


class SignupRequest(BaseModel):
    """Unified self-registration request for both Employees and Suppliers."""

    role: Literal["employee", "labour", "supplier"]
    email: EmailStr
    password: str = Field(min_length=8, max_length=128)
    first_name: str = Field(min_length=1, max_length=100)
    last_name: str = Field(min_length=1, max_length=100)
    phone_number: str = Field(min_length=7, max_length=30)
    address: str = Field(min_length=3, max_length=500)

    # Optional role-specific fields
    job_role: str | None = Field(None, max_length=100)
    nic_number: str | None = Field(None, max_length=50)
    skills: str | None = None
    experience_years: int | None = Field(None, ge=0)
    company_name: str | None = Field(None, max_length=200)
    company_registration_details: str | None = Field(None, max_length=200)
    materials_supplied: str | None = None
    bank_payment_info: str | None = None

    @field_validator("email")
    @classmethod
    def normalize_email(cls, value: EmailStr) -> str:
        return str(value).strip().lower()


class SignupResponse(BaseModel):
    """Response returned upon successful self-registration."""

    message: str
    account_id: UUID
    email: str
    role: str
    verification_status: str


class VerifyOTPRequest(BaseModel):
    """Request to verify 6-digit OTP code."""

    email: EmailStr
    otp: str = Field(min_length=6, max_length=6, pattern=r"^\d{6}$")

    @field_validator("email")
    @classmethod
    def normalize_email(cls, value: EmailStr) -> str:
        return str(value).strip().lower()


class VerifyOTPResponse(BaseModel):
    """Response returned upon successful OTP verification."""

    message: str
    account: AccountResponse
    tokens: TokenResponse | None = None


class ResendOTPRequest(BaseModel):
    """Request to generate and resend verification OTP."""

    email: EmailStr

    @field_validator("email")
    @classmethod
    def normalize_email(cls, value: EmailStr) -> str:
        return str(value).strip().lower()


class PasswordChangeRequest(BaseModel):
    current_password: str = Field(min_length=1, max_length=128)
    new_password: str = Field(min_length=8, max_length=128)


class MessageResponse(BaseModel):
    message: str


class PasswordResetRequest(BaseModel):
    email: EmailStr

    @field_validator("email")
    @classmethod
    def normalize_email(cls, value: EmailStr) -> str:
        return str(value).strip().lower()


class PasswordResetConfirm(BaseModel):
    token: str = Field(min_length=32, max_length=256)
    new_password: str = Field(min_length=8, max_length=128)


class AccountInvitationAccept(BaseModel):
    token: str = Field(min_length=32, max_length=256)
    new_password: str = Field(min_length=8, max_length=128)
