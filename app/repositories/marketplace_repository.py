"""Persistence operations for marketplace rentals and food supply orders."""

from uuid import UUID

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.models.marketplace import EquipmentRental, FoodSupplyOrder


# Equipment Rentals
def create_rental(db: Session, rental: EquipmentRental) -> EquipmentRental:
    db.add(rental)
    db.flush()
    return rental


def get_rental(db: Session, rental_id: UUID) -> EquipmentRental | None:
    return db.get(EquipmentRental, rental_id)


def list_rentals(
    db: Session, *, category: str | None = None, limit: int = 100, offset: int = 0
) -> list[EquipmentRental]:
    stmt = select(EquipmentRental).order_by(EquipmentRental.name)
    if category is not None:
        stmt = stmt.where(EquipmentRental.category == category)
    stmt = stmt.limit(limit).offset(offset)
    return list(db.scalars(stmt).all())


# Food Supply Orders
def create_food_order(db: Session, order: FoodSupplyOrder) -> FoodSupplyOrder:
    db.add(order)
    db.flush()
    return order


def get_food_order(db: Session, order_id: UUID) -> FoodSupplyOrder | None:
    return db.get(FoodSupplyOrder, order_id)


def list_food_orders(
    db: Session,
    *,
    site_id: UUID | None = None,
    status: str | None = None,
    limit: int = 100,
    offset: int = 0,
) -> list[FoodSupplyOrder]:
    stmt = select(FoodSupplyOrder).order_by(FoodSupplyOrder.delivery_date.desc())
    if site_id is not None:
        stmt = stmt.where(FoodSupplyOrder.site_id == site_id)
    if status is not None:
        stmt = stmt.where(FoodSupplyOrder.status == status)
    stmt = stmt.limit(limit).offset(offset)
    return list(db.scalars(stmt).all())
