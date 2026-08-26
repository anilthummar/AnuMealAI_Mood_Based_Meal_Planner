import 'package:uuid/uuid.dart';

import '../../domain/entities/ingredient.dart';
import '../../domain/repositories/ingredient_repository.dart';
import '../datasources/ingredient_local_data_source.dart';
import '../models/ingredient_model.dart';

class IngredientRepositoryImpl implements IngredientRepository {
  final IngredientLocalDataSource localDataSource;
  final Uuid _uuid = const Uuid();

  IngredientRepositoryImpl({required this.localDataSource});

  @override
  Future<List<Ingredient>> getIngredients() async {
    return localDataSource.getAll();
  }

  @override
  Stream<List<Ingredient>> get ingredientsStream => localDataSource.stream;

  @override
  Future<void> addIngredient(Ingredient ingredient) async {
    final model = IngredientModel.fromEntity(ingredient);
    await localDataSource.put(model);
  }

  @override
  Future<void> updateIngredient(Ingredient ingredient) async {
    final model = IngredientModel.fromEntity(ingredient);
    await localDataSource.put(model);
  }

  @override
  Future<void> deleteIngredient(String id) async {
    await localDataSource.delete(id);
  }

  @override
  Future<void> toggleAvailability(String id) async {
    await localDataSource.toggleAvailability(id);
  }

  @override
  Future<List<String>> getRecentlyUsedNames() async {
    final list = localDataSource.getAll();
    return list.map((i) => i.name).take(10).toList();
  }

  @override
  Future<void> seedInitialIngredients() async {
    final current = localDataSource.getAll();
    if (current.isNotEmpty) return;

    final now = DateTime.now();
    final seeds = [
      IngredientModel(
        id: _uuid.v4(),
        name: 'Eggs',
        category: 'Eggs',
        quantity: '6',
        unit: 'pcs',
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      IngredientModel(
        id: _uuid.v4(),
        name: 'Tomato',
        category: 'Vegetables',
        quantity: '3',
        unit: 'pcs',
        createdAt: now.subtract(const Duration(hours: 3)),
      ),
      IngredientModel(
        id: _uuid.v4(),
        name: 'Onion',
        category: 'Vegetables',
        quantity: '2',
        unit: 'pcs',
        createdAt: now.subtract(const Duration(hours: 4)),
      ),
      IngredientModel(
        id: _uuid.v4(),
        name: 'Pasta',
        category: 'Grains',
        quantity: '500',
        unit: 'g',
        createdAt: now.subtract(const Duration(hours: 5)),
      ),
      IngredientModel(
        id: _uuid.v4(),
        name: 'Garlic',
        category: 'Spices',
        quantity: '1',
        unit: 'bulb',
        createdAt: now.subtract(const Duration(hours: 6)),
      ),
      IngredientModel(
        id: _uuid.v4(),
        name: 'Olive Oil',
        category: 'Pantry',
        quantity: '1',
        unit: 'bottle',
        createdAt: now.subtract(const Duration(hours: 7)),
      ),
      IngredientModel(
        id: _uuid.v4(),
        name: 'Milk',
        category: 'Dairy',
        quantity: '1',
        unit: 'L',
        createdAt: now.subtract(const Duration(hours: 8)),
      ),
    ];

    await localDataSource.putAll(seeds);
  }
}
