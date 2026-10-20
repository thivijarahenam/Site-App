"""Integration tests for self-registration and strong OTP verification."""

from datetime import UTC, datetime, timedelta
from uuid import UUID

from fastapi.testclient import TestClient
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.models.account import Account, AccountOTP
from app.models.labour import LabourProfile
from app.models.supplier import SupplierProfile


def test_employee_self_registration_and_otp_verification(
    test_env: tuple[TestClient, Session, dict[str, str]],
) -> None:
    client, session, _ = test_env

    # 1. Employee self-registers without any invitation token
    signup_data = {
        "role": "employee",
        "email": "kasun.bandara@civilcorp.lk",
        "password": "kasun-super-strong-password-123",
        "first_name": "Kasun",
        "last_name": "Bandara",
        "phone_number": "+94771122334",
        "address": "128 Colombo Road, Gampaha",
        "job_role": "Site Leader",
    }
    signup_resp = client.post("/api/v1/auth/signup", json=signup_data)
    assert signup_resp.status_code == 201
    resp_json = signup_resp.json()
    assert resp_json["email"] == "kasun.bandara@civilcorp.lk"
    assert resp_json["verification_status"] == "PENDING"
    account_id = UUID(resp_json["account_id"])

    # 2. Verify account and profile created in DB
    account = session.get(Account, account_id)
    assert account is not None
    assert account.is_verified is False
    assert account.is_active is False
    assert account.verification_status == "PENDING"

    labour_profile = session.scalar(
        select(LabourProfile).where(LabourProfile.account_id == account_id)
    )
    assert labour_profile is not None
    assert labour_profile.first_name == "Kasun"
    assert labour_profile.last_name == "Bandara"
    assert labour_profile.full_name == "Kasun Bandara"
    assert labour_profile.phone_number == "+94771122334"
    assert labour_profile.address == "128 Colombo Road, Gampaha"
    assert labour_profile.job_role == "Site Leader"

    # 3. Check OTP record in DB
    otp_record = session.scalar(
        select(AccountOTP)
        .where(AccountOTP.account_id == account_id)
        .order_by(AccountOTP.created_at.desc())
    )
    assert otp_record is not None
    assert otp_record.consumed_at is None
    assert otp_record.failed_attempts == 0
    from app.security.tokens import as_utc

    # Strict 10-minute expiry
    assert as_utc(otp_record.expires_at) > datetime.now(UTC)
    assert as_utc(otp_record.expires_at) <= datetime.now(UTC) + timedelta(minutes=11)

    # 4. Attempt login prior to verification -> 403 Forbidden
    login_resp = client.post(
        "/api/v1/auth/login",
        json={
            "email": "kasun.bandara@civilcorp.lk",
            "password": "kasun-super-strong-password-123",
        },
    )
    assert login_resp.status_code == 403
    assert "not verified" in login_resp.json()["error"]["message"]

    # 5. Test invalid OTP attempts and brute-force tracking
    wrong_otp_resp = client.post(
        "/api/v1/auth/verify-otp",
        json={"email": "kasun.bandara@civilcorp.lk", "otp": "000000"},
    )
    assert wrong_otp_resp.status_code == 400
    assert "attempt(s) remaining" in wrong_otp_resp.json()["error"]["message"]

    session.refresh(otp_record)
    assert otp_record.failed_attempts == 1

    # 6. Verify with the actual OTP code by finding matching 6-digit code
    from app.services.otp_service import hash_otp

    actual_code = None
    for candidate in range(1_000_000):
        code_str = f"{candidate:06d}"
        if hash_otp(code_str, account_id) == otp_record.otp_hash:
            actual_code = code_str
            break

    assert actual_code is not None

    # Submit correct OTP
    verify_resp = client.post(
        "/api/v1/auth/verify-otp",
        json={"email": "kasun.bandara@civilcorp.lk", "otp": actual_code},
    )
    assert verify_resp.status_code == 200
    verify_data = verify_resp.json()
    assert verify_data["account"]["is_verified"] is True
    assert verify_data["tokens"]["access_token"] is not None

    # 7. Check account is now active and verified in DB
    session.refresh(account)
    assert account.is_verified is True
    assert account.is_active is True
    assert account.verification_status == "VERIFIED"

    # 8. Post-verification login succeeds
    login_success = client.post(
        "/api/v1/auth/login",
        json={
            "email": "kasun.bandara@civilcorp.lk",
            "password": "kasun-super-strong-password-123",
        },
    )
    assert login_success.status_code == 200
    assert "access_token" in login_success.json()


def test_supplier_self_registration_and_rate_limiting(
    test_env: tuple[TestClient, Session, dict[str, str]],
) -> None:
    client, session, _ = test_env

    # 1. Supplier self-registers
    supplier_signup = {
        "email": "procure@apexsteel.lk",
        "password": "apex-steel-secure-password-456",
        "first_name": "Mahesh",
        "last_name": "Senanayake",
        "phone_number": "+94115566778",
        "address": "88 Industrial Estate, Ekala, Ja-Ela",
        "company_name": "Apex Steel Works Ltd",
        "materials_supplied": "TMT Rebar, Mild Steel Bars",
    }
    signup_resp = client.post("/api/v1/auth/signup/supplier", json=supplier_signup)
    assert signup_resp.status_code == 201
    resp_data = signup_resp.json()
    assert resp_data["email"] == "procure@apexsteel.lk"
    assert resp_data["verification_status"] == "PENDING"
    account_id = UUID(resp_data["account_id"])

    # 2. Supplier profile created
    sup_profile = session.scalar(
        select(SupplierProfile).where(SupplierProfile.account_id == account_id)
    )
    assert sup_profile is not None
    assert sup_profile.first_name == "Mahesh"
    assert sup_profile.last_name == "Senanayake"
    assert sup_profile.company_name == "Apex Steel Works Ltd"
    assert sup_profile.contact_person == "Mahesh Senanayake"
    assert sup_profile.materials_supplied == "TMT Rebar, Mild Steel Bars"

    # 3. Test OTP resend cooldown rate limit (immediate request within 60s)
    resend_too_fast = client.post(
        "/api/v1/auth/resend-otp",
        json={"email": "procure@apexsteel.lk"},
    )
    assert resend_too_fast.status_code == 429
    assert "wait" in resend_too_fast.json()["error"]["message"].lower()

    # 4. Find valid OTP code and verify
    otp_record = session.scalar(
        select(AccountOTP)
        .where(AccountOTP.account_id == account_id)
        .order_by(AccountOTP.created_at.desc())
    )
    assert otp_record is not None

    from app.services.otp_service import hash_otp

    actual_code = None
    for candidate in range(1_000_000):
        code_str = f"{candidate:06d}"
        if hash_otp(code_str, account_id) == otp_record.otp_hash:
            actual_code = code_str
            break

    verify_resp = client.post(
        "/api/v1/auth/verify-otp",
        json={"email": "procure@apexsteel.lk", "otp": actual_code},
    )
    assert verify_resp.status_code == 200

    # 5. Supplier can now login
    login_resp = client.post(
        "/api/v1/auth/login",
        json={
            "email": "procure@apexsteel.lk",
            "password": "apex-steel-secure-password-456",
        },
    )
    assert login_resp.status_code == 200
