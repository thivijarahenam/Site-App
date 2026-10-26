# Ahenam Technology — Civil Construction & Site Operations (Frontend)

Cross-platform Flutter application for Civil Construction & Site Operations, featuring tailored role portals for:
- 👷 **Labour (Field Workforce & Trades)**
- 📋 **Site Supervisor (Oversight & Site Diary)**
- 🚚 **Supplier (Materials & RFQ Quotations)**
- 🏢 **Admin / General Contractor (Master Management)**

---

## 🚀 Key Features

1. **Role Landing Portal**:
   - On app launch, users choose their role:
     - `Work as a Labour`
     - `Work as a Supervisor`
     - `Work as a Supplier`
     - `Work as an Admin`
   - Dedicated portal per role with consistent, minimalist, modern styling.

2. **Stepper Registration with Skip Option**:
   - **Step 1 (Account Essentials)**: Full Name, Mobile Phone, Email, Residential/Office Address, Password.
   - **Step 2 (Trade & Professional Profile)**:
     - **Labour**: Trade role, years of experience, daily wage expectation, specific skills tags, emergency contact.
     - **Supplier**: Company/hardware shop name, warehouse address, years in business, materials supplied.
     - **Supervisor**: Supervisory experience, technical qualification, specialization, safety certification.
     - **Admin**: Construction company name, office address, CIDA/ICTAD grading, business registration number.
   - **Skip Option**: Users can skip Step 2 and immediately create their account to enter the app. A "Profile Incomplete" banner appears on the dashboard with a 1-tap "Complete Profile" bottom sheet modal to update and save at any time.

3. **Role Dashboards**:
   - **Admin**: Construction sites, multi-project oversight, labour force, material requests, cost & budget tracking.
   - **Supervisor**: Daily site diary, progress reports, labour calling, RFQ approvals.
   - **Labour**: Assigned project details, attendance check-in, daily wage summary, emergency contacts.
   - **Supplier**: Material RFQs, price quotation submissions, delivery dispatch tracker.

4. **Design System**:
   - Built with Flutter Material 3, modern minimalist typography (`Plus Jakarta Sans`), sleek monochrome slate styling (`#0F172A`), and clean subtle role accents.

---

## 🛠️ How to Run Locally

### Requirements
- Flutter SDK 3.3.0 or higher
- Android Studio / VS Code / Chrome / Edge

```bash
# Get dependencies
flutter pub get

# Run on Web (port 8085)
flutter run -d web-server --web-port 8085

# Run on Chrome
flutter run -d chrome

# Run on Android Device / Emulator
flutter run -d android

# Build Release APK
flutter build apk --release
```

---

## 🧪 Demo Accounts (1-Tap Login)

Each role has an instant 1-tap demo chip in the Sign-In screen:

| Role | Name | Phone / Email | Password |
|---|---|---|---|
| **Labour** | S. Thavarasa | `0771234567` / `labour@siteapp.lk` | `123456` |
| **Supervisor** | K. Sivaram | `0772345678` / `supervisor@siteapp.lk` | `123456` |
| **Supplier** | Jaffna Hardware | `0773456789` / `supplier@siteapp.lk` | `123456` |
| **Admin** | Engineer Admin | `0770001122` / `admin@siteapp.lk` | `123456` |

---

## 🔌 Backend Team Integration Points

The frontend models and providers are located at:
- `lib/models/models.dart`: Data models matching the SRS schemas (`AppUser`, `ConstructionSite`, `LabourProfile`, `SupplierProfile`, `MaterialRequest`, `LogbookEntry`, etc.)
- `lib/providers/auth_provider.dart`: Authentication state management (`login`, `registerUser`, `updateUser`, `logout`).
- `lib/providers/app_data_provider.dart`: Mock repository ready to be swapped with HTTP / Dio API clients targeting the `civil-backend` FastAPI services.
- `docs/`: Complete SRS specifications and developer handover documentation.
