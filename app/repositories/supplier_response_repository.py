"""Persistence operations for Supplier Responses (Quotations)."""

from uuid import UUID

from sqlalchemy import func, select
from sqlalchemy.orm import Session, joinedload

from app.models.supplier_response import SupplierResponse


def create_supplier_response(db: Session, response: SupplierResponse) -> SupplierResponse:
    db.add(response)
    db.flush()
    db.refresh(response)
    return response


def get_supplier_response(db: Session, response_id: UUID) -> SupplierResponse | None:
    statement = (
        select(SupplierResponse)
        .options(joinedload(SupplierResponse.supplier))
        .where(SupplierResponse.id == response_id)
    )
    return db.scalar(statement)


def get_response_by_request_and_supplier(
    db: Session, request_id: UUID, supplier_id: UUID
) -> SupplierResponse | None:
    statement = select(SupplierResponse).where(
        SupplierResponse.request_id == request_id, SupplierResponse.supplier_id == supplier_id
    )
    return db.scalar(statement)


def list_responses_for_request(
    db: Session, request_id: UUID, *, status: str | None = None
) -> list[SupplierResponse]:
    statement = (
        select(SupplierResponse)
        .options(joinedload(SupplierResponse.supplier))
        .where(SupplierResponse.request_id == request_id)
    )
    if status:
        statement = statement.where(SupplierResponse.status == status)
    statement = statement.order_by(SupplierResponse.submission_date.desc())
    return list(db.scalars(statement).all())


def list_responses_by_supplier(
    db: Session, supplier_id: UUID, *, status: str | None = None, limit: int = 100, offset: int = 0
) -> list[SupplierResponse]:
    statement = (
        select(SupplierResponse)
        .options(joinedload(SupplierResponse.supplier))
        .where(SupplierResponse.supplier_id == supplier_id)
    )
    if status:
        statement = statement.where(SupplierResponse.status == status)
    statement = (
        statement.order_by(SupplierResponse.submission_date.desc()).offset(offset).limit(limit)
    )
    return list(db.scalars(statement).all())


def count_supplier_responses(
    db: Session, *, status: str | None = None, supplier_id: UUID | None = None
) -> int:
    statement = select(func.count(SupplierResponse.id))
    if status:
        statement = statement.where(SupplierResponse.status == status)
    if supplier_id is not None:
        statement = statement.where(SupplierResponse.supplier_id == supplier_id)
    return db.scalar(statement) or 0
