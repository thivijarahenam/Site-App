"""Pydantic schemas for Marketplace Equipment Rentals and Food Supply Orders."""

from datetime import date, datetime
from decimal import Decimal
from uuid import UUID

from pydantic import BaseModel, ConfigDict, Field


class EquipmentRentalCreate(BaseModel):
    name: str = Field(..., min_length=2, max_length=200)
    category: str = Field(..., min_length=2, max_length=100)
    daily_rate: Decimal = Field(..., gt=0)
    available_stock: int = Field(default=1, ge=0)
    on_rental_count: int = Field(default=0, ge=0)
    image_url: str | None = None


class EquipmentRentalResponse(BaseModel):
    id: UUID
    name: str
    category: str
    daily_rate: Decimal
    available_stock: int
    on_rental_count: int
    image_url: str | None = None
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)


class FoodSupplyOrderCreate(BaseModel):
    site_id: UUID
    meal_type: str = Field(..., min_length=2, max_length=50)
    portions: int = Field(..., gt=0)
    delivery_date: date
    delivery_time: str = Field(..., min_length=2, max_length=50)
    status: str = Field(default="Pending", max_length=50)
    total_cost: Decimal = Field(..., gt=0)


class FoodSupplyOrderUpdate(BaseModel):
    status: str | None = Field(None, max_length=50)
    portions: int | None = Field(None, gt=0)
    delivery_time: str | None = Field(None, max_length=50)
    total_cost: Decimal | None = Field(None, gt=0)


class FoodSupplyOrderResponse(BaseModel):
    id: UUID
    site_id: UUID
    site_name: str | None = None
    meal_type: str
    portions: int
    delivery_date: date
    delivery_time: str
    status: str
    total_cost: Decimal
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)
