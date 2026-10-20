# Backend environment setup (Windows / PowerShell)

Follow these steps on each developer machine. This guide sets up the Python backend only; it does not install or configure the separate Flutter application.

## 1. Install and verify Python

Install CPython 3.12 (3.11 or newer is supported) and make sure the Python Launcher is available. Open a **new** PowerShell window after installation, then check:

```powershell
py -0p
py -3.12 --version
```

The first command should list an installed Python runtime. If it reports `No installed Pythons found`, install CPython; do not continue to the virtual environment step yet. If `python.exe` opens the Microsoft Store, that command is an App Execution Alias, not an installed interpreter. The `py -3.12` command above avoids relying on that alias.

## 2. Open the backend folder

Change to the folder containing `pyproject.toml`:

```powershell
Set-Location E:\Civil-app
```

Use your actual checkout path if the repository is somewhere else.

## 3. Create and activate a virtual environment

Run these commands once per checkout:

```powershell
py -3.12 -m venv .venv
.\.venv\Scripts\Activate.ps1
python --version
```

The prompt should show `(.venv)` and the version should be Python 3.12. If PowerShell blocks activation scripts, you can skip activation and use the full `.venv\Scripts\python.exe` path in the commands below.

## 4. Install backend dependencies

With the environment activated:

```powershell
python -m pip install --upgrade pip
python -m pip install -e ".[dev]"
```

Without activation, use:

```powershell
.\.venv\Scripts\python.exe -m pip install --upgrade pip
.\.venv\Scripts\python.exe -m pip install -e ".[dev]"
```

This installs FastAPI, Uvicorn, SQLAlchemy, Alembic, Psycopg, pytest, HTTPX, and Ruff into the project environment.

## 5. Create local configuration

Create `.env` from the example only if it does not already exist. This avoids overwriting local settings:

```powershell
if (-not (Test-Path .env)) { Copy-Item .env.example .env }
```

The health endpoint does not require PostgreSQL. Database-backed features and migrations do require a reachable PostgreSQL database and a correct `DATABASE_URL` in `.env`. Never commit `.env` or put real credentials in `.env.example`.

Before using authentication, generate a unique signing key and set it in `.env`:

```powershell
python -c "import secrets; print(secrets.token_urlsafe(48))"
```

Copy the generated value into `JWT_SECRET_KEY`. Treat it as a secret and do not commit it. The auth API contract is in `AUTH_ENDPOINTS.md`.

For browser-based clients, set `CORS_ORIGINS` to a JSON array of exact allowed origins, for example:

```dotenv
CORS_ORIGINS=["https://frontend.example.com"]
```

Native Flutter apps do not use browser CORS. Do not use `*` as a production origin.

## 6. Start the development server

With `.venv` activated:

```powershell
python -m uvicorn app.main:app --reload
```

Or without activation:

```powershell
.\.venv\Scripts\python.exe -m uvicorn app.main:app --reload
```

Keep this terminal open while using the API. Stop the server with `Ctrl+C`.

## 7. Verify the API

Open these addresses in a browser:

- Health check: `http://127.0.0.1:8000/api/v1/health` — expected response: `{"status":"ok"}`
- Interactive API docs: `http://127.0.0.1:8000/docs`
- OpenAPI JSON: `http://127.0.0.1:8000/openapi.json`

Requests to `/` or `/doc` return `404`; those routes are not part of this API. Use `/docs` or the versioned health URL above.

For an Android emulator, the local API host is usually `http://10.0.2.2:8000/api/v1`. A physical phone needs the development computer's LAN address, and both devices must be able to reach each other on the network.

## 8. Run tests and lint checks

Open another PowerShell window, change to the backend folder, and activate `.venv` again (or use the full paths):

```powershell
python -m pytest
python -m ruff check .
python -m ruff format --check .
```

## 9. Database migrations (only after PostgreSQL is configured)

Set `DATABASE_URL` in `.env` to a private PostgreSQL database before running migrations:

```powershell
alembic upgrade head
```

After the migration succeeds, create the initial administrator through the interactive prompt:

```powershell
python -m app.security.bootstrap_admin
```

The bootstrap command asks for the admin email and a password of at least 14 characters, then asks for confirmation. It does not print or store the plaintext password. Use the admin account to create labour and supplier accounts through the admin-protected endpoint.

After adding or changing SQLAlchemy models, generate a migration and review it before applying:

```powershell
alembic revision --autogenerate -m "describe schema change"
alembic upgrade head
```

The starter has no application tables yet, so there is no initial schema migration to apply. Do not expose PostgreSQL publicly.

## Troubleshooting

### `No suitable Python runtime found`

The Python Launcher cannot find the requested version. Install CPython 3.12, open a new terminal, verify with `py -0p`, then rerun the virtual environment command.

### `Python was not found` or Microsoft Store opens

The `python` App Execution Alias is active but no system Python is registered. Install CPython and use `py -3.12` to create `.venv`. Once `.venv` exists, the full `.venv\Scripts\python.exe` command works without changing the Windows alias.

### `Activate.ps1` cannot run

Skip activation and use the virtual environment's Python executable directly. For example:

```powershell
.\.venv\Scripts\python.exe -m pytest
.\.venv\Scripts\python.exe -m uvicorn app.main:app --reload
```

### `No module named pip`

Bootstrap pip inside the environment, then install the project dependencies:

```powershell
.\.venv\Scripts\python.exe -m ensurepip --upgrade
.\.venv\Scripts\python.exe -m pip install -e ".[dev]"
```

### `Address already in use`

Another process is using port 8000. Stop that server with `Ctrl+C`, or start this one on a different local port:

```powershell
python -m uvicorn app.main:app --reload --port 8001
```

