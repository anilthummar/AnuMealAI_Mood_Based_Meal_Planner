import 'dart:async';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../recipes/data/models/recipe_model.dart';

class FavoritesLocalDataSource {
  final Box<Map> box;
  final _controller = StreamController<List<RecipeModel>>.broadcast();

  FavoritesLocalDataSource({required this.box}) {
    _emit();
  }

  Stream<List<RecipeModel>> get stream => _controller.stream;

  void _emit() {
    if (!_controller.isClosed) {
      _controller.add(getAll());
    }
  }

  List<RecipeModel> getAll() {
    final list = <RecipeModel>[];
    for (final key in box.keys) {
      final val = box.get(key);
      if (val != null) {
        try {
          final map = Map<String, dynamic>.from(val);
          list.add(RecipeModel.fromMap(map));
        } catch (_) {}
      }
    }
    return list;
  }

  bool contains(String recipeId) => box.containsKey(recipeId);

  Future<void> put(RecipeModel recipe) async {
    await box.put(recipe.id, recipe.toMap());
    _emit();
  }

  Future<void> delete(String recipeId) async {
    await box.delete(recipeId);
    _emit();
  }
}
