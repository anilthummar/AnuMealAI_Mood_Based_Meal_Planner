# AnuMealAI — Project Implementation Plan

_Tagline: "Your mood. Your ingredients. Your perfect meal."_

## 1. Current Project Analysis

The working directory was **empty** prior to this plan (no existing Flutter project, no git
history, no Firebase/RevenueCat config, no assets, no theme). This is a **greenfield build**,
not a refactor. There is nothing to preserve; everything below is being introduced fresh.

Environment verified on this machine:
- Flutter 3.44.8 (stable), Dart 3.12.2
- Android toolchain ✅, Chrome/web ✅
- Xcode is incomplete (no full install) → iOS code is written and kept buildable, but iOS
  release builds/signing must happen on a machine with full Xcode. Android + Web are the
  loop we can build/run/verify locally.
- A physical Android device and Android/macOS/Chrome targets are available for testing.

Project identity chosen for scaffolding: application id `com.anumealai.app`, Dart package
name `anu_meal_ai`. These are placeholders — change them centrally (see §9) before
publishing if you already own different reverse-DNS IDs.

## 2. Architecture

Clean Architecture + MVVM-via-BLoC, feature-first:

```
UI (pages/widgets)
   -> Cubit/Bloc (ViewModel)
      -> UseCase (domain)
         -> Repository interface (domain)
            -> Repository impl (data)
               -> DataSource (local: Hive/SharedPreferences, remote: Dio/RevenueCat)
```

Rules enforced throughout the codebase:
- `presentation/` never imports `dio`, `hive`, `purchases_flutter`, etc. directly — only
  domain use cases/repository interfaces.
- Domain layer has **no Flutter imports** and no dependency on data-layer packages.
- Every repository is defined as an abstract class in `domain/repositories` and implemented
  in `data/repositories`.
- Cross-feature reads (e.g. meal planner needing ingredients) go through the other
  feature's domain repository interface, injected via GetIt — never through direct data
  access.

## 3. Folder Structure

```
lib/
  core/
    constants/        app-wide constants (moods, categories, config keys, limits)
    errors/            Failure types + Exception -> Failure mapping
    extensions/        BuildContext/DateTime/String helpers
    network/           Dio client factory, network_info (connectivity)
    theme/             ColorScheme, TextTheme, ThemeData (light/dark), design tokens
    utils/             pure helpers (id gen, date formatting, result type)
    services/          cross-cutting abstractions: AnalyticsService, NotificationService,
                       ImageProvider abstraction, AIRecipeService, FeatureAccessService
    router/            go_router configuration + route names
    dependency_injection/  GetIt setup (di.dart)
    widgets/           reusable design-system widgets (AppButton, AppCard, MoodCard, ...)
  features/
    onboarding/  home/  mood/  ingredients/  meal_planner/  recipes/  favorites/
    shopping_list/  profile/  subscription/  settings/
      data/{datasources,models,repositories}
      domain/{entities,repositories,usecases}
      presentation/{bloc,pages,widgets}
  app.dart
  main.dart
test/
  core/
  features/
```

## 4. Feature List (MVP scope, mapped to spec sections)

| Feature | Core responsibility |
|---|---|
| onboarding | welcome → how it works → preferences capture → completion; persisted flag |
| home | dynamic greeting, today snapshot, quick suggestion, CTAs, personalized section |
| mood | 10 fixed moods with recipe-characteristic metadata; mood-of-the-day |
| ingredients | CRUD, categories, search/filter, recently used |
| meal_planner | Mon–Sun x Breakfast/Lunch/Dinner/Snack grid, generate/regenerate/replace |
| recipes | AI-backed generation, local match scoring, detail page, cooking mode |
| favorites | favorite/unfavorite, list, search/sort |
| shopping_list | auto-built from missing ingredients + manual items, grouped by category |
| subscription | RevenueCat entitlement state, FeatureAccessService, paywall |
| profile | preferences editing, cooking stats, mood/meal history |
| settings | theme mode, notifications toggle, restore purchases, legal links |

Not building in MVP (explicitly out of scope per §60 "don't overengineer"): real camera
ingredient recognition (architecture stubbed only), push notifications backend (local
abstraction only), server-side analytics backend (interface + console-log implementation
only).

## 5. Data Models (domain entities)

