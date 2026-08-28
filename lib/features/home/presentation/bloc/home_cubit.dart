import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../ingredients/domain/repositories/ingredient_repository.dart';
import '../../../mood/domain/repositories/mood_repository.dart';
import '../../../profile/domain/repositories/profile_repository.dart';
import '../../../recipes/domain/repositories/recipe_repository.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final ProfileRepository profileRepository;
  final IngredientRepository ingredientRepository;
  final RecipeRepository recipeRepository;
  final MoodRepository moodRepository;

  HomeCubit({
    required this.profileRepository,
    required this.ingredientRepository,
    required this.recipeRepository,
    required this.moodRepository,
  }) : super(const HomeState());

  Future<void> loadDashboard() async {
    emit(state.copyWith(status: HomeStatus.loading));
    try {
      final hour = DateTime.now().hour;
      final greeting = hour < 12
          ? 'Good morning'
          : (hour < 17 ? 'Good afternoon' : 'Good evening');

      final results = await Future.wait([
        profileRepository.getPreferences(),
        profileRepository.getCookingStreakDays(),
        profileRepository.getMealsCookedCount(),
        ingredientRepository.getIngredients(),
      ]);

      final prefs = results[0] as dynamic;
      final streak = results[1] as int;
      final mealsCount = results[2] as int;
      final ingredients = results[3] as List<dynamic>;
      final availableIngredients = ingredients
          .where((i) => i.isAvailable == true)
          .toList();
      final availableNames = availableIngredients
          .map((i) => i.name.toString())
          .toList();

      final currentMood =
          moodRepository.getSelectedMood() ??
          moodRepository.getAllMoods().first;

      final quickList = await recipeRepository.getQuickSuggestions(
        moodId: currentMood.id,
        availableIngredients: availableNames,
      );

      // Personalized insight logic (§34)
      final favCuisines = prefs.favoriteCuisines;
      final preferredCuisine = favCuisines.isNotEmpty
          ? favCuisines.first
          : 'Italian';
      final headline = mealsCount > 2
          ? "Based on your recent meals: quick $preferredCuisine favorites"
          : "Trending for your ${currentMood.name.toLowerCase()} mood";

      final personalizedRec = quickList.isNotEmpty ? quickList.first : null;

      emit(
        state.copyWith(
          status: HomeStatus.loaded,
          greeting: greeting,
          userName: prefs.name.isNotEmpty ? prefs.name : 'Anu',
          availableIngredientsCount: availableIngredients.length,
          cookingStreakDays: streak,
          mealsCookedCount: mealsCount,
          quickSuggestions: quickList,
          personalizedRecommendation: personalizedRec,
          personalizedHeadline: headline,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: HomeStatus.error,
          errorMessage: 'Failed to load home dashboard',
        ),
      );
    }
  }
}
