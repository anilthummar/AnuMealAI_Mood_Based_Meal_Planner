import '../../domain/entities/user_preferences.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_local_data_source.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileLocalDataSource localDataSource;

  ProfileRepositoryImpl({required this.localDataSource});

  @override
  Future<UserPreferences> getPreferences() async {
    return localDataSource.getPreferences();
  }

  @override
  Future<void> savePreferences(UserPreferences preferences) async {
    await localDataSource.savePreferences(preferences);
  }

  @override
  Future<bool> isOnboardingCompleted() async {
    return localDataSource.isOnboardingCompleted();
  }

  @override
  Future<void> setOnboardingCompleted(bool completed) async {
    await localDataSource.setOnboardingCompleted(completed);
  }

  @override
  Future<int> getMealsCookedCount() async {
    return localDataSource.getMealsCookedCount();
  }

  @override
  Future<void> incrementMealsCookedCount() async {
    await localDataSource.incrementMealsCookedCount();
  }

  @override
  Future<int> getCookingStreakDays() async {
    return localDataSource.getCookingStreakDays();
  }

  @override
  Future<void> recordCookingStreak() async {
    await localDataSource.recordCookingStreak();
  }
}
