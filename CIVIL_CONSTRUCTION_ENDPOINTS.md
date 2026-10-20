# Civil Construction Site Management System: API Endpoints

This document provides API documentation for the Civil Construction Site Management System built on FastAPI and PostgreSQL.

All requests requiring authentication must supply a bearer token header:
`Authorization: Bearer <access_token>`

---

## 1. Construction Site Management (`/api/v1/sites`)

### `POST /api/v1/sites`
* **Role Required:** `admin`
* **Description:** Create a new construction project site.
* **Request Body:**
```json
{
  "site_name": "Colombo Port City",
  "project_name": "Financial Centre Phase 1",
  "site_address": "Port City, Colombo 01",
  "client_name": "CHEC Port City Colombo",
  "start_date": "2026-02-01",
  "expected_completion_date": "2028-12-31",
  "status": "Active",
  "description": "Modern coastal commercial complex"
}
```
* **Response (`201 Created`):** Site object with `id`, timestamps, and `assigned_labourer_count`.

### `GET /api/v1/sites`
* **Role Required:** `admin`
* **Query Params:** `status`, `search`, `limit`, `offset`
* **Response (`200 OK`):** List of sites matching the criteria.

### `GET /api/v1/sites/{site_id}`
* **Role Required:** `admin`
* **Response (`200 OK`):** Detailed site info.

### `PATCH /api/v1/sites/{site_id}`
* **Role Required:** `admin`
* **Request Body:** Partial update fields (`site_name`, `status`, `description`, etc.).

### `GET /api/v1/sites/{site_id}/labourers`
* **Role Required:** `admin`
* **Response (`200 OK`):** Array of all labourers assigned to this site.

### `GET /api/v1/sites/assigned/me`
* **Role Required:** `labour`
* **Description:** Returns the site profile to which the logged-in worker is currently assigned (or `null` if unassigned).

---

## 2. Labour Management (`/api/v1/labour`)

### `POST /api/v1/labour`
* **Role Required:** `admin`
* **Description:** Creates an account (`role: labour`) and registers their profile.
* **Request Body:**
```json
{
  "email": "kamal.fernando@civilcorp.com",
  "password": "kamal-secure-pwd-1234",
  "full_name": "Kamal Fernando",
  "nic_number": "199023456789",
  "phone_number": "+94719876543",
  "address": "45 Peradeniya Road, Kandy",
  "job_role": "Steel Fixer",
  "skills": "Rebar bending, Reinforcement tying",
  "experience_years": 4,
  "joining_date": "2026-01-10",
  "emergency_contact": "Kumari Fernando (+94719876540)",
  "current_site_id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
  "status": "Active"
}
```
* **Response (`201 Created`):** Complete labourer profile. Sends automatic notification to worker.

### `GET /api/v1/labour`
* **Role Required:** `admin`
* **Query Params:** `site_id`, `status`, `job_role`, `search`, `limit`, `offset`
* **Response (`200 OK`):** List of labourers with current site details.

### `GET /api/v1/labour/me`
* **Role Required:** `labour`
* **Response (`200 OK`):** Own profile and assigned site details.

### `PATCH /api/v1/labour/me`
* **Role Required:** `labour`
* **Description:** Update personal contact details (`phone_number`, `address`, `emergency_contact`, `profile_photo`).

### `GET /api/v1/labour/{labour_id}`
* **Role Required:** `admin`

### `PATCH /api/v1/labour/{labour_id}`
* **Role Required:** `admin`
* **Description:** Update worker info or status.

### `POST /api/v1/labour/{labour_id}/assign-site`
* **Role Required:** `admin`
* **Request Body:** `{"site_id": "<uuid-or-null>"}`
* **Description:** Assigns or reassigns worker to a site. Dispatches notifications.

---

## 3. Supplier Management (`/api/v1/suppliers`)

### `POST /api/v1/suppliers`
* **Role Required:** `admin`
* **Description:** Creates an account (`role: supplier`) and registers company profile.
* **Request Body:**
```json
{
  "email": "orders@tokyocement.lk",
  "password": "tokyo-cement-pass-1234",
  "company_name": "Tokyo Super Cement",
  "contact_person": "Ruwan Jayasinghe",
  "phone_number": "+94119876543",
  "address": "469 Sri Sangaraja Mawatha, Colombo 10",
  "company_registration_details": "PV-998877",
  "materials_supplied": "Cement, Ready Mix, Mortar",
  "bank_payment_info": "BOC 0012345678",
  "company_status": "Active"
}
```

### `GET /api/v1/suppliers`
* **Role Required:** `admin`
* **Query Params:** `status`, `search`, `limit`, `offset`

