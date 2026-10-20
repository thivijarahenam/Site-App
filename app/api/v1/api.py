"""Versioned API router."""

from fastapi import APIRouter

from app.api.v1.endpoints.auth import router as auth_router
from app.api.v1.endpoints.dashboard import router as dashboard_router
from app.api.v1.endpoints.health import router as health_router
from app.api.v1.endpoints.labour import router as labour_router
from app.api.v1.endpoints.material_requests import router as material_requests_router
from app.api.v1.endpoints.notifications import router as notifications_router
from app.api.v1.endpoints.reports import router as reports_router
from app.api.v1.endpoints.sites import router as sites_router
from app.api.v1.endpoints.supplier_responses import router as supplier_responses_router
from app.api.v1.endpoints.suppliers import router as suppliers_router

api_router = APIRouter()
api_router.include_router(health_router, tags=["health"])
api_router.include_router(auth_router)
api_router.include_router(sites_router)
api_router.include_router(labour_router)
api_router.include_router(suppliers_router)
api_router.include_router(material_requests_router)
api_router.include_router(supplier_responses_router)
api_router.include_router(dashboard_router)
api_router.include_router(notifications_router)
api_router.include_router(reports_router)
