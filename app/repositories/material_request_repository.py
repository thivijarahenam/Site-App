"""Persistence operations for Material Requests."""

from uuid import UUID

from sqlalchemy import func, select
from sqlalchemy.orm import Session, joinedload

from app.models.material_request import MaterialRequest
from app.models.supplier_response import SupplierResponse


def create_material_request(db: Session, request: MaterialRequest) -> MaterialRequest:
    db.add(request)
    db.flush()
    db.refresh(request)
    return request


def get_material_request(db: Session, request_id: UUID) -> MaterialRequest | None:
    statement = (
        select(MaterialRequest)
        .options(joinedload(MaterialRequest.site))
        .where(MaterialRequest.id == request_id)
    )
    return db.scalar(statement)


def list_material_requests(
    db: Session,
    *,
    site_id: UUID | None = None,
    status: str | None = None,
    material_category: str | None = None,
    search: str | None = None,
    limit: int = 100,
    offset: int = 0,
) -> list[MaterialRequest]:
    statement = select(MaterialRequest).options(joinedload(MaterialRequest.site))
    if site_id is not None:
        statement = statement.where(MaterialRequest.site_id == site_id)
    if status:
        statement = statement.where(MaterialRequest.status == status)
    if material_category:
        statement = statement.where(MaterialRequest.material_category == material_category)
    if search:
        search_pattern = f"%{search}%"
        statement = statement.where(
            MaterialRequest.material_name.ilike(search_pattern)
            | MaterialRequest.description.ilike(search_pattern)
        )
    statement = statement.order_by(MaterialRequest.created_at.desc()).offset(offset).limit(limit)
    return list(db.scalars(statement).all())


def count_material_requests(db: Session, *, status: str | None = None) -> int:
    statement = select(func.count(MaterialRequest.id))
    if status:
        statement = statement.where(MaterialRequest.status == status)
    return db.scalar(statement) or 0


def get_request_response_count(db: Session, request_id: UUID) -> int:
    statement = select(func.count(SupplierResponse.id)).where(
        SupplierResponse.request_id == request_id
    )
    return db.scalar(statement) or 0


def delete_material_request(db: Session, request: MaterialRequest) -> None:
    db.delete(request)
    db.flush()
