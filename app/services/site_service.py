"""Construction Site service."""

from uuid import UUID

from fastapi import HTTPException, status
from sqlalchemy.orm import Session

from app.models.site import ConstructionSite
from app.repositories.labour_repository import get_labour_by_account_id, list_labourers
from app.repositories.site_repository import (
    create_site,
    get_site,
    get_site_labourer_count,
    list_sites,
)
from app.schemas.labour import LabourDetail
from app.schemas.site import SiteCreate, SiteDetail, SitePublic, SiteUpdate


def create_construction_site(db: Session, data: SiteCreate) -> SiteDetail:
    site = ConstructionSite(
        site_name=data.site_name,
        project_name=data.project_name,
        site_address=data.site_address,
        client_name=data.client_name,
        start_date=data.start_date,
        expected_completion_date=data.expected_completion_date,
        status=data.status.value,
        description=data.description,
    )
    site = create_site(db, site)
    db.commit()
    db.refresh(site)
    count = get_site_labourer_count(db, site.id)
    return SiteDetail(
        id=site.id,
        site_name=site.site_name,
        project_name=site.project_name,
        site_address=site.site_address,
        client_name=site.client_name,
        start_date=site.start_date,
        expected_completion_date=site.expected_completion_date,
        status=site.status,
        description=site.description,
        assigned_labourer_count=count,
        created_at=site.created_at,
        updated_at=site.updated_at,
    )


def get_site_by_id(db: Session, site_id: UUID) -> SiteDetail:
    site = get_site(db, site_id)
    if site is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Construction site not found",
        )
    count = get_site_labourer_count(db, site.id)
    return SiteDetail(
        id=site.id,
        site_name=site.site_name,
        project_name=site.project_name,
        site_address=site.site_address,
        client_name=site.client_name,
        start_date=site.start_date,
        expected_completion_date=site.expected_completion_date,
        status=site.status,
        description=site.description,
        assigned_labourer_count=count,
        created_at=site.created_at,
        updated_at=site.updated_at,
    )


def update_site_by_id(db: Session, site_id: UUID, data: SiteUpdate) -> SiteDetail:
    site = get_site(db, site_id)
    if site is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Construction site not found",
        )
    if data.site_name is not None:
        site.site_name = data.site_name
    if data.project_name is not None:
        site.project_name = data.project_name
    if data.site_address is not None:
        site.site_address = data.site_address
    if data.client_name is not None:
        site.client_name = data.client_name
    if data.start_date is not None:
        site.start_date = data.start_date
    if data.expected_completion_date is not None:
        site.expected_completion_date = data.expected_completion_date
    if data.status is not None:
        site.status = data.status.value
    if data.description is not None:
        site.description = data.description

    db.commit()
    db.refresh(site)
    count = get_site_labourer_count(db, site.id)
    return SiteDetail(
        id=site.id,
        site_name=site.site_name,
        project_name=site.project_name,
        site_address=site.site_address,
        client_name=site.client_name,
        start_date=site.start_date,
        expected_completion_date=site.expected_completion_date,
        status=site.status,
        description=site.description,
        assigned_labourer_count=count,
        created_at=site.created_at,
        updated_at=site.updated_at,
    )


def list_construction_sites(
    db: Session,
    *,
    status: str | None = None,
    search: str | None = None,
    limit: int = 100,
    offset: int = 0,
) -> list[SiteDetail]:
    sites = list_sites(db, status=status, search=search, limit=limit, offset=offset)
    results: list[SiteDetail] = []
    for s in sites:
        count = get_site_labourer_count(db, s.id)
        results.append(
            SiteDetail(
                id=s.id,
                site_name=s.site_name,
                project_name=s.project_name,
                site_address=s.site_address,
                client_name=s.client_name,
                start_date=s.start_date,
                expected_completion_date=s.expected_completion_date,
                status=s.status,
                description=s.description,
                assigned_labourer_count=count,
                created_at=s.created_at,
                updated_at=s.updated_at,
            )
        )
    return results


def get_assigned_site_for_labourer(db: Session, account_id: UUID) -> SitePublic | None:
    profile = get_labour_by_account_id(db, account_id)
    if profile is None or profile.current_site_id is None:
        return None
    site = get_site(db, profile.current_site_id)
    if site is None:
        return None
    return SitePublic.model_validate(site)


def get_labourers_at_site(db: Session, site_id: UUID) -> list[LabourDetail]:
    site = get_site(db, site_id)
    if site is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Construction site not found",
        )
    labourers = list_labourers(db, site_id=site_id)
    return [LabourDetail.model_validate(worker) for worker in labourers]