### `GET /api/v1/suppliers/me`
* **Role Required:** `supplier`
* **Response (`200 OK`):** Own company profile.

### `PATCH /api/v1/suppliers/me`
* **Role Required:** `supplier`
* **Description:** Update own company details.

### `GET /api/v1/suppliers/{supplier_id}`
* **Role Required:** `admin`

### `PATCH /api/v1/suppliers/{supplier_id}`
* **Role Required:** `admin`

### `POST /api/v1/suppliers/{supplier_id}/toggle-status`
* **Role Required:** `admin`
* **Description:** Toggle supplier `Active` $\leftrightarrow$ `Inactive`.

---

## 4. Material Request Requisitions (`/api/v1/material-requests`)

### `POST /api/v1/material-requests`
* **Role Required:** `admin`
* **Request Body:**
```json
{
  "site_id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
  "material_name": "Cement OPC 42.5N",
  "material_category": "Cement",
  "required_quantity": 100.0,
  "unit": "Bags",
  "required_date": "2026-05-15",
  "description": "High early strength ordinary portland cement",
  "additional_notes": "Deliver in palletized bags"
}
```
* **Response (`201 Created`):** Automatically notifies all active suppliers.

### `GET /api/v1/material-requests`
* **Role Required:** `admin` or `supplier`
* **Query Params:** `site_id`, `status`, `material_category`, `search`, `limit`, `offset`

### `GET /api/v1/material-requests/{request_id}`
* **Role Required:** `admin` or `supplier`

### `PATCH /api/v1/material-requests/{request_id}`
* **Role Required:** `admin`

### `DELETE /api/v1/material-requests/{request_id}`
* **Role Required:** `admin`

---

## 5. Supplier Quotations (`/api/v1/supplier-responses`)

### `POST /api/v1/material-requests/{request_id}/responses`
* **Role Required:** `supplier`
* **Request Body:**
```json
{
  "available_quantity": 100.0,
  "unit_price": 2450.00,
  "total_price": 245000.00,
  "delivery_date": "2026-05-14",
  "delivery_details": "Direct transport via 10-wheel flatbed lorry",
  "availability_status": "Available",
  "additional_notes": "Prices valid for 14 days"
}
```
* **Response (`201 Created`):** Updates material request status to `Responded`; notifies Admins.

### `GET /api/v1/material-requests/{request_id}/responses`
* **Role Required:** `admin`
* **Description:** Admin reviews all competitive supplier bids for this material request.

### `GET /api/v1/supplier-responses/me`
* **Role Required:** `supplier`
* **Description:** Lists all quotation bids submitted by the logged-in supplier.

### `GET /api/v1/supplier-responses/{response_id}`
* **Role Required:** `admin` or the submitting `supplier`
* **Security:** Enforces strict isolation; other suppliers receive `403 Forbidden`.

### `POST /api/v1/supplier-responses/{response_id}/review`
* **Role Required:** `admin`
* **Request Body:**
```json
{
  "action": "Accepted",
  "admin_notes": "Best price and delivery schedule approved"
}
```
* **Response (`200 OK`):** Marks response `Accepted`, marks material request `Approved`, and notifies supplier.

---

## 6. Dashboards (`/api/v1/dashboard`)

### `GET /api/v1/dashboard/admin`
* **Role Required:** `admin`
* **Returns:**
  - `total_sites`, `active_sites`
  - `total_labourers`, `active_labourers`
  - `total_suppliers`, `active_suppliers`
  - `pending_material_requests`, `pending_supplier_responses`, `completed_material_requests`

### `GET /api/v1/dashboard/labour`
* **Role Required:** `labour`
* **Returns:** Profile, assigned site info, unread notifications count, recent alerts.

### `GET /api/v1/dashboard/supplier`
* **Role Required:** `supplier`
* **Returns:** Company profile, open request count, submitted count, accepted count, unread alerts.

---

## 7. Notifications (`/api/v1/notifications`)

* `GET /api/v1/notifications` — List notifications with `unread_only=true` filter.
* `GET /api/v1/notifications/unread-count` — Count of unread notifications.
* `POST /api/v1/notifications/{notification_id}/read` — Mark single notification as read.
* `POST /api/v1/notifications/read-all` — Mark all as read.

---

## 8. Reports (`/api/v1/reports`)

### `GET /api/v1/reports/summary`
* **Role Required:** `admin`
* **Returns:**
  - `sites_by_status`: Count of sites grouped by status.
  - `site_labour_distribution`: Worker headcount per site.
  - `requests_by_category`: Requisitions aggregated by material category and volume.
  - `supplier_performance`: Quotation volume, accepted vs rejected counts.
