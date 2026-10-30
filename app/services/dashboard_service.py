"""Dashboard and Reporting service."""

from decimal import Decimal
from uuid import UUID

from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.models.labour import LabourProfile, LabourStatus
from app.models.material_request import MaterialRequest, MaterialRequestStatus
from app.models.site import ConstructionSite, SiteStatus
from app.models.supplier import SupplierProfile, SupplierStatus
from app.models.supplier_response import ResponseStatus, SupplierResponse
from app.repositories.labour_repository import count_labourers, get_labour_by_account_id
from app.repositories.material_request_repository import count_material_requests
from app.repositories.notification_repository import count_unread, list_notifications
from app.repositories.site_repository import count_sites, get_site
from app.repositories.supplier_repository import count_suppliers, get_supplier_by_account_id
from app.repositories.supplier_response_repository import count_supplier_responses
from app.schemas.dashboard import (
    ActivityItemSchema,
    AdminDashboard,
    ApprovalItemSchema,
    LabourDashboard,
    SupervisorDashboard,
    SupplierDashboard,
    TaskItemSchema,
    TeamMemberSchema,
)
from app.schemas.report import (
    AdminReportsSummary,
    CategoryRequestCount,
    SiteLabourCount,
    SupplierPerformance,
)



def _default_activities() -> list[ActivityItemSchema]:
    return [
        ActivityItemSchema(
            id="act-1",
            title="Daily attendance signed",
            subtitle="22 labourers check-in confirmed",
            time_ago="12m ago",
            type="attendance",
        ),
        ActivityItemSchema(
            id="act-2",
            title="ReadyMix Concrete delivered",
            subtitle="Jaffna School Project • 40m³",
            time_ago="1h ago",
            type="delivery",
        ),
        ActivityItemSchema(
            id="act-3",
            title="Steel binding QA photo uploaded",
            subtitle="Ladies Hostel • Level 2 slab",
            time_ago="2h ago",
            type="photo",
        ),
        ActivityItemSchema(
            id="act-4",
            title="Supplier quote received",
            subtitle="Tokyo Super Cement • LKR 2,450/bag",
            time_ago="3h ago",
            type="quote",
        ),
        ActivityItemSchema(
            id="act-5",
            title="Site Inspection Report approved",
            subtitle="Site Engineer Sivaram",
            time_ago="4h ago",
            type="approval",
        ),
    ]


def _default_tasks() -> list[TaskItemSchema]:
    return [
        TaskItemSchema(
            id="t-1",
            title="Verify rebar bending at Jaffna School",
            project_name="Jaffna School Project",
            due_date="Today, 2:00 PM",
            is_completed=False,
        ),
        TaskItemSchema(
            id="t-2",
            title="Approve cement quotation from Jaffna Hardware",
            project_name="Procurement",
            due_date="Today, 4:30 PM",
            is_completed=True,
        ),
        TaskItemSchema(
            id="t-3",
            title="Confirm labour attendance for tomorrow shift",
            project_name="Workforce",
            due_date="Today, 6:00 PM",
            is_completed=False,
        ),
    ]


def _default_approvals() -> list[ApprovalItemSchema]:
    return [
        ApprovalItemSchema(id="app-1", title="Material Requisitions", count=3, category="materials"),
        ApprovalItemSchema(id="app-2", title="Subcontractor Claims", count=2, category="subContractor"),
        ApprovalItemSchema(id="app-3", title="Labour Leave Requests", count=4, category="leave"),
    ]


def _default_team_members() -> list[TeamMemberSchema]:
    return [
        TeamMemberSchema(id="tm-1", name="K. Niroshan", role="Site Supervisor", on_site_count=1, is_on_site=True),
        TeamMemberSchema(id="tm-2", name="S. Thevakanthan", role="Technical Officer", on_site_count=1, is_on_site=True),
        TeamMemberSchema(id="tm-3", name="M. Sivaram", role="Resident Engineer", on_site_count=1, is_on_site=True),
    ]


def get_admin_dashboard(db: Session) -> AdminDashboard:
    total_sites = count_sites(db)
    active_sites = count_sites(db, status=SiteStatus.ACTIVE.value)
    total_labourers = count_labourers(db)
    active_labourers = count_labourers(db, status=LabourStatus.ACTIVE.value)
    total_suppliers = count_suppliers(db)
    active_suppliers = count_suppliers(db, status=SupplierStatus.ACTIVE.value)
    pending_requests = count_material_requests(db, status=MaterialRequestStatus.PENDING.value)
    pending_responses = count_supplier_responses(db, status=ResponseStatus.SUBMITTED.value)
    completed_requests = count_material_requests(db, status=MaterialRequestStatus.COMPLETED.value)

    return AdminDashboard(
        total_sites=total_sites,
        active_sites=active_sites,
        total_labourers=total_labourers,
        active_labourers=active_labourers,
        total_suppliers=total_suppliers,
        active_suppliers=active_suppliers,
        pending_material_requests=pending_requests,
        pending_supplier_responses=pending_responses,
        completed_material_requests=completed_requests,
        recent_activities=_default_activities(),
        today_tasks=_default_tasks(),
        pending_approvals=_default_approvals(),
        team_members=_default_team_members(),
    )


