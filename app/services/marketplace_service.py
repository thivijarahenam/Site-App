"""Marketplace services for equipment rentals and food supply orders."""

from uuid import UUID

from fastapi import HTTPException, status
from sqlalchemy.orm import Session

from app.models.marketplace import EquipmentRental, FoodSupplyOrder
from app.repositories import marketplace_repository as repo
from app.repositories.site_repository import get_site
from app.schemas.marketplace import (
    EquipmentRentalCreate,
    EquipmentRentalResponse,
    FoodSupplyOrderCreate,
    FoodSupplyOrderResponse,
    FoodSupplyOrderUpdate,
)


# Equipment Rentals
def create_rental(db: Session, data: EquipmentRentalCreate) -> EquipmentRentalResponse:
    rental = EquipmentRental(
        name=data.name,
        category=data.category,
        daily_rate=data.daily_rate,
        available_stock=data.available_stock,
        on_rental_count=data.on_rental_count,
        image_url=data.image_url,
    )
    rental = repo.create_rental(db, rental)
    db.commit()
    db.refresh(rental)
    return EquipmentRentalResponse.model_validate(rental)


def list_rentals(
    db: Session, *, category: str | None = None, limit: int = 100, offset: int = 0
) -> list[EquipmentRentalResponse]:
    rentals = repo.list_rentals(db, category=category, limit=limit, offset=offset)
    return [EquipmentRentalResponse.model_validate(r) for r in rentals]


# Food Supply Orders
def create_food_order(db: Session, data: FoodSupplyOrderCreate) -> FoodSupplyOrderResponse:
    site = get_site(db, data.site_id)
    if site is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Construction site not found",
        )

    order = FoodSupplyOrder(
        site_id=data.site_id,
        meal_type=data.meal_type,
        portions=data.portions,
        delivery_date=data.delivery_date,
        delivery_time=data.delivery_time,
        status=data.status,
        total_cost=data.total_cost,
    )
    order = repo.create_food_order(db, order)
    db.commit()
    db.refresh(order)
    resp = FoodSupplyOrderResponse.model_validate(order)
    resp.site_name = site.site_name
    return resp


def update_food_order(
    db: Session, order_id: UUID, data: FoodSupplyOrderUpdate
) -> FoodSupplyOrderResponse:
    order = repo.get_food_order(db, order_id)
    if order is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Food supply order not found",
        )
    if data.status is not None:
        order.status = data.status
    if data.portions is not None:
        order.portions = data.portions
    if data.delivery_time is not None:
        order.delivery_time = data.delivery_time
    if data.total_cost is not None:
        order.total_cost = data.total_cost

    db.commit()
    db.refresh(order)
    resp = FoodSupplyOrderResponse.model_validate(order)
    if order.site:
        resp.site_name = order.site.site_name
    return resp


def list_food_orders(
    db: Session,
    *,
    site_id: UUID | None = None,
    order_status: str | None = None,
    limit: int = 100,
    offset: int = 0,
) -> list[FoodSupplyOrderResponse]:
    orders = repo.list_food_orders(db, site_id=site_id, status=order_status, limit=limit, offset=offset)
    results: list[FoodSupplyOrderResponse] = []
    for o in orders:
        item = FoodSupplyOrderResponse.model_validate(o)
        if o.site:
            item.site_name = o.site.site_name
        results.append(item)
    return results
