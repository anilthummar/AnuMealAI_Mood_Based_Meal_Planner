import '../entities/shopping_item.dart';

abstract class ShoppingListRepository {
  Future<List<ShoppingItem>> getItems();
  Stream<List<ShoppingItem>> get itemsStream;
  Future<void> addItem(ShoppingItem item);
  Future<void> addMissingIngredients({
    required List<String> missingIngredients,
    String? recipeTitle,
  });
  Future<void> toggleCheck(String id);
  Future<void> deleteItem(String id);
  Future<void> clearCompleted();
}