- `Mood { id, name, emoji, description, traits: List<String> }`
- `Ingredient { id, name, category, quantity, unit, expiryDate?, isAvailable, createdAt }`
- `Recipe { id, title, description, mood, mealType, prepTimeMinutes, cookTimeMinutes, difficulty, matchPercentage, ingredients, missingIngredients, instructions, tips, nutrition, imageQuery, isFavorite, cookedAt? }`
- `MealPlanEntry { id, date, mealType, recipeId }` inside `WeeklyMealPlan { weekStartDate, entries }`
- `ShoppingItem { id, name, category, quantity, unit, isChecked, sourceRecipeId? }`
- `UserPreferences { dietary, cuisines, skillLevel, typicalCookingTime, goals, notificationsEnabled }`
- `MealFeedback { recipeId, rating(loved/good/okay/notForMe), cookedAt }`
- `SubscriptionState { tier(free/premium), status(unknown/loading/free/premium/error), expirationDate? }`

All entities are `Equatable`, immutable, with `copyWith`. Hive persistence stores each as a
`Map<String, dynamic>` (hand-written `toMap`/`fromMap`) inside a named `Box<Map>` — this
avoids `hive_generator`, which cannot coexist with `bloc_test`'s analyzer constraint (see
§8 dependency note). No functionality is lost; only build_runner codegen is avoided.

## 6. State Management Strategy

One Cubit per feature-level concern, not per screen:
`OnboardingCubit, HomeCubit, MoodCubit, IngredientCubit, RecipeCubit, MealPlannerCubit,
FavoritesCubit, ShoppingListCubit, SubscriptionCubit, ProfileCubit, SettingsCubit`.

