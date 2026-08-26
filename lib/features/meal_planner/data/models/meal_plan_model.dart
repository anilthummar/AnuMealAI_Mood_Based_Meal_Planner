import '../../../recipes/data/models/recipe_model.dart';
import '../../domain/entities/meal_plan_entry.dart';
import '../../domain/entities/weekly_meal_plan.dart';

class MealPlanEntryModel extends MealPlanEntry {
  const MealPlanEntryModel({
    required super.id,
    required super.dayOfWeek,
    required super.mealSlot,
    required super.recipe,
    super.isCooked,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'dayOfWeek': dayOfWeek,
      'mealSlot': mealSlot,
      'recipe': RecipeModel.fromEntity(recipe).toMap(),
      'isCooked': isCooked,
    };
  }

  factory MealPlanEntryModel.fromMap(Map<String, dynamic> map) {
    return MealPlanEntryModel(
      id: map['id'] as String,
      dayOfWeek: map['dayOfWeek'] as String,
      mealSlot: map['mealSlot'] as String,
      recipe: RecipeModel.fromMap(Map<String, dynamic>.from(map['recipe'] as Map)),
      isCooked: map['isCooked'] as bool? ?? false,
    );
  }
}

class WeeklyMealPlanModel extends WeeklyMealPlan {
  const WeeklyMealPlanModel({
    required super.id,
    required super.weekStartDate,
    required super.entries,
    required super.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'weekStartDate': weekStartDate.toIso8601String(),
      'entries': entries.map((e) => MealPlanEntryModel(
            id: e.id,
            dayOfWeek: e.dayOfWeek,
            mealSlot: e.mealSlot,
            recipe: e.recipe,
            isCooked: e.isCooked,
          ).toMap()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory WeeklyMealPlanModel.fromMap(Map<String, dynamic> map) {
    final entriesRaw = (map['entries'] as List? ?? []);
    final parsedEntries = entriesRaw
        .map((e) => MealPlanEntryModel.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();

    return WeeklyMealPlanModel(
      id: map['id'] as String,
      weekStartDate: DateTime.parse(map['weekStartDate'] as String),
      entries: parsedEntries,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}
