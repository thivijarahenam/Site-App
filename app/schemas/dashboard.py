"""Pydantic schemas for Dashboards."""

from pydantic import BaseModel

from app.schemas.labour import LabourDetail
from app.schemas.notification import NotificationDetail
from app.schemas.site import SitePublic
from app.schemas.supplier import SupplierDetail


class ActivityItemSchema(BaseModel):
    id: str
    title: str
    subtitle: str
    time_ago: str
    type: str  # attendance, delivery, photo, quote, approval, logbook
    project_id: str | None = None


class TaskItemSchema(BaseModel):
    id: str
    title: str
    project_name: str
    due_date: str
    is_completed: bool = False


class ApprovalItemSchema(BaseModel):
    id: str
    title: str
    count: int
    category: str


class TeamMemberSchema(BaseModel):
    id: str
    name: str
    role: str
    on_site_count: int = 1
    avatar_url: str | None = None
    is_on_site: bool = True


class AdminDashboard(BaseModel):
    total_sites: int
    active_sites: int
    total_labourers: int
    active_labourers: int
    total_suppliers: int
    active_suppliers: int
    pending_material_requests: int
    pending_supplier_responses: int
    completed_material_requests: int
    recent_activities: list[ActivityItemSchema] = []
    today_tasks: list[TaskItemSchema] = []
    pending_approvals: list[ApprovalItemSchema] = []
    team_members: list[TeamMemberSchema] = []


class SupervisorDashboard(BaseModel):
    active_sites: int
    active_labourers: int
    pending_material_requests: int
    pending_logbook_entries: int
    recent_activities: list[ActivityItemSchema] = []
    today_tasks: list[TaskItemSchema] = []
    pending_approvals: list[ApprovalItemSchema] = []


class LabourDashboard(BaseModel):
    profile: LabourDetail | None
    assigned_site: SitePublic | None
    unread_notifications_count: int
    recent_notifications: list[NotificationDetail]


class SupplierDashboard(BaseModel):
    profile: SupplierDetail | None
    open_material_requests_count: int
    submitted_responses_count: int
    accepted_responses_count: int
    unread_notifications_count: int
    recent_notifications: list[NotificationDetail]

