import 'package:equatable/equatable.dart';

import '../../../recipes/domain/entities/recipe.dart';

class MealPlanEntry extends Equatable {
  final String id;
  final String dayOfWeek; // 'Monday', 'Tuesday', ...
  final String mealSlot; // 'Breakfast', 'Lunch', 'Dinner', 'Snack'
  final Recipe recipe;
  final bool isCooked;

  const MealPlanEntry({
    required this.id,
    required this.dayOfWeek,
    required this.mealSlot,
    required this.recipe,
    this.isCooked = false,
  });

  MealPlanEntry copyWith({
    String? id,
    String? dayOfWeek,
    String? mealSlot,
    Recipe? recipe,
    bool? isCooked,
  }) {
    return MealPlanEntry(
      id: id ?? this.id,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      mealSlot: mealSlot ?? this.mealSlot,
      recipe: recipe ?? this.recipe,
      isCooked: isCooked ?? this.isCooked,
    );
  }

  @override
  List<Object?> get props => [id, dayOfWeek, mealSlot, recipe, isCooked];
}
