import 'package:uuid/uuid.dart';

import '../../../../core/services/ai/ai_recipe_models.dart';
import '../../../../core/services/ai/ai_recipe_service.dart';
import '../../domain/entities/recipe.dart';
import '../../domain/repositories/recipe_repository.dart';
import '../../domain/services/recipe_match_calculator.dart';
import '../datasources/recipe_local_data_source.dart';
import '../models/recipe_model.dart';

class RecipeRepositoryImpl implements RecipeRepository {
  final AIRecipeService aiService;
  final RecipeLocalDataSource localDataSource;
  final Uuid _uuid = const Uuid();

  RecipeRepositoryImpl({
    required this.aiService,
    required this.localDataSource,
  });

  @override
  Future<List<Recipe>> generateRecipes({
    required String moodId,
    required List<String> moodTraits,
    required List<String> availableIngredients,
    required String mealType,
    required int maxCookingTimeMinutes,
    List<String> dietaryPreferences = const [],
    List<String> cuisinePreferences = const [],
    int count = 5,
  }) async {
    final req = AiRecipeRequest(
      moodId: moodId,
      moodTraits: moodTraits,
      availableIngredients: availableIngredients,
      mealType: mealType,
      maxCookingTimeMinutes: maxCookingTimeMinutes,
      dietaryPreferences: dietaryPreferences,
      cuisinePreferences: cuisinePreferences,
      count: count,
    );

    final suggestions = await aiService.generateRecipes(req);
    final recipes = <RecipeModel>[];

    for (final s in suggestions) {
      final totalMinutes = s.prepTimeMinutes + s.cookTimeMinutes;
      final match = RecipeMatchCalculator.calculate(
        recipeIngredients: s.ingredients,
        availableIngredients: availableIngredients,
        recipeMood: moodId,
        selectedMood: moodId,
        recipeMealType: s.mealType,
        selectedMealType: mealType,
        recipeTotalMinutes: totalMinutes,
        maxCookingMinutes: maxCookingTimeMinutes,
        userDietary: dietaryPreferences,
        userCuisines: cuisinePreferences,
        recipeCuisine: s.cuisine,
      );

      final recipe = RecipeModel(
        id: _uuid.v4(),
        title: s.title,
        description: s.description,
        mood: moodId,
        mealType: s.mealType,
        prepTimeMinutes: s.prepTimeMinutes,
        cookTimeMinutes: s.cookTimeMinutes,
        difficulty: s.difficulty,
        matchPercentage: match.matchPercentage,
        ingredients: s.ingredients,
        missingIngredients: match.missingIngredients,
        instructions: s.instructions,
        tips: s.tips,
        nutrition: s.nutrition,
        cuisine: s.cuisine,
      );

      recipes.add(recipe);
    }

    recipes.sort((a, b) => b.matchPercentage.compareTo(a.matchPercentage));
    await localDataSource.saveAll(recipes);
    return recipes;
  }

  @override
  Future<Recipe?> getRecipeById(String id) async {
    return localDataSource.getById(id);
  }

  @override
  Future<List<Recipe>> getCachedRecipes() async {
    return localDataSource.getAllCached();
  }

  @override
  Future<void> saveRecipe(Recipe recipe) async {
    await localDataSource.save(RecipeModel.fromEntity(recipe));
  }

  @override
  Future<void> markRecipeCooked(String id) async {
    await localDataSource.markCooked(id);
  }

  @override
  Future<void> rateRecipe(String id, String rating) async {
    await localDataSource.saveFeedback(id, rating);
  }

  @override
  Future<List<Recipe>> getQuickSuggestions({
    required String moodId,
    required List<String> availableIngredients,
  }) async {
    return generateRecipes(
      moodId: moodId,
      moodTraits: const [],
      availableIngredients: availableIngredients,
      mealType: 'any',
      maxCookingTimeMinutes: 30,
      count: 3,
    );
  }
}
