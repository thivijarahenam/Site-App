"""Pydantic schemas for Operational Reports."""

from decimal import Decimal
from uuid import UUID

from pydantic import BaseModel


class SiteLabourCount(BaseModel):
    site_id: UUID
    site_name: str
    project_name: str
    status: str
    labour_count: int


class CategoryRequestCount(BaseModel):
    category: str
    request_count: int
    total_quantity: Decimal


class SupplierPerformance(BaseModel):
    supplier_id: UUID
    company_name: str
    total_responses: int
    accepted_responses: int
    rejected_responses: int


class AdminReportsSummary(BaseModel):
    sites_by_status: dict[str, int]
    site_labour_distribution: list[SiteLabourCount]
    requests_by_category: list[CategoryRequestCount]
    supplier_performance: list[SupplierPerformance]
