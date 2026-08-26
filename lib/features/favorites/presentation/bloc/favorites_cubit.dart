import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/analytics_service.dart';
import '../../../recipes/domain/entities/recipe.dart';
import '../../domain/repositories/favorites_repository.dart';
import 'favorites_state.dart';

class FavoritesCubit extends Cubit<FavoritesState> {
  final FavoritesRepository favoritesRepository;
  final AnalyticsService analytics;
  StreamSubscription? _subscription;

  FavoritesCubit({
    required this.favoritesRepository,
    required this.analytics,
  }) : super(const FavoritesState()) {
    _init();
  }

  void _init() {
    emit(state.copyWith(status: FavoritesStatus.loading));
    _subscription = favoritesRepository.favoritesStream.listen((list) {
      emit(state.copyWith(
        status: FavoritesStatus.loaded,
        favorites: list,
      ));
    });
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    try {
      final list = await favoritesRepository.getFavorites();
      emit(state.copyWith(status: FavoritesStatus.loaded, favorites: list));
    } catch (e) {
      emit(state.copyWith(
        status: FavoritesStatus.error,
        errorMessage: 'Failed to load favorite recipes',
      ));
    }
  }

  Future<void> toggleFavorite(Recipe recipe) async {
    await favoritesRepository.toggleFavorite(recipe);
    await analytics.logRecipeFavorited(recipe.id, recipe.title);
  }

  Future<void> removeFavorite(String recipeId) async {
    await favoritesRepository.removeFavorite(recipeId);
  }

  void setSearchQuery(String query) {
    emit(state.copyWith(searchQuery: query));
  }

  void selectMood(String? mood) {
    if (mood == 'All' || mood == state.selectedMood) {
      emit(state.copyWith(clearMood: true));
    } else {
      emit(state.copyWith(selectedMood: mood));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
