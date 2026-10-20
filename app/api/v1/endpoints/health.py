"""Health endpoint route."""

from fastapi import APIRouter

from app.controllers.health_controller import get_health
from app.schemas.health import HealthResponse

router = APIRouter()


@router.get("/health", response_model=HealthResponse, summary="Check API health")
def health() -> HealthResponse:
    """Return process health without requiring a database connection."""
    return get_health()
