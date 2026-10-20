"""Material request persistence model."""

from datetime import UTC, date, datetime
from decimal import Decimal
from enum import StrEnum
from typing import TYPE_CHECKING
from uuid import UUID, uuid4

from sqlalchemy import Date, DateTime, ForeignKey, Numeric, String, Text, Uuid
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.models.base import Base

if TYPE_CHECKING:
    from app.models.site import ConstructionSite
    from app.models.supplier_response import SupplierResponse


class MaterialRequestStatus(StrEnum):
    """Possible statuses for a material request."""

    PENDING = "Pending"
    RESPONDED = "Responded"
    APPROVED = "Approved"
    COMPLETED = "Completed"
    CANCELLED = "Cancelled"


class MaterialRequest(Base):
    """Material request originating from construction site needs."""

    __tablename__ = "material_requests"

    id: Mapped[UUID] = mapped_column(Uuid(as_uuid=True), primary_key=True, default=uuid4)
    site_id: Mapped[UUID] = mapped_column(
        Uuid(as_uuid=True),
        ForeignKey("construction_sites.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )

    material_name: Mapped[str] = mapped_column(String(200), nullable=False, index=True)
    material_category: Mapped[str] = mapped_column(String(100), nullable=False, index=True)
    required_quantity: Mapped[Decimal] = mapped_column(Numeric(12, 2), nullable=False)
    unit: Mapped[str] = mapped_column(String(50), nullable=False)
    required_date: Mapped[date] = mapped_column(Date, nullable=False)
    description: Mapped[str | None] = mapped_column(Text, nullable=True)
    additional_notes: Mapped[str | None] = mapped_column(Text, nullable=True)
    request_date: Mapped[date] = mapped_column(Date, default=date.today, nullable=False)
    status: Mapped[str] = mapped_column(
        String(20), default=MaterialRequestStatus.PENDING.value, nullable=False, index=True
    )
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
    site: Mapped["ConstructionSite"] = relationship(
        "ConstructionSite", back_populates="material_requests"
    )
    supplier_responses: Mapped[list["SupplierResponse"]] = relationship(
        "SupplierResponse", back_populates="request", cascade="all, delete-orphan"
    )
