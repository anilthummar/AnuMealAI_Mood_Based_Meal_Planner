import 'package:equatable/equatable.dart';

import '../../../recipes/domain/entities/recipe.dart';

enum HomeStatus { initial, loading, loaded, error }

class HomeState extends Equatable {
  final HomeStatus status;
  final bool isDishesLoading;
  final String greeting;
  final String userName;
  final int availableIngredientsCount;
  final int cookingStreakDays;
  final int mealsCookedCount;
  final List<Recipe> quickSuggestions;
  final Recipe? personalizedRecommendation;
  final String personalizedHeadline;
  final String? errorMessage;

  const HomeState({
    this.status = HomeStatus.initial,
    this.isDishesLoading = false,
    this.greeting = 'Good evening',
    this.userName = 'Anu',
    this.availableIngredientsCount = 0,
    this.cookingStreakDays = 1,
    this.mealsCookedCount = 0,
    this.quickSuggestions = const [],
    this.personalizedRecommendation,
    this.personalizedHeadline = 'Trending in your kitchen',
    this.errorMessage,
  });

  HomeState copyWith({
    HomeStatus? status,
    bool? isDishesLoading,
    String? greeting,
    String? userName,
    int? availableIngredientsCount,
    int? cookingStreakDays,
    int? mealsCookedCount,
    List<Recipe>? quickSuggestions,
    Recipe? personalizedRecommendation,
    String? personalizedHeadline,
    String? errorMessage,
  }) {
    return HomeState(
      status: status ?? this.status,
      isDishesLoading: isDishesLoading ?? this.isDishesLoading,
      greeting: greeting ?? this.greeting,
      userName: userName ?? this.userName,
      availableIngredientsCount:
          availableIngredientsCount ?? this.availableIngredientsCount,
      cookingStreakDays: cookingStreakDays ?? this.cookingStreakDays,
      mealsCookedCount: mealsCookedCount ?? this.mealsCookedCount,
      quickSuggestions: quickSuggestions ?? this.quickSuggestions,
      personalizedRecommendation:
          personalizedRecommendation ?? this.personalizedRecommendation,
      personalizedHeadline: personalizedHeadline ?? this.personalizedHeadline,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    isDishesLoading,
    greeting,
    userName,
    availableIngredientsCount,
    cookingStreakDays,
    mealsCookedCount,
    quickSuggestions,
    personalizedRecommendation,
    personalizedHeadline,
    errorMessage,
  ];
}
