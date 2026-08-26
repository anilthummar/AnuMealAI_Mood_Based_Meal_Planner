import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/notification_service.dart';
import '../../../profile/domain/repositories/profile_repository.dart';
import 'onboarding_state.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  final ProfileRepository profileRepository;
  final AnalyticsService analytics;
  final NotificationService? notificationService;

  OnboardingCubit({
    required this.profileRepository,
    required this.analytics,
    this.notificationService,
  }) : super(const OnboardingState());

  void nextStep() {
    if (state.currentStep < state.totalSteps - 1) {
      emit(state.copyWith(currentStep: state.currentStep + 1));
    }
  }

  void previousStep() {
    if (state.currentStep > 0) {
      emit(state.copyWith(currentStep: state.currentStep - 1));
    }
  }

  void goToStep(int step) {
    if (step >= 0 && step < state.totalSteps) {
      emit(state.copyWith(currentStep: step));
    }
  }

  void updateName(String name) {
    emit(
      state.copyWith(
        preferences: state.preferences.copyWith(name: name.trim()),
      ),
    );
  }

  void toggleDietary(String dietary) {
    final list = List<String>.from(state.preferences.dietaryRestrictions);
    if (list.contains(dietary)) {
      list.remove(dietary);
    } else {
      list.add(dietary);
    }
    emit(
      state.copyWith(
        preferences: state.preferences.copyWith(dietaryRestrictions: list),
      ),
    );
  }

  void toggleCuisine(String cuisine) {
    final list = List<String>.from(state.preferences.favoriteCuisines);
    if (list.contains(cuisine)) {
      list.remove(cuisine);
    } else {
      list.add(cuisine);
    }
    emit(
      state.copyWith(
        preferences: state.preferences.copyWith(favoriteCuisines: list),
      ),
    );
  }

  void setCookingSkill(String skill) {
    emit(
      state.copyWith(
        preferences: state.preferences.copyWith(cookingSkill: skill),
      ),
    );
  }

  void setTypicalTime(int minutes) {
    emit(
      state.copyWith(
        preferences: state.preferences.copyWith(
          typicalCookingTimeMinutes: minutes,
        ),
      ),
    );
  }

  void toggleGoal(String goal) {
    final list = List<String>.from(state.preferences.mealGoals);
    if (list.contains(goal)) {
      list.remove(goal);
    } else {
      list.add(goal);
    }
    emit(
      state.copyWith(preferences: state.preferences.copyWith(mealGoals: list)),
    );
  }

  void setNotificationsEnabled(bool enabled) {
    emit(
      state.copyWith(
        preferences: state.preferences.copyWith(notificationsEnabled: enabled),
      ),
    );
  }

  Future<bool> requestNotificationPermission() async {
    if (notificationService != null) {
      final granted = await notificationService!.requestPermission();
      emit(
        state.copyWith(
          preferences: state.preferences.copyWith(
            notificationsEnabled: granted,
          ),
        ),
      );
      return granted;
    }
    return true;
  }

  Future<void> completeOnboarding() async {
    emit(state.copyWith(status: OnboardingStatus.completing));
    try {
      final finalPrefs = state.preferences.copyWith(
        isOnboardingCompleted: true,
      );
      await profileRepository.savePreferences(finalPrefs);
      await profileRepository.setOnboardingCompleted(true);
      await analytics.logOnboardingCompleted();
      emit(
        state.copyWith(
          status: OnboardingStatus.completed,
          preferences: finalPrefs,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: OnboardingStatus.error,
          errorMessage: 'Failed to complete setup. Please try again.',
        ),
      );
    }
  }
}
