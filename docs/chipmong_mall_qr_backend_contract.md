# Chip Mong Mall QR Backend Contract

## Goal
When a customer opens the Chip Mong Mall QR tab, the app displays a QR code.
When cashier scans that QR, cashier system can fetch and display:
- `username`
- `tierLevel`
- `membershipId`

## 1) Mobile App Endpoint (Generate QR Data)

### Request
- Method: `GET`
- Path: `/user/me/mall-qr`
- Auth: `Authorization: Bearer <token>`

### Success Response (200)
```json
{
  "success": true,
  "errorCode": "",
  "errorMsg": "",
  "data": {
    "username": "Jame",
    "tierLevel": "LifeStyle",
    "membershipId": "224256797",
    "membershipType": "LifeStyle Member",
    "points": 30,
    "qrToken": "eyJhbGciOi..."
  }
}
```

### Notes
- Preferred: return `qrToken` (short-lived, signed).
- Optional: return `qrPayload` if backend wants full encoded payload control.
- If both exist, app will prioritize `qrPayload`.

## 2) Cashier Endpoint (Verify Scanned QR)

### Request
- Method: `POST`
- Path: `/cashier/qr/verify`
- Auth: cashier/POS auth token

```json
{
  "qrToken": "eyJhbGciOi..."
}
```

### Success Response (200)
```json
{
  "success": true,
  "errorCode": "",
  "errorMsg": "",
  "data": {
    "username": "Jame",
    "tierLevel": "LifeStyle",
    "membershipId": "224256797",
    "membershipType": "LifeStyle Member",
    "isActive": true
  }
}
```

### Invalid / Expired Response (200 or 4xx based on backend standard)
```json
{
  "success": false,
  "errorCode": "QR_EXPIRED",
  "errorMsg": "QR token expired."
}
```

## 3) QR Payload Format in App
Current app behavior:
- If backend returns `qrPayload`: app encodes that directly into QR.
- Else if backend returns `qrToken`: app generates payload as:
  - `cmr://chipmong-mall/member?token=<qrToken>`
- Fallback only (temporary): app can use membership id payload.

## 4) Security Requirements
- `qrToken` should be signed and tamper-proof.
- Token should be short-lived (recommended: 60-180 seconds).
- Token should be one-time or replay-protected when possible.
- Do not expose full customer profile directly inside QR text.
