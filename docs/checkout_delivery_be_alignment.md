# Checkout + Delivery FE/BE Alignment (Pre-Implementation)

Last updated: 2026-05-13
Owner: Mobile FE

## 0) BE Confirmation Snapshot (Received)

Backend confirmed completed implementation:
- New Orders module + startup wiring + DB entities.
- Tables/indexes created at startup: `Orders`, `OrderItems`, and key indexes.
- Endpoints ready:
  - `POST /orders`
  - `GET /orders?page=1&pageSize=20`
  - `GET /orders/{orderId}`
  - `POST /orders/promo/validate`
- Constraints:
  - Bearer token required for all orders endpoints.
  - `Idempotency-Key` required for `POST /orders`.
  - Payment method currently supports only `COD`.
  - Promo codes currently: `ABC10`, `SAVE5`, `FREESHIP`.
- Response envelope:
  - `{ success, errorCode, errorMsg, data }`
  - Unauthorized -> HTTP `401`
  - Business validation errors -> HTTP `200` with `success=false`.

## 0.1) FE Integration Progress (Implemented)

The following FE wiring is now implemented:
- Checkout submit now calls `POST /orders` with Bearer token + `Idempotency-Key`.
- Promo apply now calls `POST /orders/promo/validate`.
- Order summary parsing now reads backend status/track fields.
- Track screen now refreshes via `GET /orders/{orderId}` using `orderId` string.
- Order history cubit now loads from `GET /orders`.

## 1) Current FE Status (What is already done)

UI for the following is complete:
- Checkout screen with map, route line, delivery info, order items, promo input, pricing, and `Place Order`.
- Order success dialog with `Track Order`.
- Order tracking screen with map + route + step bar + order detail sections.
- Order history and order detail screens.

Current behavior is still mock/local (not backend-connected):
- `CheckoutCubit.placeOrder()` generates local order data only (no API call).
- Order number is local incremental (`00001`, `00002`, ...).
- Promo apply is mock (`promoDiscount` remains `0.0`).
- Track step is currently hardcoded to `requesting`.
- Order history is local in-memory + fallback sample orders.
- Delivery addresses are local SQLite storage.

## 2) Current FE Flow (Reference)

1. User goes Cart -> Checkout.
2. FE reads selected shop (`shopId`, lat/lng) and selected address (lat/lng, phone, name).
3. FE draws route on map using Google Routes API (direct FE call).
4. User can enter promo code (currently no real validation).
5. User taps `Place Order`.
6. FE currently creates local `OrderSummary`, clears cart, shows success popup.
7. User taps `Track Order`, opens order track screen.

## 3) Proposed Backend Contract (v1)

Use existing API response convention in app:
- Success/business envelope: `errorCode`, `errorMsg`, `data`.
- Business errors may still come with HTTP 200; FE checks `errorCode`.

### 3.1 Create Order

`POST /orders`

Headers:
- `Authorization: Bearer <token>`
- `Idempotency-Key: <uuid>` (required to prevent duplicate orders on retry)

Request body:
```json
{
  "shopId": "271MALL",
  "deliveryAddressId": "addr_123",
  "deliveryContactName": "Royal Hospital",
  "deliveryPhone": "03048343",
  "deliveryAddressText": "Royal Phnom Penh Hospital, Khan Sensok, Phnom Penh",
  "deliveryLatitude": 11.6123,
  "deliveryLongitude": 104.8865,
  "promoCode": "ABC10",
  "paymentMethod": "COD",
  "items": [
    {
      "productId": "1",
      "quantity": 1
    },
    {
      "productId": "2",
      "quantity": 1
    }
  ]
}
```

Response body (`data`):
```json
{
  "orderId": "ord_01J...",
  "orderNumber": "00001",
  "status": "REQUESTING",
  "orderDateUtc": "2026-05-13T03:51:00Z",
  "shop": {
    "shopId": "271MALL",
    "storeName": "CHIP MONG 271 MEGA MALL",
    "latitude": 11.5589,
    "longitude": 104.9103
  },
  "delivery": {
    "addressId": "addr_123",
    "nameAddress": "Royal Hospital",
    "address": "Royal Phnom Penh Hospital, Khan Sensok, Phnom Penh",
    "phoneNumber": "03048343",
    "latitude": 11.6123,
    "longitude": 104.8865
  },
  "items": [
    {
      "productId": "1",
      "name": "Vital Water",
      "imageUrl": "https://...",
      "unitPrice": 100.0,
      "quantity": 1,
      "lineTotal": 100.0
    }
  ],
  "pricing": {
    "subtotal": 117.0,
    "deliveryFee": 1.59,
    "packageFees": 0.10,
    "discount": 0.0,
    "promoDiscount": 0.0,
    "total": 118.69,
    "currency": "USD"
  },
  "paymentMethod": "COD",
  "track": {
    "step": "REQUESTING"
  }
}
```

