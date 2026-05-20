# LifeTours — AGENTS.md

## Project status

Early development. Models are defined in `lib/models/` with a barrel export (`models.dart`). Screens are built in `lib/screens/` with a barrel export. `lib/services/` is empty — no Firebase service layer written yet. `lib/main.dart` has been adapted from the default counter: it initializes Firebase (with error catch for unconfigured environments), sets up GoRouter with all screen routes, and renders the app. No providers configured yet.

## Architecture

- **State management**: Provider (not yet wired — `MultiProvider` placeholder ready)
- **Routing**: GoRouter (routes defined in `lib/main.dart`)
- **Backend**: Firebase (Core, Auth, Firestore, Storage)
- **SDK**: `>=3.2.0 <4.0.0`
- **Lints**: `package:flutter_lints/flutter.yaml` (default Flutter rules)
- **Theme**: `lib/theme.dart` — `AppColors` class with green primary, salmon red, greys

## Package

- **Android application ID / iOS bundle identifier**: `com.life.tours` (changed from `com.example.lifetours`)
- **Dart package name**: `lifetours` (used in `package:lifetours/...` imports)
- `google-services.json` lives at `android/app/google-services.json`

## Screens (`lib/screens/`)

All 9 screens from `pantallas.md` are implemented as standalone widgets:

| File | Route | Description |
|---|---|---|
| `landing_screen.dart` | `/` | Welcome — "Life Tours" title, Crear Cuenta / Iniciar Sesion |
| `login_screen.dart` | `/login` | Login form |
| `discover_screen.dart` | `/discover` | Category grid 2×2 + scrollable search section |
| `catalog_screen.dart` | `/catalog` | Tours catalog with banner and destination cards |
| `destination_detail_screen.dart` | `/destination-detail` | Barcelona detail, activities chips, Reservar |
| `review_screen.dart` | `/review` | Write review with bubble icon |
| `profile_screen.dart` | `/profile` | Account menu, admin panel access, logout |
| `admin_panel_screen.dart` | `/admin` | Table management list (Usuarios, Destinos, etc.) |
| `table_management_screen.dart` | `/admin/users` | DataTable with sample rows, CRUD buttons |

Screens share a common bottom nav bar via `lib/widgets/bottom_nav_bar.dart`.

## Models

- Every model extends `Equatable` and implements `fromMap`, `fromDocumentSnapshot`, `toMap`, `copyWith`.
- Firestore field name constants are in `firestore_constants.dart` — use `FirestoreCollections.{collection}` and `{Model}Fields.{field}` instead of raw strings.
- Enums with string serialization (`TourCategory`, `ReservationStatus`) use an `Extension` pattern with `fromString` / `.name`.
- `favorites` is a **subcollection** under `users/{uid}/favorites/{tourId}`.
- Denormalized fields (`userName`, `tourTitle`, etc.) are stored in Firestore documents for read efficiency.

## Data model (Firestore collections)

| Collection | Path |
|---|---|
| users | `users/{uid}` |
| favorites | `users/{uid}/favorites/{tourId}` (subcollection) |
| destinations | `destinations/{destinationId}` |
| tours | `tours/{tourId}` |
| reservations | `reservations/{reservationId}` |
| reviews | `reviews/{reviewId}` |

See `FIRESTORE_SCHEMA.md` for full field schemas and security rules.

## Commands

| Command | Purpose |
|---|---|
| `flutter run` | Run app |
| `flutter test` | Run all tests |
| `flutter analyze` | Run linter/analyzer |
| `flutter pub get` | Install deps |
| `flutter build web` | Build for web deployment |

## Conventions

- Import models via `package:lifetours/models/models.dart`.
- Import screens via `package:lifetours/screens/screens.dart`.
- Firestore queries should use Firestore field constants, not inline strings.
- New enum types with string serialization should follow the `Extension + fromString` pattern in `tour_model.dart` / `reservation_model.dart`.
- New models should extend `Equatable` and include `fromMap`, `toMap`, `copyWith`.
- Project documentation files (`proyecto.md`, `FIRESTORE_SCHEMA.md`) are in **Spanish**.

## Firebase / Seed data

- **Firebase project**: `lifetours-452a8` (Android: `com.life.tours`, iOS: `com.life.tours`)
- **API Key**: `AIzaSyBSYwJYwOswrZkBiEP7OVufVYfPiGw_daw` (from `google-services.json`)
- **Firestore**: Enabled with sample data (5 destinations, 11 tours, 3 reservations, 3 reviews, 2 favorites)

### Test credentials

| Role   | Email                 | Password   | UID      |
|--------|-----------------------|------------|----------|
| Admin  | admin@lifetours.com   | Admin123!  | admin001 |
| User   | maria@example.com     | Test123!   | user001  |

Both users exist in Firebase Auth (emailVerified=true) and Firestore `users/{uid}`.

## Gotchas

- `lib/services/` is empty — any Firebase service code needs to be written from scratch.
- No providers are configured yet. Add them inside `MultiProvider` in `main.dart` when ready.
- `firebase_core` initialization in `main.dart` wraps in try-catch — safe to run without Firebase credentials.
- GoRouter routes are defined in `main.dart`; new screens need a route entry there.
- The single test (`test/widget_test.dart`) tests the Landing screen renders.
- Assets are loaded from `assets/images/` and `assets/icons/`.
- No GitHub Actions or CI workflows present.
