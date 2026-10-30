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


def _to_site_detail(db: Session, site: ConstructionSite) -> SiteDetail:
    count = get_site_labourer_count(db, site.id)
    labour_ids = [str(l.id) for l in getattr(site, "assigned_labourers", [])]
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
        progress=site.progress,
        contract_value=site.contract_value,
        cost_spent=site.cost_spent,
        margin=site.margin,
        labour_count=site.labour_count or f"{count} Workers",
        image_url=site.image_url,
        supervisor_name=site.supervisor_name,
        supervisor_phone=site.supervisor_phone,
        stages=site.stages or [
            "Site Preparation",
            "Foundation",
            "Structural Work",
            "Block Work",
            "Plastering",
            "Electrical & Plumbing",
            "Finishing & Handover",
        ],
        assigned_labourer_count=count,
        assigned_labour_ids=labour_ids,
        created_at=site.created_at,
        updated_at=site.updated_at,
    )


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
        progress=data.progress,
        contract_value=data.contract_value,
        cost_spent=data.cost_spent,
        margin=data.margin,
        labour_count=data.labour_count,
        image_url=data.image_url,
        supervisor_name=data.supervisor_name,
        supervisor_phone=data.supervisor_phone,
        stages=data.stages or [
            "Site Preparation",
            "Foundation",
            "Structural Work",
            "Block Work",
            "Plastering",
            "Electrical & Plumbing",
            "Finishing & Handover",
        ],
    )
    site = create_site(db, site)
    db.commit()
    db.refresh(site)
    return _to_site_detail(db, site)


def get_site_by_id(db: Session, site_id: UUID) -> SiteDetail:
    site = get_site(db, site_id)
    if site is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Construction site not found",
        )
    return _to_site_detail(db, site)


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
    if data.progress is not None:
        site.progress = data.progress
    if data.contract_value is not None:
        site.contract_value = data.contract_value
    if data.cost_spent is not None:
        site.cost_spent = data.cost_spent
    if data.margin is not None:
        site.margin = data.margin
    if data.labour_count is not None:
        site.labour_count = data.labour_count
    if data.image_url is not None:
        site.image_url = data.image_url
    if data.supervisor_name is not None:
        site.supervisor_name = data.supervisor_name
    if data.supervisor_phone is not None:
        site.supervisor_phone = data.supervisor_phone
    if data.stages is not None:
        site.stages = data.stages

    db.commit()
    db.refresh(site)
    return _to_site_detail(db, site)


def list_construction_sites(
    db: Session,
    *,
    status: str | None = None,
    search: str | None = None,
    limit: int = 100,
    offset: int = 0,
) -> list[SiteDetail]:
    sites = list_sites(db, status=status, search=search, limit=limit, offset=offset)
    return [_to_site_detail(db, s) for s in sites]


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
