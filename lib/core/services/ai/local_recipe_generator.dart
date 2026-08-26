import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart' show rootBundle;

import 'ai_recipe_models.dart';
import 'ai_recipe_service.dart';

/// Deterministic, fully-offline recipe generator built from a curated local
/// template bank (`assets/data/recipe_templates.json`). This is **not** an
/// LLM — it is the honest, always-available fallback described in §11/§45:
/// "never crash the app because AI failed... show a beautiful fallback
/// state." It is also what powers the whole app out of the box before an AI
/// backend key is configured, so "What can I cook?" is never a dead feature.
///
/// Scoring here is intentionally simple (ingredient/mood/meal-type/time
/// overlap) — the *authoritative* match percentage shown to the user is
/// always recomputed by `RecipeMatchCalculator` in the recipes feature, never
/// trusted from this class.
class LocalRecipeGenerator implements AIRecipeService {
  List<Map<String, dynamic>>? _cache;

  Future<List<Map<String, dynamic>>> _loadTemplates() async {
    if (_cache != null) return _cache!;
    final raw = await rootBundle.loadString('assets/data/recipe_templates.json');
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    _cache = (decoded['recipes'] as List).cast<Map<String, dynamic>>();
    return _cache!;
  }

  @override
  Future<List<AiRecipeSuggestion>> generateRecipes(AiRecipeRequest request) async {
    final templates = await _loadTemplates();
    final available = request.availableIngredients.map((e) => e.toLowerCase().trim()).toSet();

    final scored = templates.map((t) {
      final ingredients = (t['ingredients'] as List).map((e) => e.toString().toLowerCase());
      final overlap = ingredients.where(available.contains).length;
      final ingredientScore = ingredients.isEmpty ? 0.0 : overlap / ingredients.length;

      final moods = (t['moods'] as List?)?.map((e) => e.toString()) ?? const [];
      final moodScore = moods.contains(request.moodId) ? 1.0 : 0.0;

      final mealType = (t['mealType'] as String).toLowerCase();
      final mealScore =
          request.mealType.toLowerCase() == 'any' || mealType == request.mealType.toLowerCase()
              ? 1.0
              : 0.3;

      final totalTime = (t['prepTimeMinutes'] as int) + (t['cookTimeMinutes'] as int);
      final timeScore = totalTime <= request.maxCookingTimeMinutes
          ? 1.0
          : max(0.0, 1.0 - (totalTime - request.maxCookingTimeMinutes) / 30.0);

      final score = ingredientScore * 0.45 + moodScore * 0.2 + mealScore * 0.2 + timeScore * 0.15;
      return (template: t, score: score);
    }).toList()
      ..sort((a, b) => b.score.compareTo(a.score));

    final count = request.count.clamp(1, templates.length);
    return scored.take(count).map((entry) => AiRecipeSuggestion.fromJson(entry.template)).toList();
  }
}
