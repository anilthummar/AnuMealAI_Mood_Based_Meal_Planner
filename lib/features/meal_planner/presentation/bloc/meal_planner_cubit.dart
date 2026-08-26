import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/feature_access_service.dart';
import '../../domain/entities/weekly_meal_plan.dart';
import '../../domain/repositories/meal_planner_repository.dart';
import 'meal_planner_state.dart';

class MealPlannerCubit extends Cubit<MealPlannerState> {
  final MealPlannerRepository mealPlannerRepository;
  final FeatureAccessService featureAccess;
  final AnalyticsService analytics;
  StreamSubscription? _subscription;

  MealPlannerCubit({
    required this.mealPlannerRepository,
    required this.featureAccess,
    required this.analytics,
  }) : super(const MealPlannerState()) {
    _init();
  }

  void _init() {
    _subscription = mealPlannerRepository.currentPlanStream.listen((plan) {
      emit(state.copyWith(
        status: MealPlannerStatus.loaded,
        currentPlan: plan,
      ));
    });
    loadCurrentPlan();
  }

  void selectDay(dynamic day) {
    if (day is int) {
      if (day >= 0 && day < WeeklyMealPlan.days.length) {
        emit(state.copyWith(selectedDay: WeeklyMealPlan.days[day]));
      }
    } else {
      emit(state.copyWith(selectedDay: day.toString()));
    }
  }

  Future<void> loadCurrentPlan() async {
    emit(state.copyWith(status: MealPlannerStatus.loading));
    try {
      final plan = await mealPlannerRepository.getCurrentWeekPlan();
      emit(state.copyWith(
        status: MealPlannerStatus.loaded,
        currentPlan: plan,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: MealPlannerStatus.error,
        errorMessage: 'Failed to load meal plan',
      ));
    }
  }

  Future<bool> generateWeekPlan({
    required String moodId,
    required List<String> moodTraits,
    required List<String> availableIngredients,
    List<String> dietaryRestrictions = const [],
    List<String> favoriteCuisines = const [],
  }) async {
    if (!featureAccess.canGenerateWeeklyPlan()) {
      emit(state.copyWith(
        status: MealPlannerStatus.error,
        errorMessage: 'PLAN_LIMIT_REACHED',
      ));
      return false;
    }

    emit(state.copyWith(status: MealPlannerStatus.generating, isGenerating: true, errorMessage: null));
    try {
      final plan = await mealPlannerRepository.generateWeeklyPlan(
        moodId: moodId,
        moodTraits: moodTraits,
        availableIngredients: availableIngredients,
        dietaryRestrictions: dietaryRestrictions,
        favoriteCuisines: favoriteCuisines,
      );

      await featureAccess.recordWeeklyPlanGeneration();
      await analytics.logMealPlanGenerated(moodId);

      emit(state.copyWith(
        status: MealPlannerStatus.loaded,
        currentPlan: plan,
        isGenerating: false,
      ));
      return true;
    } catch (e) {
      emit(state.copyWith(
        status: MealPlannerStatus.error,
        isGenerating: false,
        errorMessage: 'Failed to generate weekly meal plan',
      ));
      return false;
    }
  }

  Future<void> swapMeal({
    required String entryId,
    required String moodId,
    required List<String> availableIngredients,
  }) async {
    await mealPlannerRepository.replaceMeal(
      entryId: entryId,
      moodId: moodId,
      availableIngredients: availableIngredients,
    );
  }

  Future<void> replaceMeal({
    required String entryId,
    required String moodId,
    required List<String> availableIngredients,
  }) async {
    await swapMeal(
      entryId: entryId,
      moodId: moodId,
      availableIngredients: availableIngredients,
    );
  }

  Future<void> toggleMealCooked(String entryId) async {
    await mealPlannerRepository.toggleMealCooked(entryId);
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
