"""Pydantic schemas for Construction Sites."""

from datetime import date, datetime
from uuid import UUID

from pydantic import BaseModel, ConfigDict, Field

from app.models.site import SiteStatus


class SiteBase(BaseModel):
    site_name: str = Field(..., min_length=2, max_length=200)
    project_name: str = Field(..., min_length=2, max_length=200)
    site_address: str = Field(..., min_length=5, max_length=500)
    client_name: str = Field(..., min_length=2, max_length=200)
    start_date: date
    expected_completion_date: date
    status: SiteStatus = SiteStatus.ACTIVE
    description: str | None = None
    progress: float = 0.0
    contract_value: str | None = None
    cost_spent: str | None = None
    margin: float = 0.0
    labour_count: str | None = None
    image_url: str | None = None
    supervisor_name: str | None = None
    supervisor_phone: str | None = None
    stages: list[str] | None = None


class SiteCreate(SiteBase):
    pass


class SiteUpdate(BaseModel):
    site_name: str | None = Field(None, min_length=2, max_length=200)
    project_name: str | None = Field(None, min_length=2, max_length=200)
    site_address: str | None = Field(None, min_length=5, max_length=500)
    client_name: str | None = Field(None, min_length=2, max_length=200)
    start_date: date | None = None
    expected_completion_date: date | None = None
    status: SiteStatus | None = None
    description: str | None = None
    progress: float | None = None
    contract_value: str | None = None
    cost_spent: str | None = None
    margin: float | None = None
    labour_count: str | None = None
    image_url: str | None = None
    supervisor_name: str | None = None
    supervisor_phone: str | None = None
    stages: list[str] | None = None


class SitePublic(SiteBase):
    """Basic site info visible to assigned Labour."""

    id: UUID
    status: str

    model_config = ConfigDict(from_attributes=True)


class SiteDetail(SiteBase):
    """Detailed site info with metadata and assigned workers count."""

    id: UUID
    status: str
    assigned_labourer_count: int = 0
    assigned_labour_ids: list[str] = []
    created_at: datetime
    updated_at: datetime

    model_config = ConfigDict(from_attributes=True)

