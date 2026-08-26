import '../../domain/entities/recipe.dart';

class RecipeModel extends Recipe {
  const RecipeModel({
    required super.id,
    required super.title,
    required super.description,
    required super.mood,
    required super.mealType,
    required super.prepTimeMinutes,
    required super.cookTimeMinutes,
    required super.difficulty,
    required super.matchPercentage,
    required super.ingredients,
    required super.missingIngredients,
    required super.instructions,
    super.tips,
    super.nutrition,
    super.imageUrl,
    super.cuisine,
    super.isFavorite,
    super.cookedAt,
  });

  factory RecipeModel.fromEntity(Recipe entity) {
    return RecipeModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      mood: entity.mood,
      mealType: entity.mealType,
      prepTimeMinutes: entity.prepTimeMinutes,
      cookTimeMinutes: entity.cookTimeMinutes,
      difficulty: entity.difficulty,
      matchPercentage: entity.matchPercentage,
      ingredients: entity.ingredients,
      missingIngredients: entity.missingIngredients,
      instructions: entity.instructions,
      tips: entity.tips,
      nutrition: entity.nutrition,
      imageUrl: entity.imageUrl,
      cuisine: entity.cuisine,
      isFavorite: entity.isFavorite,
      cookedAt: entity.cookedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'mood': mood,
      'mealType': mealType,
      'prepTimeMinutes': prepTimeMinutes,
      'cookTimeMinutes': cookTimeMinutes,
      'difficulty': difficulty,
      'matchPercentage': matchPercentage,
      'ingredients': ingredients,
      'missingIngredients': missingIngredients,
      'instructions': instructions,
      'tips': tips,
      'nutrition': nutrition,
      'imageUrl': imageUrl,
      'cuisine': cuisine,
      'isFavorite': isFavorite,
      'cookedAt': cookedAt?.toIso8601String(),
    };
  }

  factory RecipeModel.fromMap(Map<String, dynamic> map) {
    return RecipeModel(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String? ?? '',
      mood: map['mood'] as String? ?? 'happy',
      mealType: map['mealType'] as String? ?? 'any',
      prepTimeMinutes: (map['prepTimeMinutes'] as num?)?.toInt() ?? 10,
      cookTimeMinutes: (map['cookTimeMinutes'] as num?)?.toInt() ?? 15,
      difficulty: map['difficulty'] as String? ?? 'easy',
      matchPercentage: (map['matchPercentage'] as num?)?.toInt() ?? 80,
      ingredients: List<String>.from(map['ingredients'] as List? ?? []),
      missingIngredients: List<String>.from(map['missingIngredients'] as List? ?? []),
      instructions: List<String>.from(map['instructions'] as List? ?? []),
      tips: List<String>.from(map['tips'] as List? ?? []),
      nutrition: Map<String, dynamic>.from(map['nutrition'] as Map? ?? {}),
      imageUrl: map['imageUrl'] as String?,
      cuisine: map['cuisine'] as String? ?? '',
      isFavorite: map['isFavorite'] as bool? ?? false,
      cookedAt: map['cookedAt'] != null ? DateTime.tryParse(map['cookedAt'] as String) : null,
    );
  }
}
