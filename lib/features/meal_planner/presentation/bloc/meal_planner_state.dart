import 'package:equatable/equatable.dart';

import '../../domain/entities/weekly_meal_plan.dart';

enum MealPlannerStatus { initial, loading, loaded, generating, error }

class MealPlannerState extends Equatable {
  final MealPlannerStatus status;
  final WeeklyMealPlan? currentPlan;
  final String selectedDay;
  final String? errorMessage;
  final bool isGenerating;

  const MealPlannerState({
    this.status = MealPlannerStatus.initial,
    this.currentPlan,
    this.selectedDay = 'Monday',
    this.errorMessage,
    this.isGenerating = false,
  });

  int get selectedDayIndex {
    final idx = WeeklyMealPlan.days.indexWhere(
      (d) => d.toLowerCase() == selectedDay.toLowerCase(),
    );
    return idx == -1 ? 0 : idx;
  }

  MealPlannerState copyWith({
    MealPlannerStatus? status,
    WeeklyMealPlan? currentPlan,
    String? selectedDay,
    String? errorMessage,
    bool clearError = false,
    bool? isGenerating,
  }) {
    return MealPlannerState(
      status: status ?? this.status,
      currentPlan: currentPlan ?? this.currentPlan,
      selectedDay: selectedDay ?? this.selectedDay,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isGenerating: isGenerating ?? this.isGenerating,
    );
  }

  @override
  List<Object?> get props => [
    status,
    currentPlan,
    selectedDay,
    errorMessage,
    isGenerating,
  ];
}
