# Favorites FE/BE Alignment

Last updated: 2026-05-16
Owner: Mobile FE

## Resolution Snapshot

BE confirmed and fixed the favorites persistence issue. Root cause was backend startup SQL dropping/recreating `UserFavorites`, which could wipe favorites after API restart. BE replaced that startup behavior with a non-destructive migration.

## FE Changes Implemented

- Favorites API calls now retry once after refreshing the access token when BE returns HTTP `401`, `AUTH401`, or `UNAUTHORIZED`.
- FE no longer wipes local favorites when `GET /favorites` unexpectedly returns an empty list while local saved favorites exist.
- In that case FE calls `POST /favorites/sync` with the local favorite IDs, then verifies with another `GET /favorites`.
- FE now uses idempotent `PUT /favorites/{productId}` and `DELETE /favorites/{productId}` for add/remove writes.
- Pending retry logic uses idempotent add/remove endpoints instead of replaying legacy toggle requests.

## BE Confirmed

1. `GET /favorites` must be scoped by authenticated user ID from the bearer token.
2. Expired or invalid access tokens must return HTTP `401` or an explicit auth error, never `{ success: true, data: { items: [] } }`.
3. `POST /favorites/sync` must merge/upsert product IDs only. It must not delete favorites that are omitted from the request.
4. No scheduled job, TTL, logout handler, token refresh handler, or guest migration flow should delete rows from the favorites table.
5. Favorite rows should not be tied to access-token lifetime, refresh-token lifetime, session ID, device ID, or guest temp ID after login migration.
6. `POST /favorites/sync` returns `insertedCount` and `existingCount`.

## Recommended Backend Contract

### List

`GET /favorites`

Success:

```json
{
  "success": true,
  "data": {
    "items": [
      { "productId": 101 }
    ]
  }
}
```

Auth failure:

```json
{
  "success": false,
  "errorCode": "AUTH401",
  "errorMsg": "Unauthorized"
}
```

### Add Favorite

`PUT /favorites/{productId}`

Calling this repeatedly should always leave the item favorited.

### Remove Favorite

`DELETE /favorites/{productId}`

Calling this repeatedly should always leave the item not favorited.

### Sync Guest Favorites After Login

`POST /favorites/sync`

Request:

```json
{
  "productIds": [101, 102]
}
```

Expected behavior:

- Upsert these IDs for the authenticated user.
- Do not delete any existing favorite rows.
- Return inserted/existing counts for debugging.

Response:

```json
{
  "success": true,
  "data": {
    "insertedCount": 1,
    "existingCount": 1
  }
}
```

## Debug Checklist

Ask BE to inspect the affected user around the disappearance time:

- Favorite table audit logs, if available.
- Any delete SQL involving favorites.
- Any cleanup job running overnight.
- Whether `GET /favorites` returned empty because auth failed, user ID resolved incorrectly, or rows were actually deleted.
- Whether `POST /favorites/sync` ever performs replace/delete semantics.
- Whether startup migrations are non-destructive in every environment.
