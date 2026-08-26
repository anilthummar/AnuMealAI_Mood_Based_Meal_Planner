import 'package:equatable/equatable.dart';

class Recipe extends Equatable {
  final String id;
  final String title;
  final String description;
  final String mood;
  final String mealType;
  final int prepTimeMinutes;
  final int cookTimeMinutes;
  final String difficulty;
  final int matchPercentage;
  final List<String> ingredients;
  final List<String> missingIngredients;
  final List<String> instructions;
  final List<String> tips;
  final Map<String, dynamic> nutrition;
  final String? imageUrl;
  final String cuisine;
  final bool isFavorite;
  final DateTime? cookedAt;

  const Recipe({
    required this.id,
    required this.title,
    required this.description,
    required this.mood,
    required this.mealType,
    required this.prepTimeMinutes,
    required this.cookTimeMinutes,
    required this.difficulty,
    required this.matchPercentage,
    required this.ingredients,
    required this.missingIngredients,
    required this.instructions,
    this.tips = const [],
    this.nutrition = const {},
    this.imageUrl,
    this.cuisine = '',
    this.isFavorite = false,
    this.cookedAt,
  });

  int get totalTimeMinutes => prepTimeMinutes + cookTimeMinutes;
  bool get isCooked => cookedAt != null;
  int get calories => (nutrition['calories'] as num?)?.toInt() ?? 380;

  Recipe copyWith({
    String? id,
    String? title,
    String? description,
    String? mood,
    String? mealType,
    int? prepTimeMinutes,
    int? cookTimeMinutes,
    String? difficulty,
    int? matchPercentage,
    List<String>? ingredients,
    List<String>? missingIngredients,
    List<String>? instructions,
    List<String>? tips,
    Map<String, dynamic>? nutrition,
    String? imageUrl,
    String? cuisine,
    bool? isFavorite,
    DateTime? cookedAt,
  }) {
    return Recipe(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      mood: mood ?? this.mood,
      mealType: mealType ?? this.mealType,
      prepTimeMinutes: prepTimeMinutes ?? this.prepTimeMinutes,
      cookTimeMinutes: cookTimeMinutes ?? this.cookTimeMinutes,
      difficulty: difficulty ?? this.difficulty,
      matchPercentage: matchPercentage ?? this.matchPercentage,
      ingredients: ingredients ?? this.ingredients,
      missingIngredients: missingIngredients ?? this.missingIngredients,
      instructions: instructions ?? this.instructions,
      tips: tips ?? this.tips,
      nutrition: nutrition ?? this.nutrition,
      imageUrl: imageUrl ?? this.imageUrl,
      cuisine: cuisine ?? this.cuisine,
      isFavorite: isFavorite ?? this.isFavorite,
      cookedAt: cookedAt ?? this.cookedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        mood,
        mealType,
        prepTimeMinutes,
        cookTimeMinutes,
        difficulty,
        matchPercentage,
        ingredients,
        missingIngredients,
        instructions,
        tips,
        nutrition,
        imageUrl,
        cuisine,
        isFavorite,
        cookedAt,
      ];
}