### 3.2 Validate Promo

`POST /orders/promo/validate`

Request:
```json
{
  "shopId": "271MALL",
  "promoCode": "ABC10",
  "items": [
    { "productId": "1", "quantity": 1 }
  ]
}
```

Response `data`:
```json
{
  "valid": true,
  "promoCode": "ABC10",
  "discountAmount": 2.0,
  "message": "Promo applied"
}
```

### 3.3 Order Detail / Track

`GET /orders/{orderId}`

Must return the same shape as create order + current tracking step:
- `REQUESTING`
- `PICKING`
- `DELIVERING`
- `DELIVERED`
- Optional terminal: `CANCELED`

### 3.4 Order Status Updates

Option A (fastest): polling
- FE polls `GET /orders/{orderId}` every 10-15 seconds while tracking page is open.

Option B (better UX): push
- WebSocket/SSE topic: `orders/{orderId}/status`.

### 3.5 Order History

`GET /orders?page=1&pageSize=20`

Response `data`:
```json
{
  "items": [
    {
      "orderId": "ord_01J...",
      "orderNumber": "00001",
      "status": "REQUESTING",
      "orderDateUtc": "2026-05-13T03:51:00Z",
      "shopName": "CHIP MONG 271 MEGA MALL",
      "total": 118.69,
      "itemCount": 2
    }
  ],
  "total": 1
}
```

## 4) Required BE Confirmations Before FE Integration

1. Status enum and transitions:
   - Exact allowed states and terminal states.
2. Pricing source of truth:
   - BE must return final pricing; FE should display BE-calculated numbers.
3. Promo behavior:
   - Validation rule, expiry handling, invalid code error format.
4. Out-of-stock at checkout:
   - Partial fulfillment allowed or hard reject?
5. Duplicate place-order prevention:
   - Confirm `Idempotency-Key` behavior and replay response.
6. Tracking updates:
   - Polling only (v1) or push available now.
7. Address source:
   - Keep local address book for now, or migrate to BE address endpoint.

## 5) Implementation Plan (Aligned FE/BE)

Phase 1: API contract lock (0.5-1 day)
- FE + BE finalize request/response schemas and enums.
- BE shares endpoint paths and example payloads.

Phase 2: Backend endpoints ready (1-3 days)
- `POST /orders`
- `POST /orders/promo/validate`
- `GET /orders/{orderId}`
- `GET /orders`

Phase 3: FE integration (1-2 days)
- Replace mock place order in `CheckoutCubit` with repository call.
- Map BE response into `OrderSummary`.
- Replace hardcoded track step with BE step.
- Replace local history fallback with API list.

Phase 4: Joint QA + edge cases (1 day)
- Invalid promo
- Out-of-stock on submit
- Retry/tap multiple times
- Unauthorized token refresh
- Network timeout and offline recovery

## 6) Message To Backend Team (Ready To Send)

Hi BE team,

Checkout + Delivery UI is completed on mobile FE, and we’re ready to integrate. Before coding starts, can we align on API contract and status flow for orders?

From FE side, current screens are done:
- Checkout (map route, delivery info, item list, pricing, promo input, place order)
- Success popup + Track Order
- Order Track (step bar + map + order details)
- Order History / Order Detail

What we need from BE to start integration:
- `POST /orders` (create order, return final order summary + status)
- `POST /orders/promo/validate`
- `GET /orders/{orderId}` (track/detail)
- `GET /orders` (history list)

Please confirm:
1. Order status enum + transitions (`REQUESTING`, `PICKING`, `DELIVERING`, `DELIVERED`, `CANCELED`?)
2. Pricing source of truth from BE (subtotal/fees/discount/total)
3. Promo validation response/error format
4. Out-of-stock behavior at order submit (partial vs reject)
5. Idempotency support for `POST /orders` (we will send `Idempotency-Key`)
6. Track update mechanism for v1 (polling is acceptable if push is not ready)

Once confirmed, FE can start API integration immediately.

Thanks.

## 7) Staff Approval Status (Confirmed by BE on 2026-05-13)

Canonical statuses returned by `GET /orders` and `GET /orders/{orderId}`:
- `REQUESTING`
- `PICKING`
- `DELIVERING`
- `DELIVERED`
- `CANCELED`

Current backend behavior:
- New orders are created as `REQUESTING`.
- Staff approve/reject/cancel transition endpoint is not implemented yet.
- `track.step` mirrors `status` (or falls back to `status`).

FE display mapping (1:1 with current backend):
- `REQUESTING` -> `Request`
- `PICKING`, `DELIVERING`, `DELIVERED` -> `Ordered`
- `CANCELED` -> `Cancel`
