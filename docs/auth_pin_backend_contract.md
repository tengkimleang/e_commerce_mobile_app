# Auth PIN Contract (FE ↔ BE)

## Goal
Use phone + PIN for normal login.
Use OTP only for signup verification and forgot-PIN recovery.

## Flow Summary
1. Signup: request OTP -> verify OTP -> set PIN.
2. Login: phone -> verify PIN (no OTP).
3. Forgot PIN: request OTP -> verify OTP -> reset PIN.

## 1) Login with PIN

### Request
- Method: `POST`
- Path: `/auth/login/verify-pin`
- Auth: none
```json
{
  "phoneNumber": "012345678",
  "pinCode": "1234"
}
```

### Success Response
```json
{
  "success": true,
  "errorCode": "",
  "errorMsg": "",
  "accessToken": "eyJhbGciOi...",
  "refreshToken": "rft_...",
  "accessTokenExpiresInSeconds": 3600,
  "refreshTokenExpiresInSeconds": 2592000,
  "data": {
    "fullName": "Jame Sbone",
    "phoneNumber": "012345678"
  }
}
```

## 2) Set PIN after Signup OTP

### Request
- Method: `POST`
- Path: `/auth/pin/set`
- Auth: Bearer token from signup OTP verify
```json
{
  "pinCode": "1234",
  "confirmPinCode": "1234"
}
```

### Success Response
```json
{
  "success": true,
  "errorCode": "",
  "errorMsg": ""
}
```

## 3) Forgot PIN OTP

### Request OTP
- Method: `POST`
- Path: `/auth/pin/forgot/request-otp`
- Auth: none
```json
{
  "phoneNumber": "012345678"
}
```

### Verify OTP
- Method: `POST`
- Path: `/auth/pin/forgot/verify-otp`
- Auth: none (or per BE design)
```json
{
  "phoneNumber": "012345678",
  "otpCode": "1234"
}
```

## 4) Reset PIN after Forgot OTP

### Request
- Method: `POST`
- Path: `/auth/pin/reset`
- Auth: Bearer from verify-otp or reset token per BE design
```json
{
  "pinCode": "5678",
  "confirmPinCode": "5678"
}
```

## Error Codes FE Needs
- `AUTH401`
- `USR404`
- `PIN_INVALID`
- `PIN_NOT_SET`
- `PIN_LOCKED`
- `OTP404`
- `OTP002`
- `OTP003`
- `OTP004`

