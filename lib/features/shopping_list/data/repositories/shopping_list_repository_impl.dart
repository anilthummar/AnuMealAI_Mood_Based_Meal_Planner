import 'package:uuid/uuid.dart';

import '../../domain/entities/shopping_item.dart';
import '../../domain/repositories/shopping_list_repository.dart';
import '../datasources/shopping_list_local_data_source.dart';
import '../models/shopping_item_model.dart';

class ShoppingListRepositoryImpl implements ShoppingListRepository {
  final ShoppingListLocalDataSource localDataSource;
  final Uuid _uuid = const Uuid();

  ShoppingListRepositoryImpl({required this.localDataSource});

  @override
  Future<List<ShoppingItem>> getItems() async {
    return localDataSource.getAll();
  }

  @override
  Stream<List<ShoppingItem>> get itemsStream => localDataSource.stream;

  @override
  Future<void> addItem(ShoppingItem item) async {
    await localDataSource.put(ShoppingItemModel.fromEntity(item));
  }

  @override
  Future<void> addMissingIngredients({
    required List<String> missingIngredients,
    String? recipeTitle,
  }) async {
    final now = DateTime.now();
    final items = missingIngredients.map((name) {
      final category = _guessCategory(name);
      return ShoppingItemModel(
        id: _uuid.v4(),
        name: name,
        category: category,
        quantity: '1',
        unit: 'item',
        isChecked: false,
        sourceRecipeTitle: recipeTitle,
        createdAt: now,
      );
    }).toList();

    await localDataSource.putAll(items);
  }

  @override
  Future<void> toggleCheck(String id) async {
    await localDataSource.toggleCheck(id);
  }

  @override
  Future<void> deleteItem(String id) async {
    await localDataSource.delete(id);
  }

  @override
  Future<void> clearCompleted() async {
    await localDataSource.clearCompleted();
  }

  String _guessCategory(String name) {
    final n = name.toLowerCase();
    if (n.contains('tomato') ||
        n.contains('onion') ||
        n.contains('garlic') ||
        n.contains('lettuce') ||
        n.contains('spinach') ||
        n.contains('pepper') ||
        n.contains('herb') ||
        n.contains('lemon') ||
        n.contains('apple')) {
      return 'Produce';
    }
    if (n.contains('milk') ||
        n.contains('cheese') ||
        n.contains('butter') ||
        n.contains('cream') ||
        n.contains('yogurt') ||
        n.contains('egg')) {
      return 'Dairy';
    }
    if (n.contains('chicken') ||
        n.contains('beef') ||
        n.contains('pork') ||
        n.contains('salmon') ||
        n.contains('fish') ||
        n.contains('shrimp')) {
      return 'Meat & Seafood';
    }
    return 'Pantry';
  }
}
