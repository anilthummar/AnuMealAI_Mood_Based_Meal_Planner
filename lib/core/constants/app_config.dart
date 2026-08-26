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
    defaultValue: 'test_GRcIzLgwSeOerbbBzAMMHbWyXhX',
  );
  static const String revenueCatApiKeyIos = String.fromEnvironment(
    'REVENUECAT_API_KEY_IOS',
    defaultValue: 'test_GRcIzLgwSeOerbbBzAMMHbWyXhX',
  );

  /// Base URL + key for the recipe-generation backend/proxy. Point this at a
  /// server-side proxy in production so the real LLM API key never ships
  /// inside the app binary.
  static const String aiApiBaseUrl = String.fromEnvironment(
    'AI_API_BASE_URL',
    defaultValue: 'https://api.anumealai.app',
  );
  static const String aiApiKey = String.fromEnvironment(
    'AI_API_KEY',
    defaultValue: '',
  );

  static bool get isConfigured =>
      aiApiKey.isNotEmpty || aiApiBaseUrl.isNotEmpty;

  static const String appName = 'AnuMealAI';
  static const String appTagline =
      'Your mood. Your ingredients. Your perfect meal.';
}

AppEnvironment _environmentFromName(String name) => switch (name) {
  'staging' => AppEnvironment.staging,
  'production' => AppEnvironment.production,
  _ => AppEnvironment.development,
};
