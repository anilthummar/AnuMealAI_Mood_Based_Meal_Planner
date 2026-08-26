import 'package:shared_preferences/shared_preferences.dart';

import '../constants/preference_keys.dart';
import '../constants/subscription_config.dart';
import 'premium_status_provider.dart';

/// The single place that decides what a user is allowed to do based on
/// subscription tier (§18/§45). No screen or Cubit should check
/// `isPremium` or a usage counter directly — everything routes through here,
/// so changing a limit or adding a new gated feature is a one-file edit.
class FeatureAccessService {
  final PremiumStatusProvider premiumStatus;
  final SharedPreferences prefs;

  FeatureAccessService({required this.premiumStatus, required this.prefs});

  bool get isPremium => premiumStatus.isPremium;

  // --- Recipe generation (daily limit) ---

  bool canGenerateRecipe() {
    if (isPremium) return true;
    return _dailyCount(PreferenceKeys.recipeGenerationCountPrefix) <
        SubscriptionConfig.freeRecipeGenerationsPerDay;
  }

  int remainingRecipeGenerationsToday() {
    if (isPremium) return -1; // unlimited
    final remaining =
        SubscriptionConfig.freeRecipeGenerationsPerDay - _dailyCount(PreferenceKeys.recipeGenerationCountPrefix);
    return remaining < 0 ? 0 : remaining;
  }

  Future<void> recordRecipeGeneration() async {
    if (isPremium) return;
    await _incrementDaily(PreferenceKeys.recipeGenerationCountPrefix);
  }

  // --- Weekly meal plan generation (weekly limit) ---

  bool canGenerateWeeklyPlan() {
    if (isPremium) return true;
    return _weeklyCount(PreferenceKeys.weeklyPlanGenerationCountPrefix) <
        SubscriptionConfig.freeWeeklyPlanGenerationsPerWeek;
  }

  Future<void> recordWeeklyPlanGeneration() async {
    if (isPremium) return;
    await _incrementWeekly(PreferenceKeys.weeklyPlanGenerationCountPrefix);
  }

  // --- Saved recipes (standing limit, not time-boxed) ---

  bool canSaveRecipe(int currentSavedCount) {
    if (isPremium) return true;
    return currentSavedCount < SubscriptionConfig.freeSavedRecipesLimit;
  }

  // --- helpers ---

  String get _todayKey {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  String get _weekKey {
    final now = DateTime.now();
    final firstDayOfYear = DateTime(now.year, 1, 1);
    final weekNumber = ((now.difference(firstDayOfYear).inDays) / 7).floor();
    return '${now.year}-w$weekNumber';
  }

  int _dailyCount(String prefix) => prefs.getInt('$prefix$_todayKey') ?? 0;

  int _weeklyCount(String prefix) => prefs.getInt('$prefix$_weekKey') ?? 0;

  Future<void> _incrementDaily(String prefix) async {
    final key = '$prefix$_todayKey';
    await prefs.setInt(key, (prefs.getInt(key) ?? 0) + 1);
  }

  Future<void> _incrementWeekly(String prefix) async {
    final key = '$prefix$_weekKey';
    await prefs.setInt(key, (prefs.getInt(key) ?? 0) + 1);
  }
}
