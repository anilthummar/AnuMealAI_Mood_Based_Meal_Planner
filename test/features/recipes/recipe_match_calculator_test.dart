import 'package:flutter_test/flutter_test.dart';
import 'package:anu_meal_ai/features/recipes/domain/services/recipe_match_calculator.dart';

void main() {
  group('RecipeMatchCalculator', () {
    test('calculates 100% when all ingredients match, mood matches, and time fits', () {
      final result = RecipeMatchCalculator.calculate(
        recipeIngredients: ['Eggs', 'Tomato', 'Onion'],
        availableIngredients: ['Eggs', 'Tomato', 'Onion', 'Milk'],
        recipeMood: 'happy',
        selectedMood: 'happy',
        recipeMealType: 'breakfast',
        selectedMealType: 'breakfast',
        recipeTotalMinutes: 15,
        maxCookingMinutes: 20,
      );

      expect(result.matchPercentage, greaterThanOrEqualTo(90));
      expect(result.missingIngredients, isEmpty);
      expect(result.availableIngredientsUsed.length, equals(3));
      expect(result.matchReason, contains('uses everything'));
    });

    test('correctly identifies missing ingredients and reduces score proportionally', () {
      final result = RecipeMatchCalculator.calculate(
        recipeIngredients: ['Chicken Breast', 'Parmesan', 'Pasta', 'Heavy Cream'],
        availableIngredients: ['Pasta'],
        recipeMood: 'comfort',
        selectedMood: 'relaxed',
        recipeMealType: 'dinner',
        selectedMealType: 'dinner',
        recipeTotalMinutes: 30,
        maxCookingMinutes: 30,
      );

      expect(result.missingIngredients, contains('Chicken Breast'));
      expect(result.missingIngredients, contains('Parmesan'));
      expect(result.missingIngredients, contains('Heavy Cream'));
      expect(result.availableIngredientsUsed, contains('Pasta'));
      expect(result.matchPercentage, lessThan(70));
    });

    test('penalizes recipe exceeding max cooking time', () {
      final resultUnder = RecipeMatchCalculator.calculate(
        recipeIngredients: ['Rice'],
        availableIngredients: ['Rice'],
        recipeMood: 'happy',
        selectedMood: 'happy',
        recipeMealType: 'lunch',
        selectedMealType: 'lunch',
        recipeTotalMinutes: 20,
        maxCookingMinutes: 30,
      );

      final resultOver = RecipeMatchCalculator.calculate(
        recipeIngredients: ['Rice'],
        availableIngredients: ['Rice'],
        recipeMood: 'happy',
        selectedMood: 'happy',
        recipeMealType: 'lunch',
        selectedMealType: 'lunch',
        recipeTotalMinutes: 60,
        maxCookingMinutes: 15,
      );

      expect(resultUnder.matchPercentage, greaterThan(resultOver.matchPercentage));
    });
  });
}
