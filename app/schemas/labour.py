"""Pydantic schemas for Labour Management."""

from datetime import date, datetime
from uuid import UUID

from pydantic import BaseModel, ConfigDict, EmailStr, Field

from app.models.labour import LabourStatus
from app.schemas.site import SitePublic


class LabourCreate(BaseModel):
    """Schema for Admin registering a new Labourer."""

    email: EmailStr
    password: str = Field(..., min_length=4, max_length=128)
    full_name: str = Field(..., min_length=2, max_length=200)
    profile_photo: str | None = None
    nic_number: str = Field(..., min_length=5, max_length=50)
    phone_number: str = Field(..., min_length=7, max_length=30)
    address: str = Field(..., min_length=5, max_length=500)
    job_role: str = Field(..., min_length=2, max_length=100)
    skills: str = Field(..., min_length=2)
    experience_years: int = Field(default=0, ge=0)
    joining_date: date
    emergency_contact: str = Field(..., min_length=5, max_length=200)
    current_site_id: UUID | None = None
    status: LabourStatus = LabourStatus.ACTIVE
    daily_wage: float = 3500.0
    has_attended_today: bool = True


class LabourUpdate(BaseModel):
    """Admin update schema for labourer profile."""

    full_name: str | None = Field(None, min_length=2, max_length=200)
    profile_photo: str | None = None
    nic_number: str | None = Field(None, min_length=5, max_length=50)
    phone_number: str | None = Field(None, min_length=7, max_length=30)
    address: str | None = Field(None, min_length=5, max_length=500)
    job_role: str | None = Field(None, min_length=2, max_length=100)
    skills: str | None = None
    experience_years: int | None = Field(None, ge=0)
    joining_date: date | None = None
    emergency_contact: str | None = Field(None, min_length=5, max_length=200)
    current_site_id: UUID | None = None
    status: LabourStatus | None = None
    daily_wage: float | None = None
    has_attended_today: bool | None = None


class LabourSelfUpdate(BaseModel):
    """Self-update schema for logged-in Labourer."""

    phone_number: str | None = Field(None, min_length=7, max_length=30)
    address: str | None = Field(None, min_length=5, max_length=500)
    profile_photo: str | None = None
    emergency_contact: str | None = Field(None, min_length=5, max_length=200)
    job_role: str | None = Field(None, min_length=2, max_length=100)
    skills: str | None = None
    experience_years: int | None = Field(None, ge=0)
    daily_wage: float | None = None


class LabourAssignSite(BaseModel):
    """Schema for assigning or reassigning labourer to a site."""

    site_id: UUID | None = Field(..., description="Site UUID to assign, or null to unassign")


class LabourDetail(BaseModel):
    """Detailed labour profile view."""

    id: UUID
    account_id: UUID
    full_name: str
    profile_photo: str | None = None
    nic_number: str
    phone_number: str
    address: str
    job_role: str
    skills: str
    experience_years: int
    joining_date: date
    emergency_contact: str
    status: str
    daily_wage: float = 3500.0
    has_attended_today: bool = True
    current_site_id: UUID | None = None
    current_site: SitePublic | None = None
    created_at: datetime
    updated_at: datetime

    model_config = ConfigDict(from_attributes=True)

