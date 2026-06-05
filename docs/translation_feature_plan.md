# Khmer-English Translation Feature Plan

Last updated: 2026-06-03
Owner: Mobile FE
Status: Approved by BE, Phase 1/2 FE implementation in progress

## Scope

This plan covers Khmer-English language switching/localization for the mobile app:

- Static UI copy: buttons, labels, empty states, dialogs, snackbars, validation text.
- Runtime language preference: guest and authenticated users.
- Backend-provided content: products, categories, subcategories, promotions, notifications, orders, loyalty/mall content.
- Locale-aware formatting: dates, plural/count labels, currency labels where applicable.

This is not a machine translation feature. Product names, promotion copy, and legal/marketing text should be provided by BE/CMS as reviewed English and Khmer content.

## Research Snapshot

- Flutter's current recommended app-localization path is ARB files with generated localizations through `flutter gen-l10n`. The app already has `flutter.generate: true`, `flutter_localizations`, and `intl`, so the project is ready for this approach.
- `MaterialApp` should receive `localizationsDelegates`, `supportedLocales`, and the selected `locale` so Flutter widgets and generated app strings rebuild correctly.
- Khmer is an officially valid locale via `Locale('km')` / `km-KH`; the app already includes Khmer-capable fonts (`Battambang`, `KhmerOSSiemreap`) and the theme already uses them in font fallback.
- ARB supports placeholders, plurals, select/gender messages, and descriptions, which should be used for dynamic UI strings instead of string concatenation.

References:

- Flutter internationalization guide: https://docs.flutter.dev/ui/internationalization
- Flutter gen-l10n / ARB docs: https://docs.flutter.dev/ui/accessibility-and-internationalization/internationalization
- Dart intl package: https://pub.dev/packages/intl

## Current FE Findings

Already present:

- `pubspec.yaml` includes `flutter_localizations` and `intl`.
- `pubspec.yaml` has `flutter.generate: true`.
- `assets/fonts/Battambang` and `assets/fonts/KhmerOSSiemreap` exist.
- `AppTheme` already sets Khmer font fallbacks globally.
- `showLanguageBottomSheet` exists with English and Khmer options.
- `UserInfoModel` and `UserInfoRepository` already cache a `languageCode`.
- Some backend data models already expose bilingual fields:
  - `CategoryModel`: `nameEn`, `nameKm`
  - `ShopByCategoryModel`: `titleEn`, `titleKm`

Gaps:

- `assets/l10n/` is listed in `pubspec.yaml` but the folder does not exist.
- `MaterialApp` does not set `locale`, `supportedLocales`, or `localizationsDelegates`.
- Language selection is not app-level state. `IndexView` keeps `_languageCode` locally and resets on rebuild/login.
- Login language selector always passes `selectedLanguageCode: 'en'` and does not apply the selected value.
- Most UI strings are hard-coded in widgets. A quick scan found hard-coded user-facing text across at least 48 Dart files.
- Product and subcategory models still expose only `name`; no `nameEn` / `nameKm`.
- Some API calls hardcode English:
  - `AuthService` uses `Accept-Language: en` in several requests.
  - Google Places autocomplete sends `languageCode: 'en'`.
- Current `displayTitle` getters prefer Khmer whenever available, regardless of the selected app language.

## Proposed Architecture

### 1. Add App-Level Locale State

Create a small localization module:

- `LanguageCubit` or `LocaleCubit`
- `LanguageRepository`
- `LanguageCache`
- `SupportedLanguage` enum/value object

Responsibilities:

- Load initial language before `runApp`.
- Persist guest language in `SharedPreferences`.
- Reuse authenticated user's cached preference when available.
- Expose selected `Locale`.
- Rebuild `MaterialApp` when the language changes.
- Notify API layer when `Accept-Language` changes.

Suggested storage:

- Global app language key: `app_language_code`
- Supported values: `en`, `km`
- Normalize inbound values: `en`, `en-US`, `en_US` -> `en`; `km`, `km-KH`, `km_KH`, `kh` -> `km`

### 2. Wire Flutter Localizations

Add:

- `l10n.yaml`
- `lib/l10n/app_en.arb`
- `lib/l10n/app_km.arb`

Then wire `MaterialApp`:

- `locale: Locale(languageCode)`
- `supportedLocales: [Locale('en'), Locale('km')]`
- `localizationsDelegates: AppLocalizations.localizationsDelegates`

Use the generated class everywhere:

```dart
final l10n = AppLocalizations.of(context)!;
Text(l10n.loginPhoneNumberLabel);
```

### 3. Split Static UI from Backend Content

Static UI strings:

- Owned by FE ARB files.
- Reviewed by product/business for Khmer wording.
- Covered by widget tests for locale switching.

Backend content:

- Owned by BE/CMS/admin data.
- FE selects the correct localized field based on current app language.
- FE must never auto-machine-translate backend content.

### 4. Add Localized Value Helpers

For models that have bilingual fields, avoid hardcoding Khmer preference:

