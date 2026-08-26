import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/services/analytics_service.dart';
import '../../domain/entities/shopping_item.dart';
import '../../domain/repositories/shopping_list_repository.dart';
import 'shopping_list_state.dart';

class ShoppingListCubit extends Cubit<ShoppingListState> {
  final ShoppingListRepository shoppingListRepository;
  final AnalyticsService analytics;
  final Uuid _uuid = const Uuid();
  StreamSubscription? _subscription;

  ShoppingListCubit({
    required this.shoppingListRepository,
    required this.analytics,
  }) : super(const ShoppingListState()) {
    _init();
  }

  void _init() {
    emit(state.copyWith(status: ShoppingListStatus.loading));
    _subscription = shoppingListRepository.itemsStream.listen((list) {
      emit(state.copyWith(
        status: ShoppingListStatus.loaded,
        items: list,
      ));
    });
    loadItems();
  }

  Future<void> loadItems() async {
    try {
      final list = await shoppingListRepository.getItems();
      emit(state.copyWith(status: ShoppingListStatus.loaded, items: list));
    } catch (e) {
      emit(state.copyWith(
        status: ShoppingListStatus.error,
        errorMessage: 'Failed to load shopping list',
      ));
    }
  }

  Future<void> addItem({
    required String name,
    required String category,
    String quantity = '1',
    String unit = 'pcs',
  }) async {
    final item = ShoppingItem(
      id: _uuid.v4(),
      name: name.trim(),
      category: category,
      quantity: quantity.trim(),
      unit: unit.trim(),
      createdAt: DateTime.now(),
    );
    await shoppingListRepository.addItem(item);
    await analytics.logShoppingItemAdded(item.name);
  }

  Future<void> addMissingIngredientsFromRecipe({
    required List<String> missingIngredients,
    required String recipeTitle,
  }) async {
    await shoppingListRepository.addMissingIngredients(
      missingIngredients: missingIngredients,
      recipeTitle: recipeTitle,
    );
  }

  Future<void> toggleCheck(String id) async {
    await shoppingListRepository.toggleCheck(id);
  }

  Future<void> deleteItem(String id) async {
    await shoppingListRepository.deleteItem(id);
  }

  Future<void> clearCompleted() async {
    await shoppingListRepository.clearCompleted();
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
