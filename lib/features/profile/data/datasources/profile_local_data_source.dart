import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/preference_keys.dart';
import '../../domain/entities/user_preferences.dart';

class ProfileLocalDataSource {
  final SharedPreferences prefs;

  ProfileLocalDataSource({required this.prefs});

  UserPreferences getPreferences() {
    final raw = prefs.getString(PreferenceKeys.userPreferencesJson);
    if (raw == null || raw.isEmpty) {
      final onboardingDone = prefs.getBool(PreferenceKeys.onboardingComplete) ?? false;
      return UserPreferences(isOnboardingCompleted: onboardingDone);
    }
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return UserPreferences.fromMap(map);
    } catch (_) {
      return const UserPreferences();
    }
  }

  Future<void> savePreferences(UserPreferences preferences) async {
    final raw = jsonEncode(preferences.toMap());
    await prefs.setString(PreferenceKeys.userPreferencesJson, raw);
    await prefs.setBool(PreferenceKeys.onboardingComplete, preferences.isOnboardingCompleted);
  }

  bool isOnboardingCompleted() {
    return prefs.getBool(PreferenceKeys.onboardingComplete) ?? false;
  }

  Future<void> setOnboardingCompleted(bool completed) async {
    await prefs.setBool(PreferenceKeys.onboardingComplete, completed);
  }

  int getMealsCookedCount() {
    return prefs.getInt('meals_cooked_count') ?? 0;
  }

  Future<void> incrementMealsCookedCount() async {
    final current = getMealsCookedCount();
    await prefs.setInt('meals_cooked_count', current + 1);
  }

  int getCookingStreakDays() {
    return prefs.getInt('cooking_streak_days') ?? 1;
  }

  Future<void> recordCookingStreak() async {
    final lastCookedDate = prefs.getString('last_cooked_date');
    final today = DateTime.now().toIso8601String().substring(0, 10);

    if (lastCookedDate == today) return;

    if (lastCookedDate != null) {
      final lastDate = DateTime.tryParse(lastCookedDate);
      if (lastDate != null) {
        final diff = DateTime.now().difference(lastDate).inDays;
        if (diff == 1) {
          final streak = getCookingStreakDays() + 1;
          await prefs.setInt('cooking_streak_days', streak);
        } else if (diff > 1) {
          await prefs.setInt('cooking_streak_days', 1);
        }
      }
    } else {
      await prefs.setInt('cooking_streak_days', 1);
    }

    await prefs.setString('last_cooked_date', today);
  }
}
