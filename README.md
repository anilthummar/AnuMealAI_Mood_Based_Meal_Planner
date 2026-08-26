# AnuMealAI 🍳
**"Your mood. Your ingredients. Your perfect meal."**

An AI-powered mood-based meal planner built with **Flutter**, **Material 3**, **Clean Architecture**, and **RevenueCat**. Built to commercial consumer app standards for the **RevenueCat Shipaton 2026**.

---

## 🌟 Features

- **🎭 Mood-First Recommendation Engine**: 10 handcrafted mood profiles (Energized, Comforting, Quick & Busy, Light & Fresh, Creative, Adventurous, Lazy Sunday, Healthy Reset, Cozy Evening, Celebratory) mapping emotion to flavor profiles, textures, and cooking styles.
- **🥦 Smart Pantry / Kitchen Inventory**: Track in-stock ingredients by category (Produce, Dairy, Protein, Pantry, Spices) with instant availability toggles and staple items.
- **✨ Intelligent Recipe Matching**: 0–100% deterministic local match scoring, dynamic missing-ingredient calculation, and chef cooking tips.
- **📅 7-Day Weekly Meal Planner**: Mon–Sun grid across 4 slots (Breakfast, Lunch, Dinner, Snack) with 1-tap full week regeneration and meal swapping.
- **🛒 Smart Categorized Grocery List**: Automatic missing-ingredient aggregation, produce/dairy/meat grouping, check-off progress, and completion cleanup.
- **👨‍🍳 Interactive Chef Cooking Mode**: Full-screen distraction-free cooking assistant with step-by-step guidance, built-in smart kitchen countdown timer, and post-meal rating/learning loop.
- **💎 RevenueCat In-App Purchases & Paywall**: Tier-gated features, Monthly & Annual plans, judge trial access (`SHIPATON2026` / `JUDGE_ACCESS`), and restore purchase functionality.
- **⚡ Offline-First Architecture**: Powered by Hive local boxes and graceful fallback to on-device recipe generation when offline or unconfigured.

---

## 🏗️ Architecture Overview

The app strictly follows **Clean Architecture** + **MVVM** using `flutter_bloc` (Cubit):

```
lib/
├── core/
│   ├── constants/           # AppConfig, HiveBoxes, SubscriptionConfig, Categories
│   ├── dependency_injection/# GetIt service locator setup (di.dart)
│   ├── errors/              # Domain Failures & Exceptions
│   ├── network/             # DioClient, NetworkInfo (connectivity abstraction)
│   ├── router/              # GoRouter with StatefulShellRoute bottom navigation
│   ├── services/            # AnalyticsService, FeatureAccessService, AIRecipeService
│   ├── theme/               # Material 3 Light/Dark Themes & Spacing Tokens
│   ├── utils/               # Result<T> monad
│   └── widgets/             # Reusable design system UI components
├── features/
│   ├── favorites/           # Saved recipes with mood filtering
│   ├── home/                # Dynamic greeting, mood carousel, personalized insights
│   ├── ingredients/         # Pantry items, categories, availability toggles
│   ├── meal_planner/        # 7-Day meal planning & slot swapping
│   ├── mood/                # Mood catalog & emotional state management
│   ├── onboarding/          # 9-step interactive onboarding experience
│   ├── profile/             # Preferences, cooking streaks, dietary restrictions
│   ├── recipes/             # Recipe match calculation, detail & chef cooking mode
│   ├── settings/            # Theme mode, notifications, purchases restore
│   ├── shopping_list/       # Grouped grocery items with checklist progress
│   └── subscription/        # RevenueCat purchases, Paywall page & judge access
└── app.dart & main.dart     # MultiBlocProvider root & Hive initialization
```

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://flutter.dev) (v3.22.0 or higher)
- Dart SDK 3.4+
- iOS Simulator / Android Emulator or physical device

### 1. Clone & Install Dependencies
```bash
git clone <repo-url>
cd Meal_Tracker
flutter pub get
```

### 2. Configure Environment (Optional)
Copy `.env.example` to `.env` or pass variables via `--dart-define`:
```bash
cp .env.example .env
```

### 3. Run the App
```bash
flutter run
```

### 4. Run Analysis & Tests
```bash
flutter analyze
flutter test
```

---

## 🏆 Shipaton 2026 Judge Access

Judges can unlock the full premium experience without test credit cards:
1. Open the Paywall (or go to **Profile** / **Settings** -> **Manage Premium**).
2. Tap **"Judge / Promo Code"**.
3. Enter `SHIPATON2026` or `JUDGE_ACCESS` and tap **Unlock Premium**.
4. Full unlimited weekly planning, AI generation, and chef mode will be activated instantly!

---

## 📄 License
MIT License. Built with ❤️ for the RevenueCat Shipaton 2026.
