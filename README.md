# AnuMealAI — AI Mood-Based Meal Planner 🍳✨

> **"Your mood. Your ingredients. Your perfect meal."**

AnuMealAI is a production-grade, offline-resilient Flutter application for Android and iOS. It intelligently curates chef-level recipes and weekly meal plans based on what ingredients you have in your pantry and how you are feeling right now.

---

## 🌟 Key Features

* **🎭 Mood-First Culinary Engine**: Dynamic recipe generation personalized to 8 emotional culinary states (*Comfort, Energetic, Quick & Easy, Healthy & Clean, Romantic, Adventurous, Cozy Warmth, Celebratory*).
* **🥑 Smart Pantry Inventory**: Offline-first inventory management with instant match calculations and smart ingredient substitution algorithms.
* **📅 Adaptive Weekly Planner**: Automated 7-day breakfast, lunch, and dinner scheduling with 1-tap bulk shopping list export.
* **🛒 Categorized Shopping List**: Organized by aisle (Produce, Dairy, Pantry, Meat, Spices) with instant check-off and recipe syncing.
* **🍳 Guided Cooking Mode**: Step-by-step interactive cooking screen with built-in voice-ready timers, tips, and post-cooking feedback celebration.
* **👑 Luxury Monetization & RevenueCat**: Single source-of-truth entitlement verification, auto-renewing subscriptions, restore purchases, and offline access fallback.
* **🔐 Firebase Authentication Suite**: Multi-tier authentication supporting Anonymous Guest mode, Email/Password login, password recovery, and GDPR/CCPA-compliant permanent account deletion.
* **🔄 Firebase Remote Config & Versioning**: Real-time feature flags, dynamic quotas, non-bypassable semantic force-update guard (`1.0.9 < 1.0.10`), soft update modals, and maintenance mode.
* **📊 Enterprise Observability**: Dual-engine Crashlytics crash reporting and structured Firebase Analytics event tracking.

---

## 🏛️ Clean Architecture & Tech Stack

```
lib/
├── core/                         # Enterprise Infrastructure
│   ├── constants/                # Keys, endpoints, configurations
│   ├── dependency_injection/     # GetIt service locator container
│   ├── errors/                   # Failure & Exception classes
│   ├── network/                  # Dio HTTP client & NetworkInfo
│   ├── router/                   # GoRouter navigation & deep linking
│   ├── services/                 # Firebase, RevenueCat, AI, Versioning
│   ├── theme/                    # Warm editorial typography & palette
│   └── widgets/                  # Reusable luxury UI components
└── features/                     # Domain-Driven Feature Modules
    ├── auth/                     # Authentication & Guest session
    ├── favorites/                # Saved recipes cache & offline access
    ├── home/                     # Mood carousel & discovery dashboard
    ├── ingredients/              # Pantry inventory & tracking
    ├── legal/                    # Terms, Privacy & Account Deletion
    ├── meal_planner/             # 7-day adaptive planner
    ├── mood/                     # Mood selection state machine
    ├── onboarding/               # Culinary preference questionnaire
    ├── profile/                  # User profile & dietary customization
    ├── recipes/                  # Match engine & cooking mode
    ├── remote_config/            # Remote config & maintenance guard
    ├── settings/                 # Appearance, purchases & legal
    ├── shopping_list/            # Aisle-sorted grocery checklist
    └── subscription/             # Paywall, RevenueCat & judge codes
```

---

## 🚀 Getting Started

### Prerequisites
* Flutter 3.24+ (Dart 3.5+)
* Android SDK 34+ / iOS 15+
* CocoaPods (for iOS builds)

### Installation
```bash
# 1. Clone repository
git clone https://github.com/anumealai/anu_meal_ai.git
cd anu_meal_ai

# 2. Install dependencies
flutter pub get

# 3. Run automated tests
flutter test

# 4. Launch on connected device
flutter run
```

---

## 🧪 Testing

The test suite covers domain logic, semantic version comparisons, authentication state transitions, match calculation algorithms, and widget rendering smoke tests:

```bash
flutter test
```

---

## 📄 Documentation Suite

* [Architecture Guide](ARCHITECTURE.md)
* [Firebase Console Setup](FIREBASE_SETUP.md)
* [RevenueCat Monetization Setup](REVENUECAT_SETUP.md)
* [Remote Config & Versioning Guide](REMOTE_CONFIG_SETUP.md)
* [Firestore Schema & Data Model](FIRESTORE_SCHEMA.md)
* [Firestore Security Rules](FIRESTORE_SECURITY_RULES.md)
* [Legal Documents (Terms & Privacy)](LEGAL_DOCUMENTS.md)
* [Release Checklist](RELEASE_CHECKLIST.md)
* [Google Play Compliance Checklist](GOOGLE_PLAY_COMPLIANCE_CHECKLIST.md)
* [App Store Compliance Checklist](APP_STORE_COMPLIANCE_CHECKLIST.md)

---

## ⚖️ License & Copyright

Copyright © 2026 AnuMealAI. All rights reserved.
