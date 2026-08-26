import '../entities/ingredient.dart';

abstract class IngredientRepository {
  Future<List<Ingredient>> getIngredients();
  Stream<List<Ingredient>> get ingredientsStream;
  Future<void> addIngredient(Ingredient ingredient);
  Future<void> updateIngredient(Ingredient ingredient);
  Future<void> deleteIngredient(String id);
  Future<void> toggleAvailability(String id);
  Future<List<String>> getRecentlyUsedNames();
  Future<void> seedInitialIngredients();
}
