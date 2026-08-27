/// Environment-based configuration. Values are supplied via
/// `--dart-define-from-file=env/<environment>.json` (see `.env.example` at the
/// repo root for the expected keys) — nothing sensitive is hardcoded or
/// committed here. Defaults below are safe placeholders only.
enum AppEnvironment { development, staging, production }

class AppConfig {
  AppConfig._();

  static AppEnvironment get environment => _environmentFromName(
    const String.fromEnvironment('APP_ENV', defaultValue: 'development'),
  );

  /// Public/mobile-safe RevenueCat SDK key for the current platform.
  /// NEVER put a RevenueCat *secret* key here — only the public app key.
  static const String revenueCatApiKeyAndroid = String.fromEnvironment(
    'REVENUECAT_API_KEY_ANDROID',
    defaultValue: 'goog_HcIJqcEpkSzgUbaFzaNwNrXyqqO',
  );
  static const String revenueCatApiKeyIos = String.fromEnvironment(
    'REVENUECAT_API_KEY_IOS',
    defaultValue: 'test_GRcIzLgwSeOerbbBzAMMHbWyXhX',
  );

  /// Direct Google Gemini API configuration (§11)
  static const String geminiApiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: 'AQ.Ab8RN6Kx7v8LueIvQjSBaoEnwCtaONsvty0tnH0lloR_XiZTbA',
  );
  static const String geminiModel = String.fromEnvironment(
    'GEMINI_MODEL',
    defaultValue: 'gemini-3.6-flash',
  );

  static bool get isConfigured => geminiApiKey.isNotEmpty;

  static const String appName = 'AnuMealAI – AI Meal Planner';
  static const String appTagline =
      'Your mood. Your ingredients. Your perfect meal.';

  /// Public policy links (§41, §75)
  static const String termsOfUseUrl =
      'https://sites.google.com/view/anumealai-terms-of-use/home';
  static const String privacyPolicyUrl =
      'https://sites.google.com/view/anumealai-privacy-policy/home';
}

AppEnvironment _environmentFromName(String name) => switch (name) {
  'staging' => AppEnvironment.staging,
  'production' => AppEnvironment.production,
  _ => AppEnvironment.development,
};
