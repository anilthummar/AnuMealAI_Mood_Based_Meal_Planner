import 'package:shared_preferences/shared_preferences.dart';

import '../../features/remote_config/domain/repositories/remote_config_repository.dart';
import '../constants/preference_keys.dart';
import '../constants/subscription_config.dart';
import 'premium_status_provider.dart';

/// The single place that decides what a user is allowed to do based on
/// subscription tier (§18, §34, §35). No screen or Cubit should check
/// `isPremium` or a usage counter directly — everything routes through here.
class FeatureAccessService {
  final PremiumStatusProvider premiumStatus;
  final SharedPreferences prefs;
  final RemoteConfigRepository? remoteConfigRepository;

  FeatureAccessService({
    required this.premiumStatus,
    required this.prefs,
    this.remoteConfigRepository,
  });

  bool get isPremium => premiumStatus.isPremium;

  int get dailyRecipeLimit =>
      remoteConfigRepository?.getCachedConfig().freeDailyRecipeLimit ??
      SubscriptionConfig.freeRecipeGenerationsPerDay;

  int get weeklyPlanLimit =>
      remoteConfigRepository?.getCachedConfig().freeWeeklyPlanLimit ??
      SubscriptionConfig.freeWeeklyPlanGenerationsPerWeek;

  int get favoriteLimit =>
      remoteConfigRepository?.getCachedConfig().freeFavoriteLimit ??
      SubscriptionConfig.freeSavedRecipesLimit;

  // --- Recipe generation (daily limit) ---

  bool canGenerateRecipe() {
    if (isPremium) return true;
    return _dailyCount(PreferenceKeys.recipeGenerationCountPrefix) <
        dailyRecipeLimit;
  }

  int remainingRecipeGenerationsToday() {
    if (isPremium) return -1; // unlimited
    final remaining =
        dailyRecipeLimit -
        _dailyCount(PreferenceKeys.recipeGenerationCountPrefix);
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
        weeklyPlanLimit;
  }

  Future<void> recordWeeklyPlanGeneration() async {
    if (isPremium) return;
    await _incrementWeekly(PreferenceKeys.weeklyPlanGenerationCountPrefix);
  }

  // --- Saved recipes (standing limit, not time-boxed) ---

  bool canSaveRecipe(int currentSavedCount) {
    if (isPremium) return true;
    return currentSavedCount < favoriteLimit;
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
