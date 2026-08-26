import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/user_preferences.dart';
import '../../domain/repositories/profile_repository.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository profileRepository;

  ProfileCubit({required this.profileRepository}) : super(const ProfileState());

  Future<void> loadProfile() async {
    emit(state.copyWith(status: ProfileStatus.loading));
    try {
      final prefs = await profileRepository.getPreferences();
      final meals = await profileRepository.getMealsCookedCount();
      final streak = await profileRepository.getCookingStreakDays();
      emit(
        state.copyWith(
          status: ProfileStatus.loaded,
          preferences: prefs,
          mealsCooked: meals,
          cookingStreak: streak,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ProfileStatus.error,
          errorMessage: 'Failed to load profile settings',
        ),
      );
    }
  }

  Future<void> updatePreferences(UserPreferences updated) async {
    emit(state.copyWith(status: ProfileStatus.saving, preferences: updated));
    try {
      await profileRepository.savePreferences(updated);
      emit(state.copyWith(status: ProfileStatus.loaded));
    } catch (e) {
      emit(
        state.copyWith(
          status: ProfileStatus.error,
          errorMessage: 'Failed to save preferences',
        ),
      );
    }
  }

  Future<void> updateName(String name) async {
    final updated = state.preferences.copyWith(name: name.trim());
    await updatePreferences(updated);
  }

  Future<void> updateAvatar(String path) async {
    final updated = state.preferences.copyWith(avatarPath: path);
    await updatePreferences(updated);
  }

  Future<void> removeAvatar() async {
    final updated = state.preferences.copyWith(clearAvatar: true);
    await updatePreferences(updated);
  }

  Future<void> toggleDietaryRestriction(String item) async {
    final list = List<String>.from(state.preferences.dietaryRestrictions);
    if (list.contains(item)) {
      list.remove(item);
    } else {
      list.add(item);
    }
    await updatePreferences(
      state.preferences.copyWith(dietaryRestrictions: list),
    );
  }

  Future<void> toggleCuisine(String cuisine) async {
    final list = List<String>.from(state.preferences.favoriteCuisines);
    if (list.contains(cuisine)) {
      list.remove(cuisine);
    } else {
      list.add(cuisine);
    }
    await updatePreferences(state.preferences.copyWith(favoriteCuisines: list));
  }

  Future<void> setCookingSkill(String skill) async {
    await updatePreferences(state.preferences.copyWith(cookingSkill: skill));
  }

  Future<void> setCookingTime(int minutes) async {
    await updatePreferences(
      state.preferences.copyWith(typicalCookingTimeMinutes: minutes),
    );
  }

  Future<void> recordMealCooked() async {
    await profileRepository.incrementMealsCookedCount();
    await profileRepository.recordCookingStreak();
    await loadProfile();
  }
}
