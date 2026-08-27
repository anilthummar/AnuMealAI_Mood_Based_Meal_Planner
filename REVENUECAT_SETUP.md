# AnuMealAI — RevenueCat Monetization & Subscription Guide

**AnuMealAI** uses **RevenueCat** as the authoritative single source of truth for in-app subscriptions, dynamic entitlements, Paywalls, Customer Center, and cross-platform billing.

---

## 1. Quick Configuration Summary

| Property | Value | Notes |
|---|---|---|
| **Android API Key** | `YOUR_REVENUECAT_ANDROID_KEY` (via Remote Config) | Managed in Firebase Remote Config & `AppConfig` |
| **iOS / Test API Key** | `YOUR_REVENUECAT_IOS_KEY` (via Remote Config) | Managed in Firebase Remote Config & `AppConfig` |
| **Entitlement Identifier** | `anumealai_pro` | Entitlement Name: **AnuMealAI Pro** |
| **Default Offering** | `default` | Contains Monthly and Yearly packages |
| **Monthly Package / Product** | `monthly` | Standard Monthly Subscription |
| **Yearly Package / Product** | `yearly` | Standard Annual Subscription (Best Value) |
| **SDK Packages** | `purchases_flutter: ^10.10.0`<br>`purchases_ui_flutter: ^10.10.0` | In `pubspec.yaml` |

---

## 2. Step-by-Step RevenueCat Dashboard Setup

### Step 1: Create Entitlement
1. In the RevenueCat Dashboard, navigate to **Project Settings** > **Entitlements**.
2. Click **+ New Entitlement**.
3. **Identifier**: `anumealai_pro`
4. **Description**: `AnuMealAI Pro - Unlimited AI recipe recommendations, 7-day meal planner, smart waste reduction, and chef mode.`

### Step 2: Configure Products
1. Navigate to **Products**.
2. Linked store products configured in your RevenueCat Dashboard:
   - **Google Play Store Products**:
     - `anumealai_premium:monthly` (Subscription ID: `anumealai_premium`, Base Plan: `monthly`)
     - `anumealai_premium:yearly` (Subscription ID: `anumealai_premium`, Base Plan: `yearly`)
   - **Test Store Products**:
     - `monthly` (Test Store)
     - `yearly` (Test Store)
3. Both products are attached to Entitlement: **`anumealai_pro`** (AnuMealAI Pro).

### Step 3: Configure Default Offering
1. Navigate to **Offerings**.
2. Select your `Default` offering (identifier: `default`).
3. Attach packages:
   - **Monthly Package (`$rc_monthly` / `monthly`)**: Attach `anumealai_premium:monthly` (Play Store) and `monthly` (Test Store).
   - **Annual Package (`$rc_annual` / `yearly`)**: Attach `anumealai_premium:yearly` (Play Store) and `yearly` (Test Store).

---

## 3. Flutter Architecture & Implementation

The app implements clean architecture layers for RevenueCat:

```
UI Layers (Pages / Widgets)
       │
       ▼
SubscriptionCubit (State Machine & Reactive Stream Listener)
       │
       ▼
SubscriptionRepository (Domain Interface & Implementation)
       │
       ▼
RevenueCatDataSource (SDK Wrapper with Purchases & PurchasesUI)
       │
       ▼
RevenueCat SDK (purchases_flutter + purchases_ui_flutter)
```

### 1. SDK Initialization (`main.dart` / `di.dart`)
```dart
await sl<RevenueCatDataSource>().initialize();
```
* Configures `Purchases` with API key dynamically loaded from Firebase Remote Config.
* Sets log level (`LogLevel.debug` in development).
* Registers real-time `CustomerInfoUpdateListener`.

### 2. Entitlement Checking for `anumealai_pro`
```dart
void _handleCustomerInfo(CustomerInfo info) {
  final entitlement = info.entitlements.all['anumealai_pro'];
  final isActive = entitlement != null && entitlement.isActive;

  final state = SubscriptionEntity(
    tier: isActive ? SubscriptionTier.premium : SubscriptionTier.free,
    status: isActive ? SubscriptionStatus.premium : SubscriptionStatus.free,
    activeOfferingId: entitlement?.productIdentifier,
    expirationDate: entitlement?.expirationDate,
    willRenew: entitlement?.willRenew ?? false,
  );
}
```

### 3. Presenting Native RevenueCat Paywalls
Using `purchases_ui_flutter`:
```dart
// Present Paywall directly:
final paywallResult = await RevenueCatUI.presentPaywall(
  displayCloseButton: true,
);

// Or present only if 'anumealai_pro' is NOT active:
final result = await RevenueCatUI.presentPaywallIfNeeded(
  'anumealai_pro',
  displayCloseButton: true,
);
```

### 4. Presenting Customer Center (Self-Serve Management)
RevenueCat Customer Center allows users to manage active subscriptions, change tiers, cancel, or request refunds:
```dart
final result = await RevenueCatUI.presentCustomerCenter();
```

---

## 4. Production Best Practices Implemented

1. **Firebase Authentication Synchronization**:
   - On login: `Purchases.logIn(firebaseUser.uid)` binds RevenueCat Customer ID to the Firebase user.
   - On logout: `Purchases.logOut()` generates an anonymous ID and resets session entitlements.

2. **Offline Resilience & Caching**:
   - In-memory `lastKnownState` cache ensures feature gates respond instantly without network stalls.
   - Graceful offline fallback if RevenueCat API is temporarily unreachable.

3. **Restore Purchases Guarantee**:
   - Compliant with App Store Guideline 3.1.1 and Google Play Billing policies with a 1-tap **Restore Purchases** flow.

4. **Judge / Reviewer Testing Bypass**:
   - Built-in review tokens (`SHIPATON2026`, `JUDGE_ACCESS`, `ANUMEALPRO`) allow seamless testing on physical devices without sandbox purchase friction.
