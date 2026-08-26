import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/recipe_image.dart';
import '../../../favorites/presentation/bloc/favorites_cubit.dart';
import '../../../favorites/presentation/bloc/favorites_state.dart';
import '../../../shopping_list/presentation/bloc/shopping_list_cubit.dart';
import '../../domain/entities/recipe.dart';
import '../bloc/recipe_cubit.dart';
import '../bloc/recipe_state.dart';

class RecipeDetailPage extends StatelessWidget {
  final String recipeId;
  final Recipe? initialRecipe;

  const RecipeDetailPage({
    super.key,
    required this.recipeId,
    this.initialRecipe,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<RecipeCubit, RecipeState>(
      builder: (context, state) {
        final recipe =
            initialRecipe ??
            state.selectedRecipe ??
            state.generatedRecipes.where((r) => r.id == recipeId).firstOrNull;

        if (recipe == null) {
          return Scaffold(
            backgroundColor: scheme.surface,
            appBar: AppBar(backgroundColor: scheme.surface),
            body: Center(
              child: Text(
                'Recipe not found',
                style: TextStyle(color: scheme.onSurface),
              ),
            ),
          );
        }

        final ratingScore = (4.0 + (recipe.matchPercentage / 100))
            .clamp(4.2, 5.0)
            .toStringAsFixed(2);
        final ratingCount = ((recipe.matchPercentage * 3) + 120);

        final cardBg = isDark ? const Color(0xFF222222) : Colors.white;
        final cardBorder = isDark
            ? null
            : Border.all(color: scheme.outlineVariant, width: 1.0);
        final cardShadow = isDark
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ];

        return Scaffold(
          backgroundColor: scheme.surface,
          appBar: AppBar(
            backgroundColor: scheme.surface,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.chevron_left_rounded,
                color: scheme.onSurface,
                size: 30,
              ),
              onPressed: () => context.pop(),
            ),
            title: Column(
              children: [
                Text(
                  recipe.title,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: scheme.onSurface,
                    fontSize: 16,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🔥', style: TextStyle(fontSize: 12)),
                    const SizedBox(width: 3),
                    Text(
                      '$ratingScore ($ratingCount)',
                      style: TextStyle(
                        color: isDark
                            ? AppColors.goldenFlame
                            : AppColors.primaryGold,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            centerTitle: true,
            actions: [
              BlocBuilder<FavoritesCubit, FavoritesState>(
                builder: (context, favState) {
                  final isFav = favState.favoriteIds.contains(recipe.id);
                  return IconButton(
                    icon: Icon(
                      isFav
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_border_rounded,
                      color: isFav
                          ? (isDark
                                ? AppColors.butterGold
                                : AppColors.primaryGold)
                          : scheme.onSurface,
                      size: 24,
                    ),
                    onPressed: () {
                      context.read<FavoritesCubit>().toggleFavorite(recipe);
                      AppSnackbar.show(
                        context,
                        message: isFav
                            ? 'Removed from saved'
                            : 'Saved to collection! ❤️',
                      );
                    },
                  );
                },
              ),
            ],
          ),
          body: Stack(
            children: [
              // Scrollable Content
              ListView(
                padding: const EdgeInsets.only(bottom: 110),
                children: [
                  // 1. Hero Circular Gourmet Food Plate
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.md,
                      ),
                      child: Container(
                        width: 240,
                        height: 240,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(
                                alpha: isDark ? 0.6 : 0.15,
                              ),
                              blurRadius: 28,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: RecipeImage(
                            seed: recipe.title,
                            imageUrl: recipe.imageUrl,
                            width: 240,
                            height: 240,
                            borderRadius: BorderRadius.zero,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // 2. Main Recipe Sheet Container
                  Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(28),
                      border: cardBorder,
                      boxShadow: cardShadow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Recipe Header + 45 MIN Butter Gold Pill
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Recipe',
                              style: textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: scheme.onSurface,
                                fontSize: 22,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.butterGold
                                    : scheme.primaryContainer,
                                borderRadius: BorderRadius.circular(
                                  AppSpacing.radiusPill,
                                ),
                              ),
                              child: Text(
                                '${recipe.totalTimeMinutes} MIN',
                                style: TextStyle(
                                  color: isDark
                                      ? const Color(0xFF141414)
                                      : AppColors.onAmberContainer,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 13,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        // Ingredients Section with Squircle Cards
                        Text(
                          'Ingredients',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: scheme.onSurface,
                            fontSize: 17,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),

                        SizedBox(
                          height: 105,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            clipBehavior: Clip.none,
                            itemCount: recipe.ingredients.length,
                            itemBuilder: (context, index) {
                              final ing = recipe.ingredients[index];
                              final isMissing = recipe.missingIngredients.any(
                                (m) =>
                                    ing.toLowerCase().contains(m.toLowerCase()),
                              );

                              return Container(
                                width: 88,
                                margin: const EdgeInsets.only(right: 10),
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF2C2C2C)
                                      : scheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(18),
                                  border: isMissing
                                      ? Border.all(
                                          color: AppColors.terracotta
                                              .withValues(alpha: 0.5),
                                          width: 1.2,
                                        )
                                      : (isDark
                                            ? null
                                            : Border.all(
                                                color: scheme.outlineVariant,
                                                width: 0.8,
                                              )),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      _ingredientEmoji(ing),
                                      style: const TextStyle(fontSize: 26),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      ing.split(' ').last,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: scheme.onSurface,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      isMissing ? 'Missing' : 'In stock',
                                      style: TextStyle(
                                        color: isMissing
                                            ? AppColors.terracotta
                                            : (isDark
                                                  ? AppColors.sageLight
                                                  : AppColors.sage),
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),

                        if (recipe.missingIngredients.isNotEmpty) ...[
                          OutlinedButton.icon(
                            icon: Icon(
                              Icons.add_shopping_cart_rounded,
                              size: 16,
                              color: isDark
                                  ? AppColors.butterGold
                                  : AppColors.primaryGold,
                            ),
                            label: Text(
                              'Add ${recipe.missingIngredients.length} Missing to Shopping List 🛒',
                              style: TextStyle(
                                color: isDark
                                    ? AppColors.butterGold
                                    : AppColors.primaryGold,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: isDark
                                    ? AppColors.butterGold
                                    : AppColors.primaryGold,
                                width: 1.2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: () {
                              context
                                  .read<ShoppingListCubit>()
                                  .addMissingIngredientsFromRecipe(
                                    missingIngredients:
                                        recipe.missingIngredients,
                                    recipeTitle: recipe.title,
                                  );
                              AppSnackbar.show(
                                context,
                                message:
                                    'Added missing ingredients to shopping list! 🛒',
                                variant: SnackbarVariant.success,
                              );
                            },
                          ),
                          const SizedBox(height: AppSpacing.lg),
                        ],

                        // Step by Step Instructions
                        Text(
                          'Instructions',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: scheme.onSurface,
                            fontSize: 17,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),

                        ...recipe.instructions.asMap().entries.map((entry) {
                          final stepNum = entry.key + 1;
                          final stepText = entry.value;

                          return Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.md,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  margin: const EdgeInsets.only(top: 2),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isDark
                                          ? AppColors.butterGold
                                          : AppColors.primaryGold,
                                      width: 2,
                                    ),
                                  ),
                                  child: Center(
                                    child: Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? AppColors.butterGold
                                            : AppColors.primaryGold,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Step $stepNum',
                                        style: TextStyle(
                                          color: scheme.onSurface,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        stepText,
                                        style: TextStyle(
                                          color: scheme.onSurfaceVariant,
                                          fontSize: 13.5,
                                          height: 1.4,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),

              // Sticky Floating "Start Cooking" Button
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.md,
                    AppSpacing.lg,
                    AppSpacing.lg,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        scheme.surface.withValues(alpha: 0.0),
                        scheme.surface.withValues(alpha: 0.95),
                        scheme.surface,
                      ],
                    ),
                  ),
                  child: AppButton(
                    label: 'Start Cooking 🍳',
                    backgroundColor: isDark
                        ? AppColors.butterGold
                        : AppColors.primaryGold,
                    foregroundColor: const Color(0xFF141414),
                    onPressed: () {
                      context.push(
                        AppRoutes.cookingModePath(recipe.id),
                        extra: recipe,
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _ingredientEmoji(String ing) {
    final s = ing.toLowerCase();
    if (s.contains('potato')) {
      return '🥔';
    }
    if (s.contains('bean')) {
      return '🫛';
    }
    if (s.contains('tomato')) {
      return '🍅';
    }
    if (s.contains('egg')) {
      return '🥚';
    }
    if (s.contains('meat') ||
        s.contains('beef') ||
        s.contains('chicken') ||
        s.contains('pork')) {
      return '🥩';
    }
    if (s.contains('bread') || s.contains('toast')) {
      return '🍞';
    }
    if (s.contains('cheese') || s.contains('dairy')) {
      return '🧀';
    }
    if (s.contains('rice')) {
      return '🍚';
    }
    if (s.contains('pasta')) {
      return '🍝';
    }
    if (s.contains('oil') || s.contains('olive')) {
      return '🫒';
    }
    if (s.contains('onion') || s.contains('garlic')) {
      return '🧅';
    }
    if (s.contains('pepper') || s.contains('chili')) {
      return '🌶️';
    }
    if (s.contains('spinach') || s.contains('herb') || s.contains('basil')) {
      return '🌿';
    }
    return '🥬';
  }
}
