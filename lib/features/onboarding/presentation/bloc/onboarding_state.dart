import 'package:equatable/equatable.dart';

import '../../../profile/domain/entities/user_preferences.dart';

enum OnboardingStatus { inProgress, completing, completed, error }

class OnboardingState extends Equatable {
  final int currentStep;
  final int totalSteps;
  final UserPreferences preferences;
  final OnboardingStatus status;
  final String? errorMessage;

  const OnboardingState({
    this.currentStep = 0,
    this.totalSteps = 9,
    this.preferences = const UserPreferences(),
    this.status = OnboardingStatus.inProgress,
    this.errorMessage,
  });

  bool get isFirstStep => currentStep == 0;
  bool get isLastStep => currentStep == totalSteps - 1;
  double get progress => (currentStep + 1) / totalSteps;

  OnboardingState copyWith({
    int? currentStep,
    int? totalSteps,
    UserPreferences? preferences,
    OnboardingStatus? status,
    String? errorMessage,
  }) {
    return OnboardingState(
      currentStep: currentStep ?? this.currentStep,
      totalSteps: totalSteps ?? this.totalSteps,
      preferences: preferences ?? this.preferences,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [currentStep, totalSteps, preferences, status, errorMessage];
}
