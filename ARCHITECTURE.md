# AnuMealAI — Architectural Design & Specification

## 1. Architectural Philosophy

AnuMealAI adheres to **Clean Architecture** combined with **Feature-First modularization** and the **BLoC / Cubit state management pattern**.

```
[Presentation Layer]
      │ (Cubit.events / State Streams)
      ▼
[Domain Layer: Use Cases & Entities]
      │ (Abstract Repository Interfaces)
      ▼
[Data Layer: Repositories & Data Sources]
      │
 ┌────┴───────────────────────────┬─────────────────────────┐
 ▼                                ▼                         ▼
[Local Hive Storage]      [Firebase Services]      [RevenueCat SDK]
```

### Core Design Invariants
1. **Unidirectional Data Flow**: UI dispatches intent to Cubits -> Cubits execute business logic -> Cubits emit immutable States -> UI renders via `BlocBuilder` / `BlocConsumer`.
2. **Entitlement Source of Truth**: User premium access is never determined by local boolean flags or Firestore fields alone; it is derived strictly through the `RevenueCatDataSource` entitlement verification (`premium_access`), cached in `PremiumStatusProvider`.
3. **Offline Resilience**: All critical user actions (pantry edits, recipe bookmarking, meal schedule modifications, shopping list updates) work offline first through Hive and queue changes to `SyncService`.
4. **Data Isolation on Logout**: When a user signs out, `SyncService.clearLocalUserData()` immediately wipes all private Hive boxes so that User A's data is never exposed to User B.

---

## 2. Layer Definitions

### Presentation Layer (`lib/features/*/presentation/`)
- **Pages**: Top-level route destinations mapped in `AppRouter`.
- **Widgets**: Reusable, atomic UI components themed with the AnuMealAI warm editorial design system.
- **Cubits & States**: Lightweight state machines handling UI state transitions without boilerplate event classes.

### Domain Layer (`lib/features/*/domain/`)
- **Entities**: Pure Dart immutable business objects extending `Equatable`. Free of third-party framework dependencies.
- **Repositories**: Abstract contracts defining data operations required by business features.

### Data Layer (`lib/features/*/data/`)
- **Data Sources**: Remote (`FirebaseAuthRemoteDataSource`, `FirebaseRemoteConfigDataSource`, `RevenueCatDataSource`) and Local (`HiveBoxDataSources`).
- **Repositories**: Concrete implementations orchestrating local caching, remote synchronization, error mapping, and analytics emission.

---

## 3. State Management & Lifecycle

| Feature | Cubit | Key States | Responsibilities |
|---|---|---|---|
| **Auth** | `AuthCubit` | `AuthInitial`, `AuthLoading`, `Authenticated`, `Unauthenticated`, `PasswordResetSent`, `AuthError` | Listens to Firebase Auth stream, manages login, guest session, registration, password recovery, account deletion. |
| **Remote Config** | `RemoteConfigCubit` | `RemoteConfigState` | Evaluates version updates, checks maintenance mode, provides dynamic limits. |
| **Subscription** | `SubscriptionCubit` | `SubscriptionState` | Manages paywall offerings, purchase execution, restores, entitlement status, and Judge promo bypass. |
| **Mood** | `MoodCubit` | `MoodState` | Active mood selection, mood-filtered recipes. |
| **Recipes** | `RecipeCubit` | `RecipeState` | AI recipe generation, pantry match calculation, cooking mode step tracking. |
| **Meal Planner** | `MealPlannerCubit` | `MealPlannerState` | 7-day breakfast/lunch/dinner plan scheduling. |
| **Shopping List** | `ShoppingListCubit` | `ShoppingListState` | Grocery items, check/uncheck status, bulk recipe ingredient import. |
| **Pantry** | `IngredientCubit` | `IngredientState` | Ingredient inventory, expiration tracking, category grouping. |
| **Favorites** | `FavoritesCubit` | `FavoritesState` | Bookmarking recipes, custom user recipe notes. |
| **Settings** | `SettingsCubit` | `SettingsState` | Theme switching (system/light/dark), notification permissions, legal navigation. |

---

## 4. Semantic Version Comparison Specification

Semantic versions follow the `MAJOR.MINOR.PATCH` pattern. The `AppVersionService.compareVersions` method parses each period-delimited segment into integers:

```dart
// Guarantees proper comparison where "1.0.9" is strictly less than "1.0.10"
static int compareVersions(String v1, String v2) {
  final parts1 = v1.split('.').map((e) => int.tryParse(e) ?? 0).toList();
  final parts2 = v2.split('.').map((e) => int.tryParse(e) ?? 0).toList();
  final length = math.max(parts1.length, parts2.length);
  for (int i = 0; i < length; i++) {
    final p1 = i < parts1.length ? parts1[i] : 0;
    final p2 = i < parts2.length ? parts2[i] : 0;
    if (p1 != p2) return p1.compareTo(p2);
  }
  return 0;
}
```
