"""Marketplace equipment rental and food supply order persistence models."""

from datetime import UTC, date, datetime
from decimal import Decimal
from typing import TYPE_CHECKING
from uuid import UUID, uuid4

from sqlalchemy import Date, DateTime, ForeignKey, Integer, Numeric, String, Uuid
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.models.base import Base

if TYPE_CHECKING:
    from app.models.site import ConstructionSite


class EquipmentRental(Base):
    """Heavy machinery or tool rental catalog item."""

    __tablename__ = "equipment_rentals"

    id: Mapped[UUID] = mapped_column(Uuid(as_uuid=True), primary_key=True, default=uuid4)
    name: Mapped[str] = mapped_column(String(200), nullable=False)
    category: Mapped[str] = mapped_column(String(100), nullable=False, index=True)
    daily_rate: Mapped[Decimal] = mapped_column(Numeric(12, 2), nullable=False)
    available_stock: Mapped[int] = mapped_column(Integer, default=0, nullable=False)
    on_rental_count: Mapped[int] = mapped_column(Integer, default=0, nullable=False)
    image_url: Mapped[str | None] = mapped_column(String(500), nullable=True)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=lambda: datetime.now(UTC), nullable=False
    )


class FoodSupplyOrder(Base):
    """Catering and meal supply order for a construction site workforce."""

    __tablename__ = "food_supply_orders"

    id: Mapped[UUID] = mapped_column(Uuid(as_uuid=True), primary_key=True, default=uuid4)
    site_id: Mapped[UUID] = mapped_column(
        Uuid(as_uuid=True),
        ForeignKey("construction_sites.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    meal_type: Mapped[str] = mapped_column(String(50), nullable=False)
    portions: Mapped[int] = mapped_column(Integer, nullable=False)
    delivery_date: Mapped[date] = mapped_column(Date, nullable=False)
    delivery_time: Mapped[str] = mapped_column(String(50), nullable=False)
    status: Mapped[str] = mapped_column(String(50), default="Pending", nullable=False, index=True)
    total_cost: Mapped[Decimal] = mapped_column(Numeric(12, 2), nullable=False)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=lambda: datetime.now(UTC), nullable=False
    )

    # Relationships
    site: Mapped["ConstructionSite"] = relationship(
        "ConstructionSite", back_populates="food_orders"
    )
