import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/feature_access_service.dart';
import '../../domain/entities/recipe.dart';
import '../../domain/repositories/recipe_repository.dart';
import 'recipe_state.dart';

class RecipeCubit extends Cubit<RecipeState> {
  final RecipeRepository recipeRepository;
  final FeatureAccessService featureAccess;
  final AnalyticsService analytics;

  RecipeCubit({
    required this.recipeRepository,
    required this.featureAccess,
    required this.analytics,
  }) : super(const RecipeState());

  void setMealType(String mealType) {
    emit(state.copyWith(selectedMealType: mealType));
  }

  void setMaxCookingTime(int minutes) {
    emit(state.copyWith(maxCookingTimeMinutes: minutes));
  }

  Future<void> loadQuickSuggestions({
    required String moodId,
    required List<String> availableIngredients,
  }) async {
    try {
      final list = await recipeRepository.getQuickSuggestions(
        moodId: moodId,
        availableIngredients: availableIngredients,
      );
      emit(state.copyWith(quickSuggestions: list));
    } catch (_) {}
  }

  Future<bool> generateRecipes({
    required String moodId,
    required List<String> moodTraits,
    required List<String> availableIngredients,
    List<String> dietaryPreferences = const [],
    List<String> cuisinePreferences = const [],
  }) async {
    if (!featureAccess.canGenerateRecipe()) {
      emit(
        state.copyWith(
          status: RecipeStatus.error,
          errorMessage: 'DAILY_LIMIT_REACHED',
        ),
      );
      return false;
    }

    emit(
      state.copyWith(
        status: RecipeStatus.loading,
        isGenerating: true,
        errorMessage: null,
      ),
    );
    try {
      final recipes = await recipeRepository.generateRecipes(
        moodId: moodId,
        moodTraits: moodTraits,
        availableIngredients: availableIngredients,
        mealType: state.selectedMealType,
        maxCookingTimeMinutes: state.maxCookingTimeMinutes,
        dietaryPreferences: dietaryPreferences,
        cuisinePreferences: cuisinePreferences,
      );

      await featureAccess.recordRecipeGeneration();
      await analytics.logRecipeGenerated(moodId, availableIngredients.length);

      emit(
        state.copyWith(
          status: RecipeStatus.loaded,
          isGenerating: false,
          generatedRecipes: recipes,
        ),
      );
      return true;
    } catch (e) {
      emit(
        state.copyWith(
          status: RecipeStatus.error,
          isGenerating: false,
          errorMessage:
              'Unable to generate recipes right now. Please try again.',
        ),
      );
      return false;
    }
  }

  Future<void> selectRecipeById(String id) async {
    emit(state.copyWith(status: RecipeStatus.loading));
    try {
      final recipe = await recipeRepository.getRecipeById(id);
      if (recipe != null) {
        await analytics.logRecipeViewed(recipe.id, recipe.title);
        emit(
          state.copyWith(status: RecipeStatus.loaded, selectedRecipe: recipe),
        );
      } else {
        emit(
          state.copyWith(
            status: RecipeStatus.error,
            errorMessage: 'Recipe not found',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: RecipeStatus.error,
          errorMessage: 'Failed to load recipe',
        ),
      );
    }
  }

  void setSelectedRecipe(Recipe recipe) {
    analytics.logRecipeViewed(recipe.id, recipe.title);
    emit(state.copyWith(selectedRecipe: recipe));
  }

  Future<void> markRecipeCooked(String id) async {
    await recipeRepository.markRecipeCooked(id);
    await analytics.logRecipeCooked(id);
  }

  void clearError() {
    if (state.status == RecipeStatus.error) {
      emit(state.copyWith(status: RecipeStatus.initial, errorMessage: null));
    }
  }

  Future<void> rateRecipe(String id, String rating) async {
    await recipeRepository.rateRecipe(id, rating);
  }
}
