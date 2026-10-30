# Civil Construction Site Management System - Backend API

Enterprise-grade FastAPI backend for the **Civil Construction Site Management System**.  
Provides centralized operations management for construction sites, worker/labour allocations, suppliers, procurement requisitions, quotation workflows, project logbooks, and marketplace orders with Role-Based Access Control (**Admin**, **Supervisor**, **Labour**, **Supplier**).

Interactive API documentation (Swagger) is available at: **`http://127.0.0.1:8000/docs`**

---

## 1. Prerequisites

Before setting up the backend, ensure you have:
- **Python 3.11** or **Python 3.12** installed (`python --version` or `py -0p`)
- **PostgreSQL** running locally on port `5432` (or access to a remote PostgreSQL instance)
- **Git**

---

## 2. Quick Setup Guide (Step-by-Step)

Follow these steps in your terminal to set up and run the backend from scratch:

### Step 1: Open Terminal & Navigate to Project
```powershell
cd E:\Civil-app
```

### Step 2: Create & Activate Virtual Environment

**On Windows (PowerShell):**
```powershell
py -3.12 -m venv .venv
.\.venv\Scripts\Activate.ps1
```

**On macOS / Linux (Bash/Zsh):**
```bash
python3 -m venv .venv
source .venv/bin/activate
```

### Step 3: Install Dependencies
```powershell
python -m pip install --upgrade pip
pip install -e ".[dev]"
```

### Step 4: Configure Environment Variables
Copy the example environment configuration:

**On Windows (PowerShell):**
```powershell
if (-not (Test-Path .env)) { Copy-Item .env.example .env }
```

**On macOS / Linux:**
```bash
cp -n .env.example .env
```

Open `.env` and verify your PostgreSQL connection in `DATABASE_URL`:
```ini
DATABASE_URL=postgresql+psycopg://app:admin@localhost:5432/auth_1
JWT_SECRET_KEY=c86rptFxZbuQ5KTN1X0n9ZmQ_kTMukHEzg_kKaikhybMa_2iNzFt8zPJvxtYasYR
CORS_ORIGINS=["*"]
DOCS_ENABLED=true
```
*(Ensure the database `auth_1` exists in PostgreSQL or create it: `CREATE DATABASE auth_1;`)*

### Step 5: Apply Database Migrations
Run Alembic migrations to create all database tables:
```powershell
alembic upgrade head
```

### Step 6: Seed Demo Accounts & Data
Populate the database with pre-configured demo users and mock data matching the Flutter frontend demo chips:
```powershell
python -m app.database.seed
```

### Step 7: Start the FastAPI Backend Server
```powershell
uvicorn app.main:app --host 127.0.0.1 --port 8000 --reload
```

The API will now be live at:
- **Base URL**: `http://127.0.0.1:8000/api/v1`
- **Health Check**: `http://127.0.0.1:8000/api/v1/health`
- **Swagger Documentation**: `http://127.0.0.1:8000/docs`
- **ReDoc Documentation**: `http://127.0.0.1:8000/redoc`

---

## 3. Pre-Seeded Test Credentials

Use these credentials to sign in directly from the Flutter frontend or Swagger UI:

| Role | Email / Phone | Password | Features / Access |
|---|---|---|---|
| **Admin** | `admin@siteapp.lk` | `admin123` | Full system access, all dashboards, reports, and management |
| **Site Supervisor** | `supervisor@siteapp.lk` | `super123` | Project logbook, attendance toggle, requisitions, site tracking |
| **Labourer / Worker** | `labour@siteapp.lk`<br>*(or `0771234567`)* | `labour123`<br>*(or `123456`)* | Assigned site card, attendance status, profile & skills update |
| **Supplier / Vendor** | `supplier@siteapp.lk`<br>*(or `0773344556`)* | `supplier123`<br>*(or `123456`)* | Open requisitions, quote submission, delivery history |
| **Food Vendor** | `food@labourpro.lk` | `food123` | Site meal orders and food supply management |

*(Legacy accounts `jana@labourpro.lk`, `perera@supplies.lk`, etc. with password `123456` are also seeded).*

---

## 4. Automated Testing & Verification

Run the full pytest integration test suite to verify that all endpoints and security policies pass:

```powershell
pytest -v
```

To run code formatting and linting:
```powershell
ruff check .
ruff format --check .
```

---

## 5. Flutter Frontend Integration

When running the Flutter app:
- **Web / Chrome / Desktop**: Connects to `http://127.0.0.1:8000/api/v1`
- **Android Emulator**: Connects to `http://10.0.2.2:8000/api/v1`
- **Physical Device**: Connects to `http://<your-lan-ip>:8000/api/v1`

### Running the Frontend
```powershell
cd Civil-frontend\Site-App
flutter pub get
flutter run -d chrome
```

---

## 6. Available Backend Modules & Endpoints

| Module | Endpoints | Description |
|---|---|---|
| **Authentication** | `POST /api/v1/auth/login`<br>`POST /api/v1/auth/unified-signup`<br>`GET /api/v1/auth/me` | JWT login (email or phone), self-registration, user profile |
| **Sites** | `GET /api/v1/sites`<br>`POST /api/v1/sites`<br>`PATCH /api/v1/sites/{id}` | Construction site lifecycle, stages, progress, and budgets |
| **Labour** | `GET /api/v1/labour`<br>`POST /api/v1/labour`<br>`PATCH /api/v1/labour/{id}` | Labour profile management, site allocation, attendance toggle |
| **Suppliers** | `GET /api/v1/suppliers`<br>`POST /api/v1/suppliers`<br>`PATCH /api/v1/suppliers/{id}` | Supplier company directory, supplied categories, bank details |
| **Material Requests** | `GET /api/v1/material-requests`<br>`POST /api/v1/material-requests` | Requisitions, preferred supplier tagging, urgency tracking |
| **Quotations** | `POST /api/v1/material-requests/{id}/responses` | Supplier bids, pricing, delivery lead times, approval flow |
| **Project Logbook** | `GET /api/v1/logbook`<br>`POST /api/v1/logbook`<br>`POST /api/v1/logbook/{id}/comments` | Daily site logs, photos, comments, supervisor acknowledgement |
| **Marketplace** | `GET /api/v1/marketplace/rentals`<br>`GET /api/v1/marketplace/food-orders` | Equipment rental catalog, site meal and catering orders |
| **Dashboards & Reports** | `GET /api/v1/dashboard/*`<br>`GET /api/v1/reports/summary` | Role-specific dashboard statistics and executive summary reports |
| **Notifications** | `GET /api/v1/notifications`<br>`POST /api/v1/notifications/{id}/read` | In-app alerts, unread counts, and mark-as-read actions |
