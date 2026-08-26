/// Centralized Firebase Remote Config Parameter Keys (§56, §73).
class RemoteConfigKeys {
  RemoteConfigKeys._();

  // Versioning & Update Management
  static const String appMinimumSupportedVersion =
      'app_minimum_supported_version';
  static const String appLatestVersion = 'app_latest_version';
  static const String appForceUpdate = 'app_force_update';
  static const String appUpdateMessage = 'app_update_message';
  static const String androidStoreUrl = 'android_store_url';
  static const String iosStoreUrl = 'ios_store_url';

  // Maintenance Mode
  static const String maintenanceMode = 'maintenance_mode';
  static const String maintenanceMessage = 'maintenance_message';

  // Business & Monetization Limits
  static const String freeDailyRecipeLimit = 'free_daily_recipe_limit';
  static const String freeWeeklyPlanLimit = 'free_weekly_plan_limit';
  static const String freeFavoriteLimit = 'free_favorite_limit';

  // Feature Flags
  static const String enableAiRecipes = 'enable_ai_recipes';
  static const String enableWeeklyPlanner = 'enable_weekly_planner';
  static const String enableNotifications = 'enable_notifications';
  static const String enableMoodRecommendations = 'enable_mood_recommendations';
  static const String enableNewHome = 'enable_new_home';
  static const String enablePremiumFeatures = 'enable_premium_features';
}

/// Default local values for safe fallback when offline or before first fetch (§19)
class RemoteConfigDefaults {
  RemoteConfigDefaults._();

  static const Map<String, dynamic> defaults = {
    RemoteConfigKeys.appMinimumSupportedVersion: '1.0.0',
    RemoteConfigKeys.appLatestVersion: '1.0.0',
    RemoteConfigKeys.appForceUpdate: false,
    RemoteConfigKeys.appUpdateMessage:
        "You're using an older version of AnuMealAI. Please update to enjoy the latest features and improvements.",
    RemoteConfigKeys.androidStoreUrl:
        'https://play.google.com/store/apps/details?id=com.anumealai.anu_meal_ai',
    RemoteConfigKeys.iosStoreUrl: 'https://apps.apple.com/app/id6740123456',
    RemoteConfigKeys.maintenanceMode: false,
    RemoteConfigKeys.maintenanceMessage:
        "AnuMealAI is getting better! We're performing a quick service update. Please check back shortly.",
    RemoteConfigKeys.freeDailyRecipeLimit: 3,
    RemoteConfigKeys.freeWeeklyPlanLimit: 1,
    RemoteConfigKeys.freeFavoriteLimit: 20,
    RemoteConfigKeys.enableAiRecipes: true,
    RemoteConfigKeys.enableWeeklyPlanner: true,
    RemoteConfigKeys.enableNotifications: true,
    RemoteConfigKeys.enableMoodRecommendations: true,
    RemoteConfigKeys.enableNewHome: true,
    RemoteConfigKeys.enablePremiumFeatures: true,
  };
}
