"""Pydantic schemas for Supplier Quotation Responses."""

from datetime import date, datetime
from decimal import Decimal
from uuid import UUID

from pydantic import BaseModel, ConfigDict, Field

from app.models.supplier_response import AvailabilityStatus, ResponseStatus
from app.schemas.supplier import SupplierDetail


class SupplierResponseCreate(BaseModel):
    """Schema for Supplier submitting quotation."""

    available_quantity: Decimal = Field(..., gt=0)
    unit_price: Decimal = Field(..., gt=0)
    total_price: Decimal = Field(..., gt=0)
    delivery_date: date
    delivery_details: str | None = None
    availability_status: AvailabilityStatus = AvailabilityStatus.AVAILABLE
    additional_notes: str | None = None


class SupplierResponseDetail(BaseModel):
    """Quotation details returned to Admin or submitting Supplier."""

    id: UUID
    request_id: UUID
    supplier_id: UUID
    available_quantity: Decimal
    unit_price: Decimal
    total_price: Decimal
    delivery_date: date
    delivery_details: str | None = None
    availability_status: str
    additional_notes: str | None = None
    submission_date: datetime
    status: str
    reviewed_at: datetime | None = None
    supplier: SupplierDetail | None = None

    model_config = ConfigDict(from_attributes=True)


class ReviewResponseAction(BaseModel):
    """Admin review action on a supplier response."""

    action: ResponseStatus = Field(
        ..., description="ACCEPTED to approve response, REJECTED to reject"
    )
    admin_notes: str | None = None
