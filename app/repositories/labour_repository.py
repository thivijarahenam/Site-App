"""Persistence operations for Labour Profiles."""

from uuid import UUID

from sqlalchemy import func, select
from sqlalchemy.orm import Session, joinedload

from app.models.labour import LabourProfile


def create_labour_profile(db: Session, profile: LabourProfile) -> LabourProfile:
    db.add(profile)
    db.flush()
    db.refresh(profile)
    return profile


def get_labour_by_id(db: Session, labour_id: UUID) -> LabourProfile | None:
    statement = (
        select(LabourProfile)
        .options(joinedload(LabourProfile.current_site))
        .where(LabourProfile.id == labour_id)
    )
    return db.scalar(statement)


def get_labour_by_account_id(db: Session, account_id: UUID) -> LabourProfile | None:
    statement = (
        select(LabourProfile)
        .options(joinedload(LabourProfile.current_site))
        .where(LabourProfile.account_id == account_id)
    )
    return db.scalar(statement)


def get_labour_by_nic(db: Session, nic_number: str) -> LabourProfile | None:
    statement = select(LabourProfile).where(LabourProfile.nic_number == nic_number)
    return db.scalar(statement)


def list_labourers(
    db: Session,
    *,
    site_id: UUID | None = None,
    status: str | None = None,
    job_role: str | None = None,
    search: str | None = None,
    limit: int = 100,
    offset: int = 0,
) -> list[LabourProfile]:
    statement = select(LabourProfile).options(joinedload(LabourProfile.current_site))
    if site_id is not None:
        statement = statement.where(LabourProfile.current_site_id == site_id)
    if status:
        statement = statement.where(LabourProfile.status == status)
    if job_role:
        statement = statement.where(LabourProfile.job_role.ilike(f"%{job_role}%"))
    if search:
        search_pattern = f"%{search}%"
        statement = statement.where(
            LabourProfile.full_name.ilike(search_pattern)
            | LabourProfile.nic_number.ilike(search_pattern)
            | LabourProfile.phone_number.ilike(search_pattern)
        )
    statement = statement.order_by(LabourProfile.created_at.desc()).offset(offset).limit(limit)
    return list(db.scalars(statement).all())


def count_labourers(db: Session, *, status: str | None = None) -> int:
    statement = select(func.count(LabourProfile.id))
    if status:
        statement = statement.where(LabourProfile.status == status)
    return db.scalar(statement) or 0


def delete_labour_profile(db: Session, profile: LabourProfile) -> None:
    db.delete(profile)
    db.flush()
