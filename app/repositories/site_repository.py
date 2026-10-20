"""Persistence operations for Construction Sites."""

from uuid import UUID

from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.models.labour import LabourProfile
from app.models.site import ConstructionSite


def create_site(db: Session, site: ConstructionSite) -> ConstructionSite:
    db.add(site)
    db.flush()
    db.refresh(site)
    return site


def get_site(db: Session, site_id: UUID) -> ConstructionSite | None:
    return db.get(ConstructionSite, site_id)


def list_sites(
    db: Session,
    *,
    status: str | None = None,
    search: str | None = None,
    limit: int = 100,
    offset: int = 0,
) -> list[ConstructionSite]:
    statement = select(ConstructionSite)
    if status:
        statement = statement.where(ConstructionSite.status == status)
    if search:
        search_pattern = f"%{search}%"
        statement = statement.where(
            ConstructionSite.site_name.ilike(search_pattern)
            | ConstructionSite.project_name.ilike(search_pattern)
            | ConstructionSite.client_name.ilike(search_pattern)
        )
    statement = statement.order_by(ConstructionSite.created_at.desc()).offset(offset).limit(limit)
    return list(db.scalars(statement).all())


def count_sites(db: Session, *, status: str | None = None) -> int:
    statement = select(func.count(ConstructionSite.id))
    if status:
        statement = statement.where(ConstructionSite.status == status)
    return db.scalar(statement) or 0


def get_site_labourer_count(db: Session, site_id: UUID) -> int:
    statement = select(func.count(LabourProfile.id)).where(LabourProfile.current_site_id == site_id)
    return db.scalar(statement) or 0


def delete_site(db: Session, site: ConstructionSite) -> None:
    db.delete(site)
    db.flush()
