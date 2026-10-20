"""Pydantic schemas for Dashboards."""

from pydantic import BaseModel

from app.schemas.labour import LabourDetail
from app.schemas.notification import NotificationDetail
from app.schemas.site import SitePublic
from app.schemas.supplier import SupplierDetail


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
