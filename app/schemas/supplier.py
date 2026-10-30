"""Pydantic schemas for Supplier Management."""

from datetime import datetime
from uuid import UUID

from pydantic import BaseModel, ConfigDict, EmailStr, Field

from app.models.supplier import SupplierStatus


class SupplierCreate(BaseModel):
    """Schema for Admin registering a new Supplier."""

    email: EmailStr
    password: str = Field(..., min_length=4, max_length=128)
    company_name: str = Field(..., min_length=2, max_length=200)
    contact_person: str = Field(..., min_length=2, max_length=200)
    phone_number: str = Field(..., min_length=7, max_length=30)
    address: str = Field(..., min_length=5, max_length=500)
    company_registration_details: str = Field(..., min_length=3, max_length=200)
    materials_supplied: str = Field(..., min_length=2)
    bank_payment_info: str | None = None
    company_status: SupplierStatus = SupplierStatus.ACTIVE


class SupplierUpdate(BaseModel):
    """Schema for Admin updating a Supplier."""

    company_name: str | None = Field(None, min_length=2, max_length=200)
    contact_person: str | None = Field(None, min_length=2, max_length=200)
    phone_number: str | None = Field(None, min_length=7, max_length=30)
    email: EmailStr | None = None
    address: str | None = Field(None, min_length=5, max_length=500)
    company_registration_details: str | None = Field(None, min_length=3, max_length=200)
    materials_supplied: str | None = None
    bank_payment_info: str | None = None
    company_status: SupplierStatus | None = None


class SupplierSelfUpdate(BaseModel):
    """Schema for Supplier updating their own profile."""

    contact_person: str | None = Field(None, min_length=2, max_length=200)
    phone_number: str | None = Field(None, min_length=7, max_length=30)
    address: str | None = Field(None, min_length=5, max_length=500)
    materials_supplied: str | None = None
    bank_payment_info: str | None = None


class SupplierDetail(BaseModel):
    """Detailed supplier profile view."""

    id: UUID
    account_id: UUID
    company_name: str
    contact_person: str
    phone_number: str
    email: str
    address: str
    company_registration_details: str
    materials_supplied: str
    bank_payment_info: str | None = None
    company_status: str
    created_at: datetime
    updated_at: datetime

    model_config = ConfigDict(from_attributes=True)
