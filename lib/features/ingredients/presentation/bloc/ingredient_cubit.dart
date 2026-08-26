import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/services/analytics_service.dart';
import '../../domain/entities/ingredient.dart';
import '../../domain/repositories/ingredient_repository.dart';
import 'ingredient_state.dart';

class IngredientCubit extends Cubit<IngredientState> {
  final IngredientRepository ingredientRepository;
  final AnalyticsService analytics;
  final Uuid _uuid = const Uuid();
  StreamSubscription? _subscription;

  IngredientCubit({
    required this.ingredientRepository,
    required this.analytics,
  }) : super(const IngredientState()) {
    _init();
  }

  void _init() {
    emit(state.copyWith(status: IngredientStatus.loading));
    _subscription = ingredientRepository.ingredientsStream.listen((list) {
      emit(state.copyWith(
        status: IngredientStatus.loaded,
        ingredients: list,
      ));
    });
    loadIngredients();
  }

  Future<void> loadIngredients() async {
    try {
      await ingredientRepository.seedInitialIngredients();
      final list = await ingredientRepository.getIngredients();
      emit(state.copyWith(status: IngredientStatus.loaded, ingredients: list));
    } catch (e) {
      emit(state.copyWith(
        status: IngredientStatus.error,
        errorMessage: 'Failed to load pantry ingredients',
      ));
    }
  }

  Future<void> addIngredient({
    required String name,
    required String category,
    String quantity = '1',
    String unit = 'pcs',
    DateTime? expiryDate,
  }) async {
    final item = Ingredient(
      id: _uuid.v4(),
      name: name.trim(),
      category: category,
      quantity: quantity.trim(),
      unit: unit.trim(),
      expiryDate: expiryDate,
      createdAt: DateTime.now(),
    );
    await ingredientRepository.addIngredient(item);
    await analytics.logIngredientAdded(item.name);
  }

  Future<void> updateIngredient(Ingredient ingredient) async {
    await ingredientRepository.updateIngredient(ingredient);
  }

  Future<void> deleteIngredient(String id) async {
    await ingredientRepository.deleteIngredient(id);
  }

  Future<void> toggleAvailability(String id) async {
    await ingredientRepository.toggleAvailability(id);
  }

  void setSearchQuery(String query) {
    emit(state.copyWith(searchQuery: query));
  }

  void selectCategory(String? category) {
    if (category == 'All' || category == state.selectedCategory) {
      emit(state.copyWith(clearCategory: true));
    } else {
      emit(state.copyWith(selectedCategory: category));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
