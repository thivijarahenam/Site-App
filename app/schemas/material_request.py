"""Pydantic schemas for Material Requests."""

from datetime import date, datetime
from decimal import Decimal
from uuid import UUID

from pydantic import BaseModel, ConfigDict, Field

from app.models.material_request import MaterialRequestStatus
from app.schemas.site import SitePublic
from app.schemas.supplier import SupplierDetail


class MaterialRequestCreate(BaseModel):
    """Schema for Admin creating a material request."""

    site_id: UUID
    material_name: str = Field(..., min_length=2, max_length=200)
    material_category: str = Field(..., min_length=2, max_length=100)
    required_quantity: Decimal = Field(..., gt=0)
    unit: str = Field(..., min_length=1, max_length=50)
    required_date: date
    description: str | None = None
    additional_notes: str | None = None
    assigned_supplier_id: UUID | None = None


class MaterialRequestUpdate(BaseModel):
    """Schema for updating a material request."""

    material_name: str | None = Field(None, min_length=2, max_length=200)
    material_category: str | None = Field(None, min_length=2, max_length=100)
    required_quantity: Decimal | None = Field(None, gt=0)
    unit: str | None = Field(None, min_length=1, max_length=50)
    required_date: date | None = None
    description: str | None = None
    additional_notes: str | None = None
    status: MaterialRequestStatus | None = None
    assigned_supplier_id: UUID | None = None


class MaterialRequestDetail(BaseModel):
    """Full detail of material request."""

    id: UUID
    site_id: UUID
    material_name: str
    material_category: str
    required_quantity: Decimal
    unit: str
    required_date: date
    description: str | None = None
    additional_notes: str | None = None
    request_date: date
    status: str
    assigned_supplier_id: UUID | None = None
    created_at: datetime
    updated_at: datetime
    site: SitePublic | None = None
    assigned_supplier: SupplierDetail | None = None
    response_count: int = 0

    model_config = ConfigDict(from_attributes=True)
