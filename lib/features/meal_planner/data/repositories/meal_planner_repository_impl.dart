import 'package:uuid/uuid.dart';

import '../../../recipes/domain/repositories/recipe_repository.dart';
import '../../domain/entities/meal_plan_entry.dart';
import '../../domain/entities/weekly_meal_plan.dart';
import '../../domain/repositories/meal_planner_repository.dart';
import '../datasources/meal_planner_local_data_source.dart';
import '../models/meal_plan_model.dart';

class MealPlannerRepositoryImpl implements MealPlannerRepository {
  final MealPlannerLocalDataSource localDataSource;
  final RecipeRepository recipeRepository;
  final Uuid _uuid = const Uuid();

  MealPlannerRepositoryImpl({
    required this.localDataSource,
    required this.recipeRepository,
  });

  @override
  Future<WeeklyMealPlan?> getCurrentWeekPlan() async {
    return localDataSource.getCurrent();
  }

  @override
  Stream<WeeklyMealPlan?> get currentPlanStream => localDataSource.stream;

  @override
  Future<WeeklyMealPlan> generateWeeklyPlan({
    required String moodId,
    required List<String> moodTraits,
    required List<String> availableIngredients,
    List<String> dietaryRestrictions = const [],
    List<String> favoriteCuisines = const [],
  }) async {
    final entries = <MealPlanEntryModel>[];
    final now = DateTime.now();

    // Fetch batch recipes for breakfast, lunch, dinner, snack
    final breakfastList = await recipeRepository.generateRecipes(
      moodId: moodId,
      moodTraits: moodTraits,
      availableIngredients: availableIngredients,
      mealType: 'breakfast',
      maxCookingTimeMinutes: 20,
      dietaryPreferences: dietaryRestrictions,
      cuisinePreferences: favoriteCuisines,
      count: 7,
    );

    final lunchList = await recipeRepository.generateRecipes(
      moodId: moodId,
      moodTraits: moodTraits,
      availableIngredients: availableIngredients,
      mealType: 'lunch',
      maxCookingTimeMinutes: 30,
      dietaryPreferences: dietaryRestrictions,
      cuisinePreferences: favoriteCuisines,
      count: 7,
    );

    final dinnerList = await recipeRepository.generateRecipes(
      moodId: moodId,
      moodTraits: moodTraits,
      availableIngredients: availableIngredients,
      mealType: 'dinner',
      maxCookingTimeMinutes: 45,
      dietaryPreferences: dietaryRestrictions,
      cuisinePreferences: favoriteCuisines,
      count: 7,
    );

    final snackList = await recipeRepository.generateRecipes(
      moodId: moodId,
      moodTraits: moodTraits,
      availableIngredients: availableIngredients,
      mealType: 'snack',
      maxCookingTimeMinutes: 15,
      dietaryPreferences: dietaryRestrictions,
      cuisinePreferences: favoriteCuisines,
      count: 7,
    );

    for (int i = 0; i < WeeklyMealPlan.days.length; i++) {
      final day = WeeklyMealPlan.days[i];

      final bRecipe = breakfastList[i % breakfastList.length];
      final lRecipe = lunchList[i % lunchList.length];
      final dRecipe = dinnerList[i % dinnerList.length];
      final sRecipe = snackList[i % snackList.length];

      entries.add(MealPlanEntryModel(id: _uuid.v4(), dayOfWeek: day, mealSlot: 'Breakfast', recipe: bRecipe));
      entries.add(MealPlanEntryModel(id: _uuid.v4(), dayOfWeek: day, mealSlot: 'Lunch', recipe: lRecipe));
      entries.add(MealPlanEntryModel(id: _uuid.v4(), dayOfWeek: day, mealSlot: 'Dinner', recipe: dRecipe));
      entries.add(MealPlanEntryModel(id: _uuid.v4(), dayOfWeek: day, mealSlot: 'Snack', recipe: sRecipe));
    }

    final plan = WeeklyMealPlanModel(
      id: _uuid.v4(),
      weekStartDate: now,
      entries: entries,
      createdAt: now,
    );

    await localDataSource.save(plan);
    return plan;
  }

  @override
  Future<void> saveWeeklyPlan(WeeklyMealPlan plan) async {
    final model = WeeklyMealPlanModel(
      id: plan.id,
      weekStartDate: plan.weekStartDate,
      entries: plan.entries,
      createdAt: plan.createdAt,
    );
    await localDataSource.save(model);
  }

  @override
  Future<void> replaceMeal({
    required String entryId,
    required String moodId,
    required List<String> availableIngredients,
  }) async {
    final current = localDataSource.getCurrent();
    if (current == null) return;

    final entryIndex = current.entries.indexWhere((e) => e.id == entryId);
    if (entryIndex == -1) return;

    final oldEntry = current.entries[entryIndex];
    final replacementList = await recipeRepository.generateRecipes(
      moodId: moodId,
      moodTraits: const [],
      availableIngredients: availableIngredients,
      mealType: oldEntry.mealSlot.toLowerCase(),
      maxCookingTimeMinutes: 45,
      count: 3,
    );

    final newRecipe = replacementList.firstWhere(
      (r) => r.id != oldEntry.recipe.id,
      orElse: () => replacementList.first,
    );

    final updatedEntries = List<MealPlanEntry>.from(current.entries);
    updatedEntries[entryIndex] = oldEntry.copyWith(recipe: newRecipe);

    await saveWeeklyPlan(current.copyWith(entries: updatedEntries));
  }

  @override
  Future<void> toggleMealCooked(String entryId) async {
    final current = localDataSource.getCurrent();
    if (current == null) return;

    final entryIndex = current.entries.indexWhere((e) => e.id == entryId);
    if (entryIndex == -1) return;

    final old = current.entries[entryIndex];
    final updatedEntries = List<MealPlanEntry>.from(current.entries);
    updatedEntries[entryIndex] = old.copyWith(isCooked: !old.isCooked);

    await saveWeeklyPlan(current.copyWith(entries: updatedEntries));
  }
}
