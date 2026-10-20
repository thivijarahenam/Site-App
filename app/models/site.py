"""Construction site persistence model."""

from datetime import UTC, date, datetime
from enum import StrEnum
from typing import TYPE_CHECKING
from uuid import UUID, uuid4

from sqlalchemy import Date, DateTime, String, Text, Uuid
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.models.base import Base

if TYPE_CHECKING:
    from app.models.labour import LabourProfile
    from app.models.material_request import MaterialRequest


class SiteStatus(StrEnum):
    """Possible statuses for a construction site."""

    ACTIVE = "Active"
    COMPLETED = "Completed"
    ON_HOLD = "On Hold"


class ConstructionSite(Base):
    """Construction site managed by admins."""

    __tablename__ = "construction_sites"

    id: Mapped[UUID] = mapped_column(Uuid(as_uuid=True), primary_key=True, default=uuid4)
    site_name: Mapped[str] = mapped_column(String(200), nullable=False, index=True)
    project_name: Mapped[str] = mapped_column(String(200), nullable=False, index=True)
    site_address: Mapped[str] = mapped_column(String(500), nullable=False)
    client_name: Mapped[str] = mapped_column(String(200), nullable=False)
    start_date: Mapped[date] = mapped_column(Date, nullable=False)
    expected_completion_date: Mapped[date] = mapped_column(Date, nullable=False)
    status: Mapped[str] = mapped_column(
        String(20), default=SiteStatus.ACTIVE.value, nullable=False, index=True
    )
    description: Mapped[str | None] = mapped_column(Text, nullable=True)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=lambda: datetime.now(UTC), nullable=False
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        default=lambda: datetime.now(UTC),
        onupdate=lambda: datetime.now(UTC),
        nullable=False,
    )

    # Relationships
    assigned_labourers: Mapped[list["LabourProfile"]] = relationship(
        "LabourProfile", back_populates="current_site"
    )
    material_requests: Mapped[list["MaterialRequest"]] = relationship(
        "MaterialRequest", back_populates="site", cascade="all, delete-orphan"
    )
