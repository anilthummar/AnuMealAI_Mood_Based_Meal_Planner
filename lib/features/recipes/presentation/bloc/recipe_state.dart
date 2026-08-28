import 'package:equatable/equatable.dart';

import '../../domain/entities/recipe.dart';

enum RecipeStatus { initial, loading, loaded, error }

class RecipeState extends Equatable {
  final RecipeStatus status;
  final List<Recipe> generatedRecipes;
  final List<Recipe> quickSuggestions;
  final Recipe? selectedRecipe;
  final String selectedMealType;
  final int maxCookingTimeMinutes;
  final String? errorMessage;
  final bool isGenerating;

  const RecipeState({
    this.status = RecipeStatus.initial,
    this.generatedRecipes = const [],
    this.quickSuggestions = const [],
    this.selectedRecipe,
    this.selectedMealType = 'any',
    this.maxCookingTimeMinutes = 30,
    this.errorMessage,
    this.isGenerating = false,
  });

  RecipeState copyWith({
    RecipeStatus? status,
    List<Recipe>? generatedRecipes,
    List<Recipe>? quickSuggestions,
    Recipe? selectedRecipe,
    String? selectedMealType,
    int? maxCookingTimeMinutes,
    String? errorMessage,
    bool clearError = false,
    bool? isGenerating,
  }) {
    return RecipeState(
      status: status ?? this.status,
      generatedRecipes: generatedRecipes ?? this.generatedRecipes,
      quickSuggestions: quickSuggestions ?? this.quickSuggestions,
      selectedRecipe: selectedRecipe ?? this.selectedRecipe,
      selectedMealType: selectedMealType ?? this.selectedMealType,
      maxCookingTimeMinutes:
          maxCookingTimeMinutes ?? this.maxCookingTimeMinutes,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isGenerating: isGenerating ?? this.isGenerating,
    );
  }

  @override
  List<Object?> get props => [
    status,
    generatedRecipes,
    quickSuggestions,
    selectedRecipe,
    selectedMealType,
    maxCookingTimeMinutes,
    errorMessage,
    isGenerating,
  ];
}
