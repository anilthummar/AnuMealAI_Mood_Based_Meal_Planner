import 'package:equatable/equatable.dart';

import '../../../recipes/domain/entities/recipe.dart';

enum FavoritesStatus { initial, loading, loaded, error }

class FavoritesState extends Equatable {
  final FavoritesStatus status;
  final List<Recipe> favorites;
  final String searchQuery;
  final String? selectedMood;
  final String? errorMessage;

  const FavoritesState({
    this.status = FavoritesStatus.initial,
    this.favorites = const [],
    this.searchQuery = '',
    this.selectedMood,
    this.errorMessage,
  });

  List<Recipe> get filteredFavorites {
    return favorites.where((r) {
      final matchesSearch = searchQuery.isEmpty ||
          r.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
          r.description.toLowerCase().contains(searchQuery.toLowerCase());
      final matchesMood = selectedMood == null ||
          selectedMood == 'All' ||
          r.mood.toLowerCase() == selectedMood!.toLowerCase();
      return matchesSearch && matchesMood;
    }).toList();
  }

  Set<String> get favoriteIds => favorites.map((r) => r.id).toSet();

  FavoritesState copyWith({
    FavoritesStatus? status,
    List<Recipe>? favorites,
    String? searchQuery,
    String? selectedMood,
    bool clearMood = false,
    String? errorMessage,
  }) {
    return FavoritesState(
      status: status ?? this.status,
      favorites: favorites ?? this.favorites,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedMood: clearMood ? null : (selectedMood ?? this.selectedMood),
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, favorites, searchQuery, selectedMood, errorMessage];
}
