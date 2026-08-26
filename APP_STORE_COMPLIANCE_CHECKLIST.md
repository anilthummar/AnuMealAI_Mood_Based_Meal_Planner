# AnuMealAI — Apple App Store Review Guidelines Compliance Checklist

This checklist guarantees adherence to Apple App Store Review Guidelines before submission to App Store Connect.

---

## 1. Guideline Compliance Mapping

### Guideline 5.1.1(v) — Account Deletion
* **Requirement**: Apps supporting account creation must offer users a simple, direct mechanism to initiate permanent account deletion within the app.
* **Implementation in AnuMealAI**: Implemented in `DeleteAccountPage` (`/account/delete`), accessible from `Settings -> Delete Account` and `Profile`. Permanently removes user account, Firebase credentials, and cloud documents cascade.

### Guideline 3.1.1 — In-App Purchase & Subscriptions
* **Requirement**: Paid digital features, unlimited recipe generations, and cloud synchronization must use StoreKit In-App Purchases.
* **Implementation**: Integrated with `RevenueCat` and native StoreKit.
* **Requirement**: Paywall must clearly disclose subscription title, length, price per unit, trial duration, renewal terms, and links to Terms of Use (EULA) and Privacy Policy.
* **Implementation**: Included on `PaywallPage`, `LoginPage`, `RegisterPage`, and `SettingsPage`.

### Guideline 3.1.2(c) — Restore Purchases
* **Requirement**: Apps offering subscriptions must include a functional "Restore Purchases" button on the paywall and in settings.
* **Implementation**: Added on `PaywallPage` and `SettingsPage` with interactive loading indicator and user feedback snackbar.

### Guideline 1.4 — Physical Harm / Health & Safety
* **Requirement**: Medical/health apps must include proper disclaimers.
* **Implementation**: Clear food safety, allergen, and non-medical disclaimers embedded into recipe instructions, terms of use, and cooking mode headers.

