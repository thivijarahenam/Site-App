"""Controller for health checks."""

from app.schemas.health import HealthResponse
from app.services.health_service import get_health_status


def get_health() -> HealthResponse:
    """Coordinate the health response."""
    return HealthResponse(status=get_health_status())
