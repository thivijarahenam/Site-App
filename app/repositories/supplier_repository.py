"""Persistence operations for Supplier Profiles."""

from uuid import UUID

from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.models.supplier import SupplierProfile


def create_supplier_profile(db: Session, profile: SupplierProfile) -> SupplierProfile:
    db.add(profile)
    db.flush()
    db.refresh(profile)
    return profile


def get_supplier_by_id(db: Session, supplier_id: UUID) -> SupplierProfile | None:
    return db.get(SupplierProfile, supplier_id)


def get_supplier_by_account_id(db: Session, account_id: UUID) -> SupplierProfile | None:
    statement = select(SupplierProfile).where(SupplierProfile.account_id == account_id)
    return db.scalar(statement)


def list_suppliers(
    db: Session,
    *,
    status: str | None = None,
    search: str | None = None,
    limit: int = 100,
    offset: int = 0,
) -> list[SupplierProfile]:
    statement = select(SupplierProfile)
    if status:
        statement = statement.where(SupplierProfile.company_status == status)
    if search:
        search_pattern = f"%{search}%"
        statement = statement.where(
            SupplierProfile.company_name.ilike(search_pattern)
            | SupplierProfile.contact_person.ilike(search_pattern)
            | SupplierProfile.materials_supplied.ilike(search_pattern)
        )
    statement = statement.order_by(SupplierProfile.created_at.desc()).offset(offset).limit(limit)
    return list(db.scalars(statement).all())


def count_suppliers(db: Session, *, status: str | None = None) -> int:
    statement = select(func.count(SupplierProfile.id))
    if status:
        statement = statement.where(SupplierProfile.company_status == status)
    return db.scalar(statement) or 0


def delete_supplier_profile(db: Session, profile: SupplierProfile) -> None:
    db.delete(profile)
    db.flush()
