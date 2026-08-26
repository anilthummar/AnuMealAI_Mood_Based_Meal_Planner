/// Provider-agnostic request/response DTOs for [AIRecipeService]. These live
/// in `core` (not a feature) so the AI abstraction has zero dependency on any
/// feature's domain layer — `features/recipes` maps [AiRecipeSuggestion] into
/// its own `Recipe` entity.
class AiRecipeRequest {
  final String moodId;
  final List<String> moodTraits;
  final List<String> availableIngredients;
  final String mealType;
  final int maxCookingTimeMinutes;
  final List<String> dietaryPreferences;
  final List<String> cuisinePreferences;
  final int count;

  const AiRecipeRequest({
    required this.moodId,
    required this.moodTraits,
    required this.availableIngredients,
    required this.mealType,
    required this.maxCookingTimeMinutes,
    this.dietaryPreferences = const [],
    this.cuisinePreferences = const [],
    this.count = 5,
  });

  Map<String, dynamic> toJson() => {
        'mood': moodId,
        'moodTraits': moodTraits,
        'availableIngredients': availableIngredients,
        'mealType': mealType,
        'maxCookingTimeMinutes': maxCookingTimeMinutes,
        'dietaryPreferences': dietaryPreferences,
        'cuisinePreferences': cuisinePreferences,
        'count': count,
      };
}

class AiRecipeSuggestion {
  final String title;
  final String description;
  final String mealType;
  final int prepTimeMinutes;
  final int cookTimeMinutes;
  final String difficulty;
  final List<String> ingredients;
  final List<String> instructions;
  final List<String> tips;
  final Map<String, dynamic> nutrition;
  final String cuisine;

  const AiRecipeSuggestion({
    required this.title,
    required this.description,
    required this.mealType,
    required this.prepTimeMinutes,
    required this.cookTimeMinutes,
    required this.difficulty,
    required this.ingredients,
    required this.instructions,
    required this.tips,
    required this.nutrition,
    this.cuisine = '',
  });

  /// Parses one recipe object from the structured JSON schema described in
  /// `AI_INTEGRATION.md`. Throws [FormatException] on malformed input — the
  /// caller (RemoteAIRecipeService) turns that into an [AiParsingException].
  factory AiRecipeSuggestion.fromJson(Map<String, dynamic> json) {
    final title = json['title'];
    final ingredients = json['ingredients'];
    final instructions = json['instructions'];
    if (title is! String || title.trim().isEmpty) {
      throw const FormatException('Recipe is missing a title.');
    }
    if (ingredients is! List || ingredients.isEmpty) {
      throw const FormatException('Recipe is missing ingredients.');
    }
    if (instructions is! List || instructions.isEmpty) {
      throw const FormatException('Recipe is missing instructions.');
    }
    return AiRecipeSuggestion(
      title: title.trim(),
      description: (json['description'] as String?)?.trim() ?? '',
      mealType: (json['mealType'] as String?)?.trim() ?? 'any',
      prepTimeMinutes: _asInt(json['prepTimeMinutes'], fallback: 10),
      cookTimeMinutes: _asInt(json['cookTimeMinutes'], fallback: 15),
      difficulty: (json['difficulty'] as String?)?.trim() ?? 'easy',
      ingredients: ingredients.map((e) => e.toString()).toList(),
      instructions: instructions.map((e) => e.toString()).toList(),
      tips: (json['tips'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      nutrition: (json['nutrition'] as Map?)?.cast<String, dynamic>() ?? const {},
      cuisine: (json['cuisine'] as String?)?.trim() ?? '',
    );
  }

  static int _asInt(dynamic value, {required int fallback}) {
    if (value is int) return value;
    if (value is num) return value.round();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }
}
