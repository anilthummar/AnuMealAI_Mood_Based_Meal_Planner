import '../../../recipes/domain/entities/recipe.dart';

abstract class FavoritesRepository {
  Future<List<Recipe>> getFavorites();
  Stream<List<Recipe>> get favoritesStream;
  Future<bool> isFavorite(String recipeId);
  Future<void> toggleFavorite(Recipe recipe);
  Future<void> removeFavorite(String recipeId);
}
