"""Supplier profile persistence model."""

from datetime import UTC, datetime
from enum import StrEnum
from typing import TYPE_CHECKING
from uuid import UUID, uuid4

from sqlalchemy import DateTime, ForeignKey, String, Text, Uuid
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.models.base import Base

if TYPE_CHECKING:
    from app.models.account import Account
    from app.models.supplier_response import SupplierResponse


class SupplierStatus(StrEnum):
    """Possible statuses for a supplier."""

    ACTIVE = "Active"
    INACTIVE = "Inactive"


class SupplierProfile(Base):
    """Supplier company profile managed by Admin and Supplier."""

    __tablename__ = "supplier_profiles"

    id: Mapped[UUID] = mapped_column(Uuid(as_uuid=True), primary_key=True, default=uuid4)
    account_id: Mapped[UUID] = mapped_column(
        Uuid(as_uuid=True),
        ForeignKey("accounts.id", ondelete="CASCADE"),
        unique=True,
        nullable=False,
        index=True,
    )

    first_name: Mapped[str | None] = mapped_column(String(100), nullable=True)
    last_name: Mapped[str | None] = mapped_column(String(100), nullable=True)
    company_name: Mapped[str] = mapped_column(String(200), nullable=False, index=True)
    contact_person: Mapped[str] = mapped_column(String(200), nullable=False)
    phone_number: Mapped[str] = mapped_column(String(30), nullable=False)
    email: Mapped[str] = mapped_column(String(254), nullable=False)
    address: Mapped[str] = mapped_column(String(500), nullable=False)
    company_registration_details: Mapped[str | None] = mapped_column(String(200), nullable=True)
    materials_supplied: Mapped[str | None] = mapped_column(Text, nullable=True)
    bank_payment_info: Mapped[str | None] = mapped_column(Text, nullable=True)
    company_status: Mapped[str] = mapped_column(
        String(20), default=SupplierStatus.ACTIVE.value, nullable=False, index=True
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
    account: Mapped["Account"] = relationship("Account")
    responses: Mapped[list["SupplierResponse"]] = relationship(
        "SupplierResponse", back_populates="supplier", cascade="all, delete-orphan"
    )
