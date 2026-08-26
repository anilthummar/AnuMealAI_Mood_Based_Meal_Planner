import 'package:hive_flutter/hive_flutter.dart';

import '../models/recipe_model.dart';

class RecipeLocalDataSource {
  final Box<Map> cacheBox;
  final Box<Map> feedbackBox;

  RecipeLocalDataSource({
    required this.cacheBox,
    required this.feedbackBox,
  });

  List<RecipeModel> getAllCached() {
    final list = <RecipeModel>[];
    for (final key in cacheBox.keys) {
      final val = cacheBox.get(key);
      if (val != null) {
        try {
          final map = Map<String, dynamic>.from(val);
          list.add(RecipeModel.fromMap(map));
        } catch (_) {}
      }
    }
    return list;
  }

  RecipeModel? getById(String id) {
    final val = cacheBox.get(id);
    if (val == null) return null;
    try {
      final map = Map<String, dynamic>.from(val);
      return RecipeModel.fromMap(map);
    } catch (_) {
      return null;
    }
  }

  Future<void> save(RecipeModel recipe) async {
    await cacheBox.put(recipe.id, recipe.toMap());
  }

  Future<void> saveAll(List<RecipeModel> recipes) async {
    final map = {for (final r in recipes) r.id: r.toMap()};
    await cacheBox.putAll(map);
  }

  Future<void> markCooked(String id) async {
    final recipe = getById(id);
    if (recipe != null) {
      final updated = recipe.copyWith(cookedAt: DateTime.now());
      await save(RecipeModel.fromEntity(updated));
    }
  }

  Future<void> saveFeedback(String recipeId, String rating) async {
    await feedbackBox.put(recipeId, {
      'recipeId': recipeId,
      'rating': rating,
      'ratedAt': DateTime.now().toIso8601String(),
    });
  }

  Map<String, String> getAllFeedback() {
    final map = <String, String>{};
    for (final key in feedbackBox.keys) {
      final val = feedbackBox.get(key);
      if (val != null) {
        try {
          final entry = Map<String, dynamic>.from(val);
          final id = entry['recipeId'] as String;
          final rating = entry['rating'] as String;
          map[id] = rating;
        } catch (_) {}
      }
    }
    return map;
  }
}
