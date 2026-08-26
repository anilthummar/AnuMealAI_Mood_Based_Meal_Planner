# AnuMealAI — Firebase Production Console Setup Guide

This guide details the complete configuration required in the [Firebase Console](https://console.firebase.google.com/) for AnuMealAI.

---

## 1. Firebase Project Creation
1. Go to Firebase Console -> **Add project** -> Name it `AnuMealAI-Production` (or `anumealai-app`).
2. Enable **Google Analytics for Firebase** and select your Analytics account.
3. Finish project creation.

---

## 2. Platform App Registration

### Android Configuration
1. Register Android app with Package Name: `com.anumealai.anu_meal_ai`
2. App nickname: `AnuMealAI Android`
3. Add Debug and Release SHA-1 and SHA-256 fingerprint hashes (required for Firebase Auth).
4. Download `google-services.json` and place it in:
   ```
   android/app/google-services.json
   ```
5. Ensure `android/build.gradle.kts` has the Google Services classpath and `android/app/build.gradle.kts` applies `com.google.gms.google-services`.

### iOS Configuration
1. Register iOS app with Bundle ID: `com.anumealai.anuMealAi`
2. App nickname: `AnuMealAI iOS`
3. Download `GoogleService-Info.plist` and place it in:
   ```
   ios/Runner/GoogleService-Info.plist
   ```
4. In Xcode, ensure `GoogleService-Info.plist` is added to the `Runner` target.

---

## 3. Firebase Authentication Setup
1. In Firebase Console -> **Build** -> **Authentication** -> **Get Started**.
2. Under **Sign-in method**, enable:
   - **Email/Password**: Enable "Email/Password" (leave Email link disabled unless desired).
   - **Anonymous**: Enable (used for instant frictionless guest trial onboarding).
3. Under **Templates**, customize the **Password reset** email sender name and reply-to email (`support@anumealai.app`).

---

## 4. Cloud Firestore Database Setup
1. In Firebase Console -> **Build** -> **Firestore Database** -> **Create Database**.
2. Select your production region (e.g. `us-central1` or `europe-west1`).
3. Start in **Production mode**.
4. Deploy the production security rules detailed in [FIRESTORE_SECURITY_RULES.md](FIRESTORE_SECURITY_RULES.md).

---

## 5. Firebase Remote Config Setup
1. In Firebase Console -> **Build** -> **Remote Config** -> **Create Configuration**.
2. Add the parameters detailed in [REMOTE_CONFIG_SETUP.md](REMOTE_CONFIG_SETUP.md).
3. Publish changes.

---

## 6. Firebase Crashlytics & Analytics Setup
1. In Firebase Console -> **Build** -> **Crashlytics** -> Click **Enable Crashlytics**.
2. Analytics will automatically stream events (`sign_up`, `login`, `recipe_generated`, `recipe_cooked`, `paywall_viewed`, `purchase_completed`).