def get_supervisor_dashboard(db: Session) -> SupervisorDashboard:
    active_sites = count_sites(db, status=SiteStatus.ACTIVE.value)
    active_labourers = count_labourers(db, status=LabourStatus.ACTIVE.value)
    pending_requests = count_material_requests(db, status=MaterialRequestStatus.PENDING.value)
    from app.models.logbook import ProjectLogbookEntry
    logbook_count = db.scalar(select(func.count(ProjectLogbookEntry.id)).where(ProjectLogbookEntry.is_acknowledged == False)) or 0

    return SupervisorDashboard(
        active_sites=active_sites,
        active_labourers=active_labourers,
        pending_material_requests=pending_requests,
        pending_logbook_entries=logbook_count,
        recent_activities=_default_activities(),
        today_tasks=_default_tasks(),
        pending_approvals=_default_approvals(),
    )



def get_labour_dashboard(db: Session, account_id: UUID) -> LabourDashboard:
    profile = get_labour_by_account_id(db, account_id)
    profile_dto = LabourDetail.model_validate(profile) if profile else None

    assigned_site_dto = None
    if profile and profile.current_site_id:
        site = get_site(db, profile.current_site_id)
        if site:
            assigned_site_dto = SitePublic.model_validate(site)

    unread_count = count_unread(db, account_id)
    recent = list_notifications(db, account_id, limit=5)
    recent_dto = [NotificationDetail.model_validate(n) for n in recent]

    return LabourDashboard(
        profile=profile_dto,
        assigned_site=assigned_site_dto,
        unread_notifications_count=unread_count,
        recent_notifications=recent_dto,
    )


def get_supplier_dashboard(db: Session, account_id: UUID) -> SupplierDashboard:
    profile = get_supplier_by_account_id(db, account_id)
    profile_dto = SupplierDetail.model_validate(profile) if profile else None

    open_requests_count = count_material_requests(db, status=MaterialRequestStatus.PENDING.value)
    submitted_count = 0
    accepted_count = 0
    if profile:
        submitted_count = count_supplier_responses(
            db, status=ResponseStatus.SUBMITTED.value, supplier_id=profile.id
        )
        accepted_count = count_supplier_responses(
            db, status=ResponseStatus.ACCEPTED.value, supplier_id=profile.id
        )

    unread_count = count_unread(db, account_id)
    recent = list_notifications(db, account_id, limit=5)
    recent_dto = [NotificationDetail.model_validate(n) for n in recent]

    return SupplierDashboard(
        profile=profile_dto,
        open_material_requests_count=open_requests_count,
        submitted_responses_count=submitted_count,
        accepted_responses_count=accepted_count,
        unread_notifications_count=unread_count,
        recent_notifications=recent_dto,
    )


def get_admin_reports(db: Session) -> AdminReportsSummary:
    # 1. Sites by status
    site_status_rows = db.execute(
        select(ConstructionSite.status, func.count(ConstructionSite.id)).group_by(
            ConstructionSite.status
        )
    ).all()
    sites_by_status = {row[0]: row[1] for row in site_status_rows}

    # 2. Site labour distribution
    labour_dist_rows = db.execute(
        select(
            ConstructionSite.id,
            ConstructionSite.site_name,
            ConstructionSite.project_name,
            ConstructionSite.status,
            func.count(LabourProfile.id).label("worker_count"),
        )
        .outerjoin(LabourProfile, LabourProfile.current_site_id == ConstructionSite.id)
        .group_by(ConstructionSite.id)
    ).all()

    site_labour_distribution = [
        SiteLabourCount(
            site_id=row[0],
            site_name=row[1],
            project_name=row[2],
            status=row[3],
            labour_count=row[4],
        )
        for row in labour_dist_rows
    ]

    # 3. Requests by category
    category_rows = db.execute(
        select(
            MaterialRequest.material_category,
            func.count(MaterialRequest.id),
            func.sum(MaterialRequest.required_quantity),
        ).group_by(MaterialRequest.material_category)
    ).all()

    requests_by_category = [
        CategoryRequestCount(
            category=row[0],
            request_count=row[1],
            total_quantity=row[2] or Decimal("0"),
        )
        for row in category_rows
    ]

    # 4. Supplier performance
    supplier_rows = db.execute(
        select(
            SupplierProfile.id,
            SupplierProfile.company_name,
            func.count(SupplierResponse.id).label("total_responses"),
            func.count(
                func.nullif(SupplierResponse.status != ResponseStatus.ACCEPTED.value, True)
            ).label("accepted"),
            func.count(
                func.nullif(SupplierResponse.status != ResponseStatus.REJECTED.value, True)
            ).label("rejected"),
        )
        .outerjoin(SupplierResponse, SupplierResponse.supplier_id == SupplierProfile.id)
        .group_by(SupplierProfile.id)
    ).all()

    supplier_performance = [
        SupplierPerformance(
            supplier_id=row[0],
            company_name=row[1],
            total_responses=row[2],
            accepted_responses=row[3],
            rejected_responses=row[4],
        )
        for row in supplier_rows
    ]

    return AdminReportsSummary(
        sites_by_status=sites_by_status,
        site_labour_distribution=site_labour_distribution,
        requests_by_category=requests_by_category,
        supplier_performance=supplier_performance,
    )
