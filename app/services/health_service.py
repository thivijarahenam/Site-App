"""Health check business logic."""


def get_health_status() -> str:
    """Return process liveness without external dependency checks."""
    return "ok"
