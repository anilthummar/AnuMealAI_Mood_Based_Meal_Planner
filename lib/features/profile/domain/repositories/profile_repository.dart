import '../entities/user_preferences.dart';

abstract class ProfileRepository {
  Future<UserPreferences> getPreferences();
  Future<void> savePreferences(UserPreferences preferences);
  Future<bool> isOnboardingCompleted();
  Future<void> setOnboardingCompleted(bool completed);
  Future<int> getMealsCookedCount();
  Future<void> incrementMealsCookedCount();
  Future<int> getCookingStreakDays();
  Future<void> recordCookingStreak();
}
