"""Database seeder populating data matching Flutter frontend SeedData & DemoAccounts."""

from datetime import UTC, date, datetime
from decimal import Decimal
from uuid import uuid4

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.database.session import SessionLocal
from app.models.account import Account, AccountRole
from app.models.labour import LabourProfile, LabourStatus
from app.models.logbook import LogbookCategory, LogbookComment, ProjectLogbookEntry
from app.models.marketplace import EquipmentRental, FoodSupplyOrder
from app.models.material_request import MaterialRequest, MaterialRequestStatus
from app.models.site import ConstructionSite, SiteStatus
from app.models.supplier import SupplierProfile, SupplierStatus
from app.models.supplier_response import AvailabilityStatus, ResponseStatus, SupplierResponse
from app.security.password import hash_password


def seed_database(db: Session) -> None:
    print("Starting database seeding...")
    default_pwd_hash = hash_password("123456")

    # 1. Accounts
    demo_users = [
        {"email": "jana@labourpro.lk", "role": AccountRole.ADMIN.value, "phone": "0771234567", "name": "Jana Kumaran"},
        {"email": "admin@siteapp.lk", "role": AccountRole.ADMIN.value, "phone": "0770001122", "name": "Engineer Admin"},
        {"email": "niroshan@labourpro.lk", "role": AccountRole.SUPERVISOR.value, "phone": "0772223344", "name": "K. Niroshan"},
        {"email": "supervisor@siteapp.lk", "role": AccountRole.SUPERVISOR.value, "phone": "0772345678", "name": "K. Sivaram"},
        {"email": "thavarasa@labourpro.lk", "role": AccountRole.LABOUR.value, "phone": "0773334455", "name": "S. Thavarasa"},
        {"email": "labour@siteapp.lk", "role": AccountRole.LABOUR.value, "phone": "0771234567", "name": "S. Thavarasa Demo"},
        {"email": "supplier@labourpro.lk", "role": AccountRole.SUPPLIER.value, "phone": "0774445566", "name": "Nimal Fernando"},
        {"email": "supplier@siteapp.lk", "role": AccountRole.SUPPLIER.value, "phone": "0773456789", "name": "Jaffna Hardware"},
        {"email": "food@labourpro.lk", "role": AccountRole.FOOD_SUPPLIER.value, "phone": "0775556677", "name": "Razaak Caterers"},
    ]

    account_map: dict[str, Account] = {}
    for u in demo_users:
        existing = db.scalar(select(Account).where(Account.email == u["email"]))
        if not existing:
            acc = Account(
                email=u["email"],
                password_hash=default_pwd_hash,
                role=u["role"],
                is_active=True,
                is_verified=True,
                verification_status="VERIFIED",
            )
            db.add(acc)
            db.flush()
            account_map[u["email"]] = acc
        else:
            existing.password_hash = default_pwd_hash
            existing.is_active = True
            existing.is_verified = True
            existing.verification_status = "VERIFIED"
            account_map[u["email"]] = existing

    # 2. Construction Sites
    sites_data = [
        {
            "site_name": "Jaffna School Project",
            "project_name": "Jaffna School Project",
            "site_address": "Chavakachcheri Road, Jaffna",
            "client_name": "Northern Education Department",
            "start_date": date(2026, 10, 20),
            "expected_completion_date": date(2027, 4, 20),
            "status": SiteStatus.ACTIVE.value,
            "progress": 0.42,
            "contract_value": "LKR 89,500,000",
            "cost_spent": "LKR 21.4M",
            "margin": 18.0,
            "labour_count": "22 / 40",
            "image_url": "https://images.unsplash.com/photo-1541888946425-d0fbb18615f3?w=500",
            "supervisor_name": "K. Niroshan",
            "supervisor_phone": "0772223344",
            "description": "Three-storey modern secondary school building including 18 classrooms, science labs, and auditorium.",
        },
        {
            "site_name": "Ladies Hostel Project",
            "project_name": "Ladies Hostel Project",
            "site_address": "University Road, Jaffna",
            "client_name": "University Grants Commission",
            "start_date": date(2026, 5, 10),
            "expected_completion_date": date(2027, 2, 28),
            "status": SiteStatus.ACTIVE.value,
            "progress": 0.68,
            "contract_value": "LKR 45,000,000",
            "cost_spent": "LKR 28.5M",
            "margin": 22.0,
            "labour_count": "18 / 25",
            "image_url": "https://images.unsplash.com/photo-1590381105924-c72589b9ef3f?w=500",
            "supervisor_name": "K. Sivaram",
            "supervisor_phone": "0772345678",
            "description": "4-storey residential university hostel with dining hall and student amenities.",
        },
        {
            "site_name": "Factory Project",
            "project_name": "Factory Project",
            "site_address": "Industrial Zone, Atchuvely",
            "client_name": "Apex Industries Ltd",
            "start_date": date(2026, 8, 1),
            "expected_completion_date": date(2027, 8, 30),
            "status": SiteStatus.ACTIVE.value,
            "progress": 0.25,
            "contract_value": "LKR 120,000,000",
            "cost_spent": "LKR 31.0M",
            "margin": 15.0,
            "labour_count": "30 / 60",
            "image_url": "https://images.unsplash.com/photo-1504307651254-35680f356dfd?w=500",
            "supervisor_name": "K. Niroshan",
            "supervisor_phone": "0772223344",
            "description": "Pre-engineered steel building with heavy concrete flooring.",
        },
    ]

    site_map: dict[str, ConstructionSite] = {}
    for s_info in sites_data:
        existing_site = db.scalar(select(ConstructionSite).where(ConstructionSite.site_name == s_info["site_name"]))
        if not existing_site:
            site_obj = ConstructionSite(
                site_name=s_info["site_name"],
                project_name=s_info["project_name"],
                site_address=s_info["site_address"],
                client_name=s_info["client_name"],
                start_date=s_info["start_date"],
                expected_completion_date=s_info["expected_completion_date"],
                status=s_info["status"],
                progress=s_info["progress"],
                contract_value=s_info["contract_value"],
                cost_spent=s_info["cost_spent"],
                margin=s_info["margin"],
                labour_count=s_info["labour_count"],
                image_url=s_info["image_url"],
                supervisor_name=s_info["supervisor_name"],
                supervisor_phone=s_info["supervisor_phone"],
                stages=[
                    "Site Preparation",
                    "Foundation",
                    "Structural Work",
                    "Block Work",
                    "Plastering",
                    "Electrical & Plumbing",
                    "Finishing & Handover",
                ],
                description=s_info["description"],
            )
            db.add(site_obj)
            db.flush()
            site_map[s_info["site_name"]] = site_obj
        else:
            site_map[s_info["site_name"]] = existing_site

    # 3. Labour / Professional Profiles
    school_site = site_map["Jaffna School Project"]
    ladies_hostel = site_map.get("Ladies Hostel Project", school_site)
    labourers_data = [
        {
            "email": "thavarasa@labourpro.lk",
            "name": "S. Thavarasa",
            "phone": "0773334455",
            "job_role": "Mason Leader",
            "skills": "Bricklaying, Plastering, Scaffolding",
            "daily_wage": 3500.0,
            "address": "Navanthurai, Jaffna",
            "site_id": school_site.id,
        },
        {
            "email": "labour@siteapp.lk",
            "name": "S. Thavarasa",
            "phone": "0771234567",
            "job_role": "Steel Fixer",
            "skills": "Rebar bending, Binding, Tying",
            "daily_wage": 3200.0,
            "address": "Kopay, Jaffna",
            "site_id": school_site.id,
        },
        {
            "email": "niroshan@labourpro.lk",
            "name": "K. Niroshan",
            "phone": "0772223344",
            "job_role": "Site Supervisor",
            "skills": "Site Management, QA/QC, Safety Compliance",
            "daily_wage": 5500.0,
            "address": "Nallur, Jaffna",
            "site_id": school_site.id,
        },
        {
            "email": "supervisor@siteapp.lk",
            "name": "K. Sivaram",
            "phone": "0772345678",
            "job_role": "Site Supervisor",
            "skills": "Supervision, Logbook, Structural QA",
            "daily_wage": 6000.0,
            "address": "Hospital Road, Jaffna",
            "site_id": ladies_hostel.id,
        },
        {
            "email": "admin@siteapp.lk",
            "name": "Engineer Admin",
            "phone": "0770001122",
            "job_role": "General Contractor / Admin",
            "skills": "Project Management, Procurement, Cost Control",
            "daily_wage": 10000.0,
            "address": "Main Street, Jaffna",
            "site_id": None,
        },
        {
            "email": "jana@labourpro.lk",
            "name": "Jana Kumaran",
            "phone": "0771234567",
            "job_role": "Executive Project Director",
            "skills": "Civil Engineering, CIDA Management",
            "daily_wage": 12000.0,
            "address": "Colombo 03",
            "site_id": None,
        },
    ]

    for l_data in labourers_data:
        acc = account_map.get(l_data["email"])
        if acc:
            existing_labour = db.scalar(select(LabourProfile).where(LabourProfile.account_id == acc.id))
            if not existing_labour:
                labour_obj = LabourProfile(
                    account_id=acc.id,
                    current_site_id=l_data["site_id"],
                    full_name=l_data["name"],
                    phone_number=l_data["phone"],
                    address=l_data["address"],
                    job_role=l_data["job_role"],
                    skills=l_data["skills"],
                    experience_years=5,
                    daily_wage=l_data["daily_wage"],
                    has_attended_today=True,
                    emergency_contact="0779998877",
                    status="Active",
                )
                db.add(labour_obj)

    # 4. Supplier Profiles
    suppliers_data = [
        {
            "email": "supplier@labourpro.lk",
            "company_name": "Jaffna Building Supplies",
            "contact_person": "Nimal Fernando",
            "phone": "0774445566",
            "address": "Stanley Road, Jaffna",
            "materials": "Cement, Sand, Steel Rebars, Gravel",
        },
        {
            "email": "supplier@siteapp.lk",
            "company_name": "Jaffna Hardware",
            "contact_person": "Jaffna Hardware",
            "phone": "0773456789",
            "address": "Power House Road, Jaffna",
            "materials": "Cement, Steel Rebars, Hollow Blocks, Sand",
        },
        {
            "email": "food@labourpro.lk",
            "company_name": "Northern Site Food Services",
            "contact_person": "Razaak Caterers",
            "phone": "0775556677",
            "address": "Navanthurai, Jaffna",
            "materials": "Workforce Catering, Site Meals, Tea Service",
        },
    ]

    supplier_obj = None
    for s_data in suppliers_data:
        supp_acc = account_map.get(s_data["email"])
        if supp_acc:
            existing_supp = db.scalar(select(SupplierProfile).where(SupplierProfile.account_id == supp_acc.id))
            if not existing_supp:
                s_prof = SupplierProfile(
                    account_id=supp_acc.id,
                    company_name=s_data["company_name"],
                    contact_person=s_data["contact_person"],
                    phone_number=s_data["phone"],
                    email=s_data["email"],
                    address=s_data["address"],
                    company_registration_details="PV-998877",
                    materials_supplied=s_data["materials"],
                    bank_payment_info="Commercial Bank - 1002345678",
                    company_status="Active",
                )
                db.add(s_prof)
                db.flush()
                if s_data["email"] == "supplier@labourpro.lk":
                    supplier_obj = s_prof
            else:
                if s_data["email"] == "supplier@labourpro.lk":
                    supplier_obj = existing_supp

    # 5. Material Requests & Supplier Responses
    req = db.scalar(select(MaterialRequest).where(MaterialRequest.material_name == "ReadyMix Concrete Grade 25"))
    if not req:
        req = MaterialRequest(
            site_id=school_site.id,
            assigned_supplier_id=supplier_obj.id if supplier_obj else None,
            material_name="ReadyMix Concrete Grade 25",
            material_category="Concrete",
            required_quantity=Decimal("40.0"),
            unit="m³",
            required_date=date(2026, 11, 15),
            description="Grade 25 mix with 20mm aggregate for 1st-floor slab casting.",
            additional_notes="Deliver with 30m pump car.",
            status=MaterialRequestStatus.RESPONDED.value,
        )
        db.add(req)
        db.flush()

        if supplier_obj:
            resp = SupplierResponse(
                request_id=req.id,
                supplier_id=supplier_obj.id,
                available_quantity=Decimal("40.0"),
                unit_price=Decimal("28500.00"),
                total_price=Decimal("1140000.00"),
                delivery_date=date(2026, 11, 14),
                delivery_details="Direct delivery via 4 truck mixers + pump unit",
                availability_status=AvailabilityStatus.AVAILABLE.value,
                additional_notes="Standard slump 100±25mm. Admixture included.",
                status=ResponseStatus.SUBMITTED.value,
            )
            db.add(resp)

    # 6. Project Logbook Entries
    log_entry = db.scalar(select(ProjectLogbookEntry).where(ProjectLogbookEntry.title == "Level 1 Slab Rebar Inspection"))
    if not log_entry:
        log_entry = ProjectLogbookEntry(
            site_id=school_site.id,
            entry_date=datetime.now(UTC),
            author_name="K. Sivaram",
            author_role="Consultant / Resident Engineer",
            category=LogbookCategory.INSPECTION_QA.value,
            title="Level 1 Slab Rebar Inspection",
            description="Reinforcement checked against structural drawing ST-04. Lap lengths and spacer block placement verified with zero defects.",
            photo_urls=["https://images.unsplash.com/photo-1541888946425-d0fbb18615f3?w=500"],
            attachments=[{"name": "Inspection_Report_ST04.pdf", "size": "1.2 MB", "extension": "pdf"}],
            linked_items=["ST-04 Structural Sheet", "Concrete Casting Approval"],
            is_acknowledged=True,
            acknowledged_by="Jana Kumaran (Project Admin)",
            acknowledged_at=datetime.now(UTC),
        )
        db.add(log_entry)
        db.flush()

        comment = LogbookComment(
            entry_id=log_entry.id,
            author_name="K. Niroshan",
            author_role="Site Supervisor",
            text="Cover blocks verified at 25mm bottom cover. Ready for concrete pour tomorrow 7:00 AM.",
        )
        db.add(comment)

    # 7. Equipment Rentals
    rental_items = [
        {"name": "CAT 320 Hydraulic Excavator", "category": "Excavator", "rate": Decimal("45000.00"), "stock": 2, "rental": 1},
        {"name": "Concrete Mixer 1-Bag Diesel", "category": "Mixer", "rate": Decimal("3500.00"), "stock": 5, "rental": 2},
        {"name": "Heavy Duty Steel Scaffolding (100 Sets)", "category": "Scaffolding", "rate": Decimal("12500.00"), "stock": 8, "rental": 4},
        {"name": "Hydraulic Telescopic Jacks 3.5m", "category": "Jacks", "rate": Decimal("150.00"), "stock": 300, "rental": 150},
    ]
    for r_item in rental_items:
        existing_rental = db.scalar(select(EquipmentRental).where(EquipmentRental.name == r_item["name"]))
        if not existing_rental:
            db.add(
                EquipmentRental(
                    name=r_item["name"],
                    category=r_item["category"],
                    daily_rate=r_item["rate"],
                    available_stock=r_item["stock"],
                    on_rental_count=r_item["rental"],
                )
            )

    # 8. Food Supply Orders
    food_order = db.scalar(select(FoodSupplyOrder).where(FoodSupplyOrder.site_id == school_site.id))
    if not food_order:
        db.add(
            FoodSupplyOrder(
                site_id=school_site.id,
                meal_type="Lunch",
                portions=25,
                delivery_date=date.today(),
                delivery_time="12:30 PM",
                status="Preparing",
                total_cost=Decimal("11250.00"),
            )
        )

    db.commit()
    print("Database seeding complete!")


if __name__ == "__main__":
    session = SessionLocal()
    try:
        seed_database(session)
    finally:
        session.close()
