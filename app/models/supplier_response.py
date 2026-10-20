"""Supplier material response / quotation persistence model."""

from datetime import UTC, date, datetime
from decimal import Decimal
from enum import StrEnum
from typing import TYPE_CHECKING
from uuid import UUID, uuid4

from sqlalchemy import Date, DateTime, ForeignKey, Numeric, String, Text, Uuid
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.models.base import Base

if TYPE_CHECKING:
    from app.models.material_request import MaterialRequest
    from app.models.supplier import SupplierProfile


class AvailabilityStatus(StrEnum):
    """Supplier material availability."""

    AVAILABLE = "Available"
    PARTIAL = "Partial"
    UNAVAILABLE = "Unavailable"


class ResponseStatus(StrEnum):
    """Admin review status of quotation."""

    SUBMITTED = "Submitted"
    ACCEPTED = "Accepted"
    REJECTED = "Rejected"


class SupplierResponse(Base):
    """Quotation submitted by a supplier for a material request."""

    __tablename__ = "supplier_responses"

    id: Mapped[UUID] = mapped_column(Uuid(as_uuid=True), primary_key=True, default=uuid4)
    request_id: Mapped[UUID] = mapped_column(
        Uuid(as_uuid=True),
        ForeignKey("material_requests.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    supplier_id: Mapped[UUID] = mapped_column(
        Uuid(as_uuid=True),
        ForeignKey("supplier_profiles.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )

    available_quantity: Mapped[Decimal] = mapped_column(Numeric(12, 2), nullable=False)
    unit_price: Mapped[Decimal] = mapped_column(Numeric(12, 2), nullable=False)
    total_price: Mapped[Decimal] = mapped_column(Numeric(14, 2), nullable=False)
    delivery_date: Mapped[date] = mapped_column(Date, nullable=False)
    delivery_details: Mapped[str | None] = mapped_column(Text, nullable=True)
    availability_status: Mapped[str] = mapped_column(
        String(20), default=AvailabilityStatus.AVAILABLE.value, nullable=False
    )
    additional_notes: Mapped[str | None] = mapped_column(Text, nullable=True)
    submission_date: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=lambda: datetime.now(UTC), nullable=False
    )
    status: Mapped[str] = mapped_column(
        String(20), default=ResponseStatus.SUBMITTED.value, nullable=False, index=True
    )
    reviewed_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)

    # Relationships
    request: Mapped["MaterialRequest"] = relationship(
        "MaterialRequest", back_populates="supplier_responses"
    )
    supplier: Mapped["SupplierProfile"] = relationship(
        "SupplierProfile", back_populates="responses"
    )