- `flutter_bloc` + `equatable` states (`Initial/Loading/Loaded/Empty/Error` per feature).
- Purely local UI state (e.g. a text field's focus, a tab index) stays in a
  `StatefulWidget` — no Cubit created for it.
- Cubits depend only on use cases, injected via GetIt/constructor — never on
  `BuildContext` or other Cubits directly. Cross-feature coordination happens by one
  Cubit calling another feature's use case, not by reaching into its Cubit.

## 7. Subscription Strategy

- `SubscriptionRepository` (domain) + `RevenueCatDataSource` (data, wraps `purchases_flutter`)
  + `SubscriptionCubit` (presentation), matching §17 exactly.
- Truth for premium access is **RevenueCat `CustomerInfo.entitlements`**, read through
  `SubscriptionRepository.getCustomerInfo()` / `.entitlementUpdates` stream — never a
  locally-stored boolean. Local Hive cache of the last known state is kept only so the UI
  can render something instantly offline; it is always reconciled against RevenueCat on
  app resume/network return.
- `FeatureAccessService` (core/services) is the **single** place with limit logic:
  `canGenerateRecipe()`, `canGenerateWeeklyPlan()`, `canSaveRecipe()`, each consulting
  `SubscriptionCubit.state` + a local usage counter (resets daily/weekly). No other file
  contains an `if (isPremium)` check — screens call `FeatureAccessService`.
- Central `SubscriptionConfig` (core/constants) holds entitlement id and product id
  placeholders (`entl_premium`, `anu_meal_ai_monthly`, `anu_meal_ai_yearly`) and free-tier
  limits (recipes/day, plans/week, saved recipes) as named constants.

## 8. RevenueCat Strategy

- SDK: `purchases_flutter`. Configured in `main.dart` via `AppConfig.revenueCatApiKey`
  (from `--dart-define`/`.env`, never committed).
- Products: `anu_meal_ai_monthly`, `anu_meal_ai_yearly` under entitlement `premium` —
  placeholders, real IDs are set up in the RevenueCat dashboard by the developer (see
  `REVENUECAT_SETUP.md`).
- Paywall built natively in Flutter (not RevenueCatUI) to match the app's design system,
  reading `Offerings` from the repository.
- Judge/trial access (Shipaton requirement, §21): supported via a real RevenueCat free
  trial configured on the yearly/monthly package, **or** a RevenueCat promo code redeemed
  through `Purchases.restorePurchases()`/promotional entitlement — no fake in-app unlock
  path is implemented. Documented in `REVENUECAT_SETUP.md`.
- Dependency note: `hive_generator` was dropped from `pubspec.yaml` because its `analyzer`
  constraint (`<7.0.0`) conflicts with `bloc_test`'s (`>=8.0.0`). Hive is still used, with
  manual map-based (de)serialization instead of generated `TypeAdapter`s — no capability
  lost, one fewer build step.

## 9. AI Integration Strategy

- `abstract class AIRecipeService` (core/services) with a single method:
  `Future<List<Recipe>> generateRecipes(RecipeRequest request)`.
- `RemoteAIRecipeService implements AIRecipeService` calls a configurable HTTP endpoint via
  `Dio` (`AppConfig.aiApiBaseUrl` / `AppConfig.aiApiKey`) and parses the structured JSON
  schema from §11. The provider (OpenAI/Anthropic/self-hosted) is an implementation detail
  behind this interface — swap it by changing one class, not by touching any feature code.
- Local **match percentage is never trusted from the AI**; `RecipeMatchCalculator`
  (domain, pure function) recomputes 0–100% from ingredient overlap, mood fit, meal-type
  fit, cooking time fit, dietary/cuisine fit (§44/§45).
- Malformed/empty/timeout/rate-limited responses map to typed `Failure`s and the UI shows
  a dedicated fallback state — never a crash, never a silent empty screen.
- `AppConfig` centralizes the app id / product ids/ base URLs; see `AI_INTEGRATION.md` and
  `.env.example` for exact keys.

## 10. Persistence Strategy

- `shared_preferences`: small flags/values — onboarding-complete, theme mode, last mood,
  usage counters, notification toggle.
- `hive_flutter`: structured collections as JSON-map boxes — `ingredients`, `favorites`,
  `recipes_cache`, `meal_plans`, `shopping_list`, `meal_history`, `mood_history`.
- Every box is wrapped by a `LocalDataSource` class per feature; repositories are the only
  callers. Presentation code never imports `hive` or `shared_preferences`.
- `NetworkInfo` (core/network, wraps `connectivity_plus`) lets repositories decide
  local-only vs. local+remote behavior for the offline-first rules in §30.

## 11. Navigation Strategy

- `go_router` with a `StatefulShellRoute` for the 5-tab bottom nav (Home, Planner, Recipes,
  Shopping, Profile), plus top-level routes for onboarding, recipe detail, cooking mode,
  and the paywall (presented modally). Route names are constants in
  `core/router/app_routes.dart` so deep links are just named-route pushes — the paywall,
  recipe detail (`/recipe/:id`), and cooking mode are all deep-linkable by construction.
- `main.dart` decides the initial location (`/onboarding` vs `/home`) by reading the
  onboarding-complete flag before `runApp`.

## 12. Design System

Material 3, warm/fresh/food-forward palette (terracotta/tomato primary, sage secondary,
cream surfaces), Google Fonts (a rounded display face + a readable body face), 8pt spacing
scale, 16–20dp corner radius on cards. Light, dark, and system theme modes, all colors
sourced from `ThemeData`/`ColorScheme` — no widget hardcodes a `Color`.

Reusable widgets in `core/widgets`: `AppButton`, `AppCard`, `AppTextField`, `AppChip`,
`MoodCard`, `RecipeCard`, `IngredientChip`, `PremiumBadge`, `LoadingShimmer`, `EmptyState`,
`ErrorState`, `SectionHeader`, `AppBottomSheet`, `AppSnackbar`.

## 13. Testing Strategy

- Domain: use case unit tests (mocktail fakes for repositories).
- `FeatureAccessService`/subscription: free-limit-exceeded, premium-unlimited, purchase →
  unlock, restore → unlock, expiry → lock (per §43's explicit list).
- `AIRecipeService`/JSON parsing: valid, malformed, empty, timeout cases.
- `RecipeMatchCalculator`: deterministic scoring cases.
- Cubit tests with `bloc_test` for state-transition coverage on the higher-risk cubits
  (Recipe, MealPlanner, Subscription).
- A handful of widget tests for Home, Paywall, and Recipe Detail smoke coverage.
- Kept intentionally lean per §60 — breadth over exhaustive coverage for an MVP.

## 14. Release Checklist

See `RELEASE_CHECKLIST.md` (created alongside this plan) — covers `flutter analyze`,
`flutter test`, Android/iOS release builds, RevenueCat product/offering setup, store
listing assets, and the Shipaton judge-access requirement.

## 15. Implementation Sequence (phases from the brief, §59)

Executed incrementally; after each phase: analyze → fix → verify → move on, never leaving
broken code for the next phase.

1. ✅ Inspection + architecture + this plan
2. Theme + navigation shell + shared UI components
3. Onboarding + profile/preferences
4. Home + mood system
5. Ingredient management
6. Recipe generation architecture (AI service + match calculator)
7. Recipe detail + cooking mode
8. Favorites + history
9. Shopping list
10. Weekly meal planner
11. RevenueCat subscription
12. Premium gating (FeatureAccessService wired into the above)
13. Personalization engine
14. Animations + microinteractions pass
15. Offline support pass
16. Analytics-ready architecture
17. Testing pass
18. Performance pass
19. Release prep (docs, checklists, `.env.example`)

Each phase will be reported with: what was implemented, files changed, dependencies
added, tests added, remaining work, and any configuration required from you (API keys,
bundle IDs, RevenueCat dashboard setup).
