# Auth Refresh Token Contract (FE ↔ BE)

## Goal
Allow users to stay logged in without manual re-login every day by using:
- short-lived `accessToken`
- long-lived `refreshToken`

## 1) Login/Signup OTP success response (update)

### Existing endpoints
- `POST /auth/login/verify-otp`
- `POST /auth/signup/verify-otp`

### Required fields on success
```json
{
  "success": true,
  "errorCode": "",
  "errorMsg": "",
  "accessToken": "eyJhbGciOi...",
  "refreshToken": "rft_...",
  "accessTokenExpiresInSeconds": 3600,
  "refreshTokenExpiresInSeconds": 2592000
}
```

### Notes
- `accessToken` should be short-lived (recommended: 15m-60m).
- `refreshToken` should be long-lived (recommended: 30-90 days).
- `refreshToken` should be rotatable (new refresh token on every refresh call).

## 2) Refresh endpoint (new)

### Request
- Method: `POST`
- Path: `/auth/refresh`
- Auth: no bearer required (token-based refresh body)

```json
{
  "refreshToken": "rft_..."
}
```

### Success response
```json
{
  "success": true,
  "errorCode": "",
  "errorMsg": "",
  "accessToken": "eyJhbGciOi...",
  "refreshToken": "rft_new_...",
  "accessTokenExpiresInSeconds": 3600,
  "refreshTokenExpiresInSeconds": 2592000
}
```

### Error response examples
```json
{
  "success": false,
  "errorCode": "AUTH401",
  "errorMsg": "Unauthorized"
}
```

```json
{
  "success": false,
  "errorCode": "REFRESH_INVALID",
  "errorMsg": "Refresh token is invalid."
}
```

```json
{
  "success": false,
  "errorCode": "REFRESH_EXPIRED",
  "errorMsg": "Refresh token expired."
}
```

## 3) Logout endpoint (recommended)

### Request
- Method: `POST`
- Path: `/auth/logout`
- Auth: Bearer token

```json
{
  "refreshToken": "rft_..."
}
```

### Behavior
- Invalidate refresh token (server-side revoke).
- Access token can expire naturally.

## 4) FE expected runtime behavior

1. FE calls protected endpoint with `accessToken`.
2. If response is `401` (`AUTH401`), FE calls `/auth/refresh` using saved `refreshToken`.
3. If refresh succeeds:
   - FE stores new `accessToken` (+ rotated `refreshToken` if returned).
   - FE retries original request once.
4. If refresh fails (`REFRESH_INVALID`/`REFRESH_EXPIRED`):
   - FE clears session.
   - redirect to login.

## 5) Security requirements

- Refresh token must be revocable server-side.
- Refresh token rotation strongly recommended.
- Bind refresh token to device/session metadata when possible.
- Return consistent `errorCode` values for FE handling.

## 6) Acceptance criteria

- User remains logged in across days until refresh token expires or logout.
- Normal API calls do not require manual re-login after access token expiry.
- Refresh flow is transparent to user (silent retry).
