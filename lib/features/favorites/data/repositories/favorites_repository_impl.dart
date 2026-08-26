import '../../../recipes/data/models/recipe_model.dart';
import '../../../recipes/domain/entities/recipe.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../datasources/favorites_local_data_source.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  final FavoritesLocalDataSource localDataSource;

  FavoritesRepositoryImpl({required this.localDataSource});

  @override
  Future<List<Recipe>> getFavorites() async {
    return localDataSource.getAll();
  }

  @override
  Stream<List<Recipe>> get favoritesStream => localDataSource.stream;

  @override
  Future<bool> isFavorite(String recipeId) async {
    return localDataSource.contains(recipeId);
  }

  @override
  Future<void> toggleFavorite(Recipe recipe) async {
    final exists = localDataSource.contains(recipe.id);
    if (exists) {
      await localDataSource.delete(recipe.id);
    } else {
      final fav = recipe.copyWith(isFavorite: true);
      await localDataSource.put(RecipeModel.fromEntity(fav));
    }
  }

  @override
  Future<void> removeFavorite(String recipeId) async {
    await localDataSource.delete(recipeId);
  }
}
