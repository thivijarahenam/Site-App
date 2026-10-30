"""Marketplace Equipment Rentals & Food Supply Orders API endpoints."""

from uuid import UUID

from fastapi import APIRouter, Depends, Query, status
from sqlalchemy.orm import Session

from app.database.session import get_db
from app.models.account import AccountRole
from app.schemas.marketplace import (
    EquipmentRentalCreate,
    EquipmentRentalResponse,
    FoodSupplyOrderCreate,
    FoodSupplyOrderResponse,
    FoodSupplyOrderUpdate,
)
from app.security.dependencies import require_roles
from app.services import marketplace_service

router = APIRouter(prefix="/marketplace", tags=["marketplace"])


# Equipment Rentals
@router.post(
    "/rentals",
    response_model=EquipmentRentalResponse,
    status_code=status.HTTP_201_CREATED,
    dependencies=[Depends(require_roles(AccountRole.ADMIN, AccountRole.SUPERVISOR, AccountRole.SUPPLIER))],
)
def create_rental_item(
    data: EquipmentRentalCreate, db: Session = Depends(get_db)
) -> EquipmentRentalResponse:
    """Add equipment/tool to marketplace rental catalog."""
    return marketplace_service.create_rental(db, data)


@router.get(
    "/rentals",
    response_model=list[EquipmentRentalResponse],
)
def list_rental_items(
    category: str | None = Query(None, description="Filter by machinery category (Excavator, Mixer, Scaffolding, Jacks)"),
    limit: int = Query(100, ge=1, le=500),
    offset: int = Query(0, ge=0),
    db: Session = Depends(get_db),
) -> list[EquipmentRentalResponse]:
    """List available equipment rental machinery and tools."""
    return marketplace_service.list_rentals(db, category=category, limit=limit, offset=offset)


# Food Supply Orders
@router.post(
    "/food-orders",
    response_model=FoodSupplyOrderResponse,
    status_code=status.HTTP_201_CREATED,
    dependencies=[Depends(require_roles(AccountRole.ADMIN, AccountRole.SUPERVISOR, AccountRole.FOOD_SUPPLIER))],
)
def create_food_order(
    data: FoodSupplyOrderCreate, db: Session = Depends(get_db)
) -> FoodSupplyOrderResponse:
    """Place a catering / meal order for a site workforce."""
    return marketplace_service.create_food_order(db, data)


@router.patch(
    "/food-orders/{order_id}",
    response_model=FoodSupplyOrderResponse,
    dependencies=[Depends(require_roles(AccountRole.ADMIN, AccountRole.SUPERVISOR, AccountRole.FOOD_SUPPLIER))],
)
def update_food_order(
    order_id: UUID, data: FoodSupplyOrderUpdate, db: Session = Depends(get_db)
) -> FoodSupplyOrderResponse:
    """Update food supply order status or details (Admin / Food Supplier)."""
    return marketplace_service.update_food_order(db, order_id, data)


@router.get(
    "/food-orders",
    response_model=list[FoodSupplyOrderResponse],
)
def list_food_orders(
    site_id: UUID | None = Query(None, description="Filter orders by site"),
    order_status: str | None = Query(None, description="Filter by status (Pending, Preparing, Out for Delivery, Delivered)"),
    limit: int = Query(100, ge=1, le=500),
    offset: int = Query(0, ge=0),
    db: Session = Depends(get_db),
) -> list[FoodSupplyOrderResponse]:
    """List food orders across sites with optional filters."""
    return marketplace_service.list_food_orders(
        db, site_id=site_id, order_status=order_status, limit=limit, offset=offset
    )
