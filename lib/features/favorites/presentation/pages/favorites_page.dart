import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_chip.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_shimmer.dart';
import '../../../../core/widgets/recipe_card.dart';
import '../../../mood/data/datasources/mood_catalog.dart';
import '../bloc/favorites_cubit.dart';
import '../bloc/favorites_state.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Recipes'),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: BlocBuilder<FavoritesCubit, FavoritesState>(
        builder: (context, state) {
          if (state.status == FavoritesStatus.loading && state.favorites.isEmpty) {
            return const RecipeGridSkeleton(count: 4);
          }

          if (state.favorites.isEmpty) {
            return EmptyState(
              emoji: '❤️',
              title: 'Your future favorites live here',
              message: 'Save recipes you love or want to try again. Tap the heart on any recipe.',
              actionLabel: 'Explore Meals',
              actionIcon: Icons.restaurant_menu_rounded,
              onAction: () => context.go(AppRoutes.recipes),
            );
          }

          final cubit = context.read<FavoritesCubit>();
          final filtered = state.filteredFavorites;

          return Column(
            children: [
              // Search & Mood filters
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0),
                child: AppTextField(
                  label: 'Search saved recipes...',
                  prefixIcon: Icons.search_rounded,
                  onChanged: (val) => cubit.setSearchQuery(val),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              // Mood horizontal bar
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: AppChip(
                        label: 'All (${state.favorites.length})',
                        isSelected: state.selectedMood == null || state.selectedMood == 'All',
                        onTap: () => cubit.selectMood('All'),
                      ),
                    ),
                    ...MoodCatalog.all.map((mood) {
                      final isSelected = state.selectedMood == mood.name;
                      final count = state.favorites.where((r) => r.mood.toLowerCase() == mood.name.toLowerCase()).length;
                      if (count == 0) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: AppChip(
                          label: '${mood.emoji} ${mood.name} ($count)',
                          isSelected: isSelected,
                          onTap: () => cubit.selectMood(mood.name),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              // Grid
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Text(
                          'No saved recipes match your filter.',
                          style: textTheme.bodyMedium,
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final recipe = filtered[index];
                          return RecipeCard(
                            id: recipe.id,
                            title: recipe.title,
                            imageUrl: recipe.imageUrl,
                            matchPercentage: recipe.matchPercentage,
                            totalTimeMinutes: recipe.totalTimeMinutes,
                            difficulty: recipe.difficulty,
                            isHorizontal: true,
                            isFavorite: true,
                            onTap: () => context.push(AppRoutes.recipeDetailPath(recipe.id), extra: recipe),
                            onFavoriteToggle: () => cubit.toggleFavorite(recipe),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
