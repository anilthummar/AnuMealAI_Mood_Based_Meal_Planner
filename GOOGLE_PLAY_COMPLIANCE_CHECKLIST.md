# AnuMealAI — Google Play Store Compliance Checklist & Data Safety Form

This guide provides exact answers and configurations for the Google Play Console review and Data Safety form.

---

## 1. Google Play Policy Requirements

| Requirement | Implementation in AnuMealAI | Status |
|---|---|---|
| **Account Deletion Policy** | In-app permanent account deletion available at `Settings -> Delete Account`. Web URL link: `https://anumealai.app/delete-account` | ✅ Compliant |
| **Privacy Policy URL** | Disclosed in-app (`/legal/privacy`) and externally on web. | ✅ Compliant |
| **Subscription Transparency** | Clear display of monthly/annual pricing, free trial length (3 days), billing terms, and cancel link. | ✅ Compliant |
| **Target Audience & Content** | Target age: 18+ or General Audience (Food & Drink). | ✅ Compliant |

---

## 2. Google Play Data Safety Form Answers

### Data Collection & Sharing Summary
- **Data Collected**:
  - Personal info: Name (Display name), Email address (Account management & Auth).
  - App activity: App interactions, In-app search/mood history.
  - App info & performance: Crash logs (Crashlytics), Diagnostics (Firebase).
  - Device or other IDs: User ID (Firebase UID).
- **Data Shared**: None. AnuMealAI does NOT share user data with third-party data brokers or advertising networks.
- **Security Practices**:
  - Data is encrypted in transit (TLS/HTTPS).
  - Users can request data deletion directly in the app.

---

## 3. Financial Features & Subscriptions
- Subscriptions are handled exclusively through Google Play Billing (via RevenueCat).
- No external payment links or prohibited billing bypasses in production releases.

