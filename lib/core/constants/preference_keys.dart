/// Keys used with SharedPreferences. Centralized to avoid magic strings.
class PreferenceKeys {
  PreferenceKeys._();

  static const String onboardingComplete = 'pref_onboarding_complete';
  static const String themeMode = 'pref_theme_mode';
  static const String themeModeIndex = 'pref_theme_mode_index';
  static const String notificationsEnabled = 'pref_notifications_enabled';
  static const String userPreferences = 'pref_user_preferences';
  static const String userPreferencesJson = 'pref_user_preferences_json';
  static const String lastKnownSubscriptionTier = 'pref_last_subscription_tier';
  static const String lastSelectedMoodId = 'pref_last_selected_mood_id';
  static const String moodHistoryList = 'pref_mood_history_list';
  static const String recipeGenerationCountPrefix = 'pref_recipe_gen_count_';
  static const String weeklyPlanGenerationCountPrefix = 'pref_plan_gen_count_';
  static const String appOpenCount = 'pref_app_open_count';
  static const String lastAppOpenDate = 'pref_last_app_open_date';
  static const String cookingStreak = 'pref_cooking_streak';
}
