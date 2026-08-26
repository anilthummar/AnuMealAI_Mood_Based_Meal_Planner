import 'dart:math';

/// Deterministic local recipe matching engine (§44, §45).
/// Guarantees that match percentage is never arbitrarily hallucinated by an AI.
class RecipeMatchResult {
  final int matchPercentage;
  final List<String> availableIngredientsUsed;
  final List<String> missingIngredients;
  final String matchReason;

  const RecipeMatchResult({
    required this.matchPercentage,
    required this.availableIngredientsUsed,
    required this.missingIngredients,
    required this.matchReason,
  });
}

class RecipeMatchCalculator {
  RecipeMatchCalculator._();

  static RecipeMatchResult calculate({
    required List<String> recipeIngredients,
    required List<String> availableIngredients,
    required String recipeMood,
    required String selectedMood,
    required String recipeMealType,
    required String selectedMealType,
    required int recipeTotalMinutes,
    required int maxCookingMinutes,
    List<String> userDietary = const [],
    List<String> userCuisines = const [],
    String recipeCuisine = '',
  }) {
    final availableNormalized = availableIngredients.map((e) => e.toLowerCase().trim()).toSet();
    final used = <String>[];
    final missing = <String>[];

    for (final raw in recipeIngredients) {
      final norm = raw.toLowerCase().trim();
      final hasOverlap = availableNormalized.any((avail) {
        return norm.contains(avail) || avail.contains(norm);
      });
      if (hasOverlap) {
        used.add(raw);
      } else {
        missing.add(raw);
      }
    }

    // 1. Ingredient Match (45% weight)
    final ingredientRatio = recipeIngredients.isEmpty ? 1.0 : (used.length / recipeIngredients.length);
    final ingredientScore = ingredientRatio * 45.0;

    // 2. Mood Match (20% weight)
    final moodScore = (recipeMood.toLowerCase() == selectedMood.toLowerCase()) ? 20.0 : 10.0;

    // 3. Meal Type Match (15% weight)
    final mealTypeScore = (selectedMealType.toLowerCase() == 'any' ||
            recipeMealType.toLowerCase() == selectedMealType.toLowerCase())
        ? 15.0
        : 5.0;

    // 4. Time Match (10% weight)
    double timeScore = 10.0;
    if (recipeTotalMinutes > maxCookingMinutes) {
      final overage = recipeTotalMinutes - maxCookingMinutes;
      timeScore = max(0.0, 10.0 - (overage / 5.0));
    }

    // 5. Cuisine & Dietary Match (10% weight)
    double cuisineScore = 5.0;
    if (userCuisines.isNotEmpty && recipeCuisine.isNotEmpty) {
      if (userCuisines.any((c) => c.toLowerCase() == recipeCuisine.toLowerCase())) {
        cuisineScore = 10.0;
      }
    }

    final totalScore = (ingredientScore + moodScore + mealTypeScore + timeScore + cuisineScore).round().clamp(0, 100);

    String reason;
    if (missing.isEmpty) {
      reason = '$totalScore% match — uses everything already in your kitchen.';
    } else if (missing.length <= 2) {
      reason = '$totalScore% match — only missing ${missing.length} ingredient${missing.length > 1 ? 's' : ''}.';
    } else {
      reason = '$totalScore% match — great fit for your $selectedMood mood.';
    }

    return RecipeMatchResult(
      matchPercentage: totalScore,
      availableIngredientsUsed: used,
      missingIngredients: missing,
      matchReason: reason,
    );
  }
}