```dart
String displayName(String languageCode) {
  if (languageCode == 'km' && nameKm.trim().isNotEmpty) return nameKm.trim();
  if (nameEn.trim().isNotEmpty) return nameEn.trim();
  return nameKm.trim();
}
```

Apply consistently to:

- Categories
- Subcategories
- Products
- Shop-by-category sections
- Promotions/news/notifications
- Loyalty rewards/exchanges/history
- Orders/order items
- Store names, if BE supports Khmer names
- Country names, if shown to users

### 5. Add Locale-Aware API Headers

Update the shared Dio factory to include:

- `Accept-Language: en` or `km`
- Authorization when available

Preferred behavior:

- Every request sends the active language.
- BE can use the header for localized error messages or localized single-field responses.
- FE still prefers bilingual fields where content must be switchable without refetching.

### 6. Make Existing Language Pickers Real

Update the existing bottom sheet to call app-level language state:

- Login screen picker changes guest language immediately.
- Profile language picker changes app language immediately and persists it.
- Burger menu language picker uses the same state.
- Optional: call BE profile update endpoint if BE adds `languageCode` persistence.

## Backend Alignment Needed

Backend has approved the FE plan with canonical FE language codes `en` and
`km`. FE should send `Accept-Language: en` or `Accept-Language: km`; BE may
normalize aliases like `km-KH`, `km_KH`, and `kh` internally.

Confirmed ownership:

- FE owns static UI localization through Flutter ARB/generated localization.
- BE/CMS owns product, category, promotion, loyalty, notification, order, and
  other business content translations.
- FE must not machine-translate backend content.
- Statuses, payment methods, fulfillment states, IDs, and business logic fields
  remain canonical codes; FE localizes display labels locally.
- FE stores language locally first. Cross-device language persistence requires
  BE to add `languageCode` on profile or preferences.

### Preferred Content Contract

BE returns bilingual fields for user-visible content:

```json
{
  "id": 1,
  "nameEn": "Fresh Produce",
  "nameKm": "បន្លែផ្លែឈើស្រស់",
  "descriptionEn": "Fresh vegetables and fruit",
  "descriptionKm": "បន្លែ និងផ្លែឈើស្រស់"
}
```

Reason: FE can switch language instantly without refetching every screen.

### Minimum Required Fields by Resource

Categories:

- `nameEn`
- `nameKm`
- Existing fields remain unchanged.

Subcategories:

- Add `nameEn`
- Add `nameKm`
- Keep `name` temporarily for backward compatibility.

Products:

- Implemented by BE for product endpoints:
  - `name`
  - `nameEn`
  - `nameKm`
  - `descriptionEn`
  - `descriptionKm`
  - `subCategoryName`
  - `subCategoryNameEn`
  - `subCategoryNameKm`
  - `countryOfOrigin`
- Keep `name` temporarily for backward compatibility.
- Product search checks `name`, `nameEn`, and `nameKm`.

Promotions/news/notifications/mall content:

- `titleEn`, `titleKm`
- `descriptionEn`, `descriptionKm`
- `contentEn`, `contentKm` for long-form content

Orders:

- Order status should remain canonical codes, not translated strings:
  - `REQUESTING`
  - `PICKING`
  - `DELIVERING`
  - `DELIVERED`
  - `CANCELED`
- FE translates status labels locally.
- Order item snapshots now support `nameEn` / `nameKm`.
- Order shop snapshots now support `shop.storeNameEn` / `shop.storeNameKm`.

Stores:

- Store selector supports `storeName`, `storeNameEn`, `storeNameKm`,
  `branchLabel`, `branchLabelEn`, and `branchLabelKm`.

Countries:

- Confirm whether `countryOfOrigin` is canonical English only, ISO code, or localized text.
- Preferred: BE returns ISO country code, FE localizes display names.

### Accept-Language Contract

FE will send:

- `Accept-Language: en`
- `Accept-Language: km`

BE should use this header for:

- Error messages, if BE sends user-facing messages.
- Any endpoint that intentionally returns a single localized field.

BE should not use localized strings for business logic fields. Keep canonical codes for statuses, error codes, payment methods, fulfillment stages, and IDs.

### Profile Preference Contract

Question for BE:

- Should user language preference be stored in profile?
- If yes, confirm request/response shape:

```json
{
  "languageCode": "km"
}
```

Suggested endpoint options:

- Include `languageCode` in existing profile update endpoint.
- Or add `PATCH /user/me/preferences`.

### Error Message Contract

Preferred FE behavior:

- FE uses `errorCode` to show local ARB messages for known errors.
- BE `errorMsg` is fallback/debug text.
- If BE intentionally sends user-facing error/alert copy, either return stable
  `errorCode` values or localize the text by `Accept-Language`.

Ask BE to confirm stable error codes for auth, order, profile, favorite, and validation flows.

### Current BE Rollout Notes

Already bilingual or partially bilingual:

