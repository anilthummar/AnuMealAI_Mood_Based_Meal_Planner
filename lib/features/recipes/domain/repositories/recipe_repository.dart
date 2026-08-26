import '../entities/recipe.dart';

abstract class RecipeRepository {
  Future<List<Recipe>> generateRecipes({
    required String moodId,
    required List<String> moodTraits,
    required List<String> availableIngredients,
    required String mealType,
    required int maxCookingTimeMinutes,
    List<String> dietaryPreferences = const [],
    List<String> cuisinePreferences = const [],
    int count = 5,
  });

  Future<Recipe?> getRecipeById(String id);
  Future<List<Recipe>> getCachedRecipes();
  Future<void> saveRecipe(Recipe recipe);
  Future<void> markRecipeCooked(String id);
  Future<void> rateRecipe(String id, String rating);
  Future<List<Recipe>> getQuickSuggestions({
    required String moodId,
    required List<String> availableIngredients,
  });
}
