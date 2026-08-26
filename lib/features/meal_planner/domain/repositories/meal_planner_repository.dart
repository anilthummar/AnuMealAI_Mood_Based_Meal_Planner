import '../entities/weekly_meal_plan.dart';

abstract class MealPlannerRepository {
  Future<WeeklyMealPlan?> getCurrentWeekPlan();
  Stream<WeeklyMealPlan?> get currentPlanStream;
  Future<WeeklyMealPlan> generateWeeklyPlan({
    required String moodId,
    required List<String> moodTraits,
    required List<String> availableIngredients,
    List<String> dietaryRestrictions = const [],
    List<String> favoriteCuisines = const [],
  });
  Future<void> saveWeeklyPlan(WeeklyMealPlan plan);
  Future<void> replaceMeal({
    required String entryId,
    required String moodId,
    required List<String> availableIngredients,
  });
  Future<void> toggleMealCooked(String entryId);
}