- Categories support `nameEn` / `nameKm`.
- Shop-by-category supports `titleEn` / `titleKm`.
- Product endpoints now return `nameEn`, `nameKm`, `descriptionEn`,
  `descriptionKm`, `subCategoryNameEn`, and `subCategoryNameKm`:
  - `GET /products`
  - `GET /products/{id}`
  - `GET /products/by-barcode/{code}`
  - `GET /categories/{categoryId}/products`
  - `GET /subcategories/{subCategoryId}/products`
  - `GET /shop-by-categories/{shopByCategoryId}/products`
- Product search now checks `name`, `nameEn`, and `nameKm`; Khmer keyword
  results depend on Khmer product names being populated in CMS/admin data.
- Stores now return `storeNameEn`, `storeNameKm`, `branchLabelEn`, and
  `branchLabelKm`.
- Orders now return localized shop snapshots through
  `shop.storeNameEn` / `shop.storeNameKm` and item snapshots through
  `item.nameEn` / `item.nameKm`.
- Loyalty rewards/exchanges now return `titleEn` / `titleKm`,
  `categoryLabelEn` / `categoryLabelKm`, `pointConditionEn` /
  `pointConditionKm`, and `termsAndConditionsEn` / `termsAndConditionsKm`.
- User profile supports `languageCode` through `GET /user/me` and
  `PUT /user/me`.

Pending BE fields or confirmation:

- Subcategories: add `nameEn`, `nameKm`.
- Promotions/notifications: add `titleEn`, `titleKm`, `descriptionEn`,
  `descriptionKm`, optional `contentEn`, `contentKm`.
- Loyalty history status labels: keep canonical status code stable so FE can
  localize labels locally, or provide bilingual display labels if BE-managed.
- Country of origin: prefer ISO country code so FE can localize country names.
- Filters should use IDs/canonical codes, not localized display strings.

FE rollout fallback during migration:

- If selected language is Khmer and Khmer field exists, show Khmer.
- Otherwise fall back to English.
- If English is missing but Khmer exists, show Khmer.
- Keep legacy `name`, `title`, and `description` fields working until BE migration
  is complete.

## Implementation Phases

### Phase 1: Foundation

- Add `l10n.yaml` and ARB files.
- Create locale state/cache/repository.
- Wire `MaterialApp` localization delegates and selected locale.
- Update existing language selectors to use app-level state.
- Add tests for initial language load and switching.

### Phase 2: Shared UI Copy

- Localize global/common strings:
  - Login/signup/OTP
  - Navigation labels
  - Profile/settings/language/logout
  - Cart/checkout/order status
  - Common buttons and empty states
  - Snackbars/toasts/dialogs
- Replace hard-coded date/month/status labels with localized helpers.

### Phase 3: Backend Content Model Updates

After BE confirms fields:

- Update models to parse bilingual fields while preserving old fields:
  - Product
  - Subcategory
  - Promotions/news/notifications
  - Loyalty/mall content
  - Order item snapshots
- Add `displayX(languageCode)` helpers.
- Update views to use selected language.

### Phase 4: API Language Header

- Inject active language into shared Dio headers.
- Replace hardcoded `Accept-Language: en` in `AuthService`.
- Make Google Places `languageCode` follow selected language.
- Add tests for header generation where feasible.

### Phase 5: QA and Regression

- Run Flutter analyzer and tests.
- Add widget tests that pump English and Khmer locales.
- Manually verify:
  - Login language switch
  - Profile language switch
  - Product/category names
  - Cart/checkout/order history
  - Long Khmer text wrapping
  - Input fields with Khmer IME
  - Guest -> login language preservation

## Rollout Strategy

Recommended rollout:

1. Implement FE static localization foundation first.
2. Keep old backend fields working while BE adds bilingual fields.
3. Release FE with fallback behavior:
   - If Khmer field missing, show English.
   - If English field missing, show Khmer.
4. Once BE confirms coverage, switch screens to localized dynamic fields.

## Acceptance Criteria

- User can switch English/Khmer from login, profile, and burger menu.
- The selected language persists after app restart.
- `MaterialApp.locale` updates immediately after language change.
- Static UI text uses generated localization strings.
- Backend user-facing content displays the selected language where BE provides fields.
- Missing translations gracefully fall back to English.
- API requests send the selected `Accept-Language`.
- Existing auth, cart, checkout, favorites, and order tests still pass.
- Khmer text renders cleanly with no clipped glyphs in primary screens.

## Open Questions for Backend

1. Will BE return bilingual fields for products, subcategories, promotions, notifications, loyalty rewards, order item snapshots, and stores?
2. Should user language preference be saved on BE profile, or only locally on the device?
3. Are backend `errorCode` values stable enough for FE-localized error messages?
4. For product search, when will keyword search match both English and Khmer names?
5. Should `countryOfOrigin` become an ISO country code so FE can localize country names?
6. Can BE keep legacy single-language fields during migration so current app versions continue working?

## Recommended Backend Reply Format

Ask BE to reply with:

- Supported language codes:
- Endpoints already returning bilingual fields:
- Endpoints needing migration:
- Profile language persistence: yes/no
- Error localization strategy: FE by `errorCode` or BE by `Accept-Language`
- Product/search behavior for Khmer keywords:
- Target date for bilingual field availability:
