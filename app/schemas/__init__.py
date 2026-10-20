"""API data schemas."""

from app.schemas.auth import (
    AccountCreateRequest,
    AccountInvitationAccept,
    AccountResponse,
    EmployeeSignupRequest,
    LoginRequest,
    LogoutRequest,
    MessageResponse,
    PasswordChangeRequest,
    PasswordResetConfirm,
    PasswordResetRequest,
    ResendOTPRequest,
    SignupRequest,
    SignupResponse,
    SupplierSignupRequest,
    TokenRefreshRequest,
    TokenResponse,
    VerifyOTPRequest,
    VerifyOTPResponse,
)
from app.schemas.dashboard import AdminDashboard, LabourDashboard, SupplierDashboard
from app.schemas.health import HealthResponse
from app.schemas.labour import (
    LabourAssignSite,
    LabourCreate,
    LabourDetail,
    LabourSelfUpdate,
    LabourUpdate,
)
from app.schemas.material_request import (
    MaterialRequestCreate,
    MaterialRequestDetail,
    MaterialRequestUpdate,
)
from app.schemas.notification import NotificationDetail, UnreadCountResponse
from app.schemas.report import AdminReportsSummary
from app.schemas.site import SiteCreate, SiteDetail, SitePublic, SiteUpdate
from app.schemas.supplier import (
    SupplierCreate,
    SupplierDetail,
    SupplierSelfUpdate,
    SupplierUpdate,
)
from app.schemas.supplier_response import (
    ReviewResponseAction,
    SupplierResponseCreate,
    SupplierResponseDetail,
)

__all__ = [
    "HealthResponse",
    "LoginRequest",
    "TokenRefreshRequest",
    "LogoutRequest",
    "TokenResponse",
    "AccountResponse",
    "AccountCreateRequest",
    "EmployeeSignupRequest",
    "SupplierSignupRequest",
    "SignupRequest",
    "SignupResponse",
    "VerifyOTPRequest",
    "VerifyOTPResponse",
    "ResendOTPRequest",
    "PasswordChangeRequest",
    "MessageResponse",
    "PasswordResetRequest",
    "PasswordResetConfirm",
    "AccountInvitationAccept",
    "SiteCreate",
    "SiteUpdate",
    "SitePublic",
    "SiteDetail",
    "LabourCreate",
    "LabourUpdate",
    "LabourSelfUpdate",
    "LabourAssignSite",
    "LabourDetail",
    "SupplierCreate",
    "SupplierUpdate",
    "SupplierSelfUpdate",
    "SupplierDetail",
    "MaterialRequestCreate",
    "MaterialRequestUpdate",
    "MaterialRequestDetail",
    "SupplierResponseCreate",
    "SupplierResponseDetail",
    "ReviewResponseAction",
    "NotificationDetail",
    "UnreadCountResponse",
    "AdminDashboard",
    "LabourDashboard",
    "SupplierDashboard",
    "AdminReportsSummary",
]
