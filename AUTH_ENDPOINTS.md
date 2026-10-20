# Authentication API endpoints

## POST `/api/v1/auth/login`

**Authentication:** None. Users sign in with their email address as the username and their chosen password.

Request:

```json
{"email": "worker@example.com", "password": "a-long-user-selected-password"}
```

Success (`200`): access token, refresh token, token type, and access-token lifetime.

Errors: `401` invalid credentials or inactive account; `422` invalid request; `429` temporary account lockout; `503` JWT signing key is not configured.

## POST `/api/v1/auth/refresh`

**Authentication:** None; requires a valid, unused refresh token. Each successful call rotates the token. Reuse of a revoked token revokes its token family.

Request: `{"refresh_token": "<opaque-refresh-token>"}`

Success (`200`): same token response shape as `/login`.

Errors: `401` invalid, expired, or reused refresh token; `422` invalid request; `503` JWT signing key is not configured.

## POST `/api/v1/auth/logout`

**Authentication:** None; revokes the supplied refresh token. Safe to repeat. The current access JWT remains valid until it expires.

Request: `{"refresh_token": "<opaque-refresh-token>"}`

Success: `204 No Content`.

## GET `/api/v1/auth/me`

**Authentication:** `Authorization: Bearer <access_token>`

Success (`200`): current account profile, role, activation status, and creation time.

Errors: `401` missing, invalid, expired, revoked-by-password-change, or inactive-account token.

## POST `/api/v1/auth/users`

**Authentication:** `Authorization: Bearer <access_token>`; role `admin` required. Public registration is not available. Creates a pending account and emails a one-time invitation link. The admin does not set or receive the user's password.

Request:

```json
{"email": "supplier@example.com", "role": "supplier"}
```

Allowed roles: `admin`, `labour`, `supplier`.

Success (`201`): account profile with `is_active: false` until invitation acceptance.

Errors: `401` missing or invalid access token; `403` caller is not an admin; `409` email already exists; `422` invalid request; `503` account-link signing secret is not configured.

## POST `/api/v1/auth/users/{account_id}/invitation`

**Authentication:** Admin bearer token required. Resends the invitation for a pending account; the previous invitation link is invalidated. Resends are rate-limited.

Success (`202`): generic message that an invitation will be sent if the account is awaiting setup.

Errors: `401` unauthenticated; `403` caller is not an admin; `422` invalid account ID; `503` account-link signing secret is not configured.

## POST `/api/v1/auth/invitations/accept`

**Authentication:** None. The mobile app receives the invitation link through a verified app link, extracts its token, and submits the token with the user's chosen password. The token is single-use and expires after 24 hours. On success the account becomes active; the user can then sign in with their email and password.

Request:

```json
{"token": "<invitation-token>", "new_password": "a-long-user-selected-password"}
```

Success (`200`): `{"message": "Account setup complete; sign in with your email and password."}`

Errors: `400` invalid, expired, or already-used invitation; `422` invalid request; `503` account-link signing secret is not configured.

## POST `/api/v1/auth/password`

**Authentication:** `Authorization: Bearer <access_token>`

Request:

```json
{"current_password": "the-current-password", "new_password": "a-different-long-password"}
```

Passwords must be 12–128 characters. A successful password change revokes refresh tokens and invalidates existing access tokens; sign in again.

Success (`200`): `{"message": "Password changed; sign in again"}`.

Errors: `400` current password is incorrect; `401` missing or invalid access token; `422` invalid request.

## POST `/api/v1/auth/password-reset/request`

**Authentication:** None. Requests a one-time password reset link for an active account. The response is identical whether the email belongs to an account or not. Links expire after 15 minutes; requests are rate-limited.

Request: `{"email": "worker@example.com"}`

Success (`202`): `{"message": "If an active account exists for that email, a password reset link will be sent."}`

Errors: `422` invalid email; `503` account-link signing secret is not configured.

## POST `/api/v1/auth/password-reset/confirm`

**Authentication:** None. The mobile app receives the verified app link, extracts its token, and submits it with the new password. The link is single-use. On success, existing sessions are revoked and the user must sign in again.

Request:

```json
{"token": "<password-reset-token>", "new_password": "a-different-long-password"}
```

Success (`200`): `{"message": "Password reset successfully; sign in again"}`.

Errors: `400` invalid, expired, or already-used reset link; `422` invalid request; `503` account-link signing secret is not configured.

## Error response format

```json
{"error": {"code": "http_error", "message": "Insufficient permissions"}}
```
