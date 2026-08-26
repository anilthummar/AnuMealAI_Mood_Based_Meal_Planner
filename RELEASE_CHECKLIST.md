# AnuMealAI — Pre-Flight Production Release Checklist

Complete this checklist prior to building release binaries for the Google Play Store and Apple App Store.

---

## 1. Version & Metadata Verification
- [ ] `pubspec.yaml` version code and version name updated (e.g. `version: 1.0.0+1`).
- [ ] App Name confirmed: **AnuMealAI** across `AndroidManifest.xml` and iOS `Info.plist`.
- [ ] App Bundle ID matched:
  - Android: `com.anumealai.anu_meal_ai`
  - iOS: `com.anumealai.anuMealAi`

---

## 2. Configuration Files & Keys
- [ ] Android `google-services.json` present in `android/app/`.
- [ ] iOS `GoogleService-Info.plist` present in `ios/Runner/`.
- [ ] RevenueCat public API keys configured in `lib/core/constants/app_config.dart`.
- [ ] Firebase Remote Config default parameters published in Firebase Console.
- [ ] Firestore Security Rules deployed (`firebase deploy --only firestore:rules`).

---

## 3. Code Quality & Automated Tests
- [ ] Static analysis passes with 0 issues:
  ```bash
  flutter analyze
  ```
- [ ] All unit and widget tests pass:
  ```bash
  flutter test
  ```

---

## 4. Android Release Build
- [ ] Keystore configured in `android/key.properties`.
- [ ] Proguard / R8 rules verified for Firebase, RevenueCat, and Hive.
- [ ] Build App Bundle:
  ```bash
  flutter build appbundle --release
  ```

---

## 5. iOS Release Build
- [ ] Signing certificate and Provisioning Profile selected in Xcode.
- [ ] Capabilities configured: Push Notifications, In-App Purchase.
- [ ] Build IPA / Archive:
  ```bash
  flutter build ipa --release
  ```
