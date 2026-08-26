# RevenueCat Setup Guide — AnuMealAI

This document outlines the RevenueCat configuration required to enable in-app purchases in production.

---

## 1. Dashboard Configuration

1. Log into your [RevenueCat Dashboard](https://app.revenuecat.com).
2. Create a new Project named **AnuMealAI**.
3. Under **Project Settings** -> **API Keys**, obtain:
   - Public iOS API Key (`appl_...`)
   - Public Android API Key (`goog_...`)

---

## 2. Entitlements & Offerings

### Entitlement
- **Identifier**: `anumeal_premium`
- **Description**: Access to unlimited AI recipe generation, 7-day weekly planner, and smart pantry matching.

### Products
Create the following products in the App Store Connect and Google Play Console:

| Product Identifier | Type | Duration | Price Tier |
|---|---|---|---|
| `anumeal_premium_monthly` | Auto-renewable Subscription | 1 Month | \$4.99 / month |
| `anumeal_premium_yearly` | Auto-renewable Subscription | 1 Year | \$39.99 / year |

### Offering
- **Identifier**: `default`
- Attach `anumeal_premium_monthly` as the **Monthly** package.
- Attach `anumeal_premium_yearly` as the **Annual** package (marked as Default / Best Value).

---

## 3. Environment Configuration

Supply keys using Flutter's `--dart-define` or via `.env`:

```bash
flutter run \
  --dart-define=REVENUECAT_API_KEY_IOS=appl_your_ios_key_here \
  --dart-define=REVENUECAT_API_KEY_ANDROID=goog_your_android_key_here
```

---

## 4. Shipaton 2026 Judge Free Access

For judges testing the submission without sandbox payment accounts:
1. Navigate to the Paywall screen.
2. Tap **"Judge / Promo Code"**.
3. Enter `SHIPATON2026` or `JUDGE_ACCESS`.
4. Premium entitlements will be locally simulated and active across the entire application.
