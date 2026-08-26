import 'package:equatable/equatable.dart';

import '../../domain/entities/ingredient.dart';

enum IngredientStatus { initial, loading, loaded, error }

class IngredientState extends Equatable {
  final IngredientStatus status;
  final List<Ingredient> ingredients;
  final String searchQuery;
  final String? selectedCategory;
  final String? errorMessage;

  const IngredientState({
    this.status = IngredientStatus.initial,
    this.ingredients = const [],
    this.searchQuery = '',
    this.selectedCategory,
    this.errorMessage,
  });

  List<Ingredient> get filteredIngredients {
    return ingredients.where((item) {
      final matchesSearch = searchQuery.isEmpty ||
          item.name.toLowerCase().contains(searchQuery.toLowerCase());
      final matchesCategory = selectedCategory == null ||
          selectedCategory == 'All' ||
          item.category.toLowerCase() == selectedCategory!.toLowerCase();
      return matchesSearch && matchesCategory;
    }).toList();
  }

  List<Ingredient> get availableIngredients {
    return ingredients.where((item) => item.isAvailable).toList();
  }

  int get availableCount => availableIngredients.length;

  IngredientState copyWith({
    IngredientStatus? status,
    List<Ingredient>? ingredients,
    String? searchQuery,
    String? selectedCategory,
    bool clearCategory = false,
    String? errorMessage,
  }) {
    return IngredientState(
      status: status ?? this.status,
      ingredients: ingredients ?? this.ingredients,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: clearCategory ? null : (selectedCategory ?? this.selectedCategory),
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, ingredients, searchQuery, selectedCategory, errorMessage];
}
