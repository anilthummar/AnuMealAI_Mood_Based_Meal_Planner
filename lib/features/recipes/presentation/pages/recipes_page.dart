import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/dependency_injection/di.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/services/feature_access_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_chip.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/loading_shimmer.dart';
import '../../../../core/widgets/recipe_card.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../favorites/presentation/bloc/favorites_cubit.dart';
import '../../../ingredients/presentation/bloc/ingredient_cubit.dart';
import '../../../mood/presentation/bloc/mood_cubit.dart';
import '../../../profile/presentation/bloc/profile_cubit.dart';
import '../../../subscription/presentation/bloc/subscription_cubit.dart';
import '../bloc/recipe_cubit.dart';
import '../bloc/recipe_state.dart';

class RecipesPage extends StatefulWidget {
  const RecipesPage({super.key});

  @override
  State<RecipesPage> createState() => _RecipesPageState();
}

class _RecipesPageState extends State<RecipesPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _triggerSearch();
    });
  }

  void _triggerSearch() {
    final moodState = context.read<MoodCubit>().state;
    final ingState = context.read<IngredientCubit>().state;
    final profileState = context.read<ProfileCubit>().state;

    final availableNames = ingState.availableIngredients
        .map((i) => i.name)
        .toList();

    context.read<RecipeCubit>().generateRecipes(
      moodId: moodState.selectedMood.id,
      moodTraits: moodState.selectedMood.traits,
      availableIngredients: availableNames,
      dietaryPreferences: profileState.preferences.dietaryRestrictions,
      cuisinePreferences: profileState.preferences.favoriteCuisines,
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final featureAccess = sl<FeatureAccessService>();
    final subState = context.watch<SubscriptionCubit>().state;
    final isPremium = subState.isPremium;
    final remainingGenerations = isPremium
        ? -1
        : featureAccess.remainingRecipeGenerationsToday();

    return BlocConsumer<RecipeCubit, RecipeState>(
      listener: (context, state) {
        if (state.errorMessage == 'DAILY_LIMIT_REACHED' && isPremium) {
          context.read<RecipeCubit>().clearError();
        }
      },
      builder: (context, state) {
        final moodState = context.watch<MoodCubit>().state;
        final ingState = context.watch<IngredientCubit>().state;
        final favState = context.watch<FavoritesCubit>().state;
        final cubit = context.read<RecipeCubit>();

        return Scaffold(
          appBar: AppBar(
            title: const Text('What Can I Cook?'),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh_rounded),
                tooltip: 'Refresh recommendations',
                onPressed: state.status == RecipeStatus.loading
                    ? null
                    : () => _triggerSearch(),
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async => _triggerSearch(),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.xs,
                AppSpacing.md,
                AppSpacing.xxl,
              ),
              children: [
                // Filter Panel Card
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Active Context Indicators + Quota Info
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.golden.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusPill,
                              ),
                              border: Border.all(
                                color: AppColors.golden.withValues(alpha: 0.35),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  moodState.selectedMood.emoji,
                                  style: const TextStyle(fontSize: 14),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${moodState.selectedMood.name} Mood',
                                  style: textTheme.labelSmall?.copyWith(
                                    color: isDark
                                        ? AppColors.butterGold
                                        : AppColors.primaryGoldDark,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.sage.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusPill,
                              ),
                              border: Border.all(
                                color: AppColors.sage.withValues(alpha: 0.35),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  '🥬',
                                  style: TextStyle(fontSize: 14),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${ingState.availableIngredients.length} pantry items',
                                  style: textTheme.labelSmall?.copyWith(
                                    color: isDark
                                        ? const Color(0xFFA3D9A5)
                                        : AppColors.sage,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isPremium
                                  ? (isDark
                                        ? const Color(0xFF2C2614)
                                        : const Color(0xFFFEF3C7))
                                  : (isDark
                                        ? const Color(0xFF282828)
                                        : const Color(0xFFF3F4F6)),
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusPill,
                              ),
                              border: Border.all(
                                color: isPremium
                                    ? AppColors.primaryGold.withValues(
                                        alpha: 0.5,
                                      )
                                    : (isDark
                                          ? const Color(0xFF383838)
                                          : const Color(0xFFE5E7EB)),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  isPremium ? '👑' : '⚡',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  isPremium
                                      ? 'Unlimited AI'
                                      : '$remainingGenerations of 3 free left',
                                  style: textTheme.labelSmall?.copyWith(
                                    color: isPremium
                                        ? (isDark
                                              ? AppColors.butterGold
                                              : AppColors.primaryGoldDark)
                                        : scheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Meal Type Filter Chips
                      Text(
                        'Meal Type',
                        style: textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children:
                            [
                              {'label': 'Any Meal', 'icon': '✨'},
                              {'label': 'Breakfast', 'icon': '🍳'},
                              {'label': 'Lunch', 'icon': '🥗'},
                              {'label': 'Dinner', 'icon': '🍝'},
                              {'label': 'Snack', 'icon': '🥨'},
                            ].map((item) {
                              final type = item['label']!;
                              final icon = item['icon']!;
                              final selected =
                                  state.selectedMealType.toLowerCase() ==
                                  type.toLowerCase();
                              return AppChip(
                                label: '$icon $type',
                                isSelected: selected,
                                onTap: () {
                                  cubit.setMealType(type);
                                  _triggerSearch();
                                },
                              );
                            }).toList(),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Max Cooking Time Filter Chips
                      Text(
                        'Max Cooking Time',
                        style: textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        children:
                            [
                              {'mins': 15, 'label': '⚡ 15m'},
                              {'mins': 30, 'label': '⏱️ 30m'},
                              {'mins': 45, 'label': '🍲 45m'},
                              {'mins': 60, 'label': '⏳ 60m'},
                            ].map((entry) {
                              final mins = entry['mins'] as int;
                              final label = entry['label'] as String;
                              final selected =
                                  state.maxCookingTimeMinutes == mins;
                              return Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 3,
                                  ),
                                  child: InkWell(
                                    onTap: () {
                                      cubit.setMaxCookingTime(mins);
                                      _triggerSearch();
                                    },
                                    borderRadius: BorderRadius.circular(
                                      AppSpacing.radiusPill,
                                    ),
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 180,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: selected
                                            ? (isDark
                                                  ? AppColors.butterGold
                                                  : AppColors.primaryGold)
                                            : (isDark
                                                  ? const Color(0xFF282828)
                                                  : scheme
                                                        .surfaceContainerHighest),
                                        borderRadius: BorderRadius.circular(
                                          AppSpacing.radiusPill,
                                        ),
                                        boxShadow: selected
                                            ? [
                                                BoxShadow(
                                                  color:
                                                      (isDark
                                                              ? AppColors
                                                                    .butterGold
                                                              : AppColors
                                                                    .primaryGold)
                                                          .withValues(
                                                            alpha: 0.3,
                                                          ),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ]
                                            : null,
                                      ),
                                      child: Center(
                                        child: Text(
                                          label,
                                          style: TextStyle(
                                            color: selected
                                                ? const Color(0xFF141414)
                                                : scheme.onSurface,
                                            fontWeight: selected
                                                ? FontWeight.w900
                                                : FontWeight.w700,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // Primary Generate Button
                      AppButton(
                        label: 'Generate Recipes ✨',
                        icon: Icons.auto_awesome_rounded,
                        backgroundColor: isDark
                            ? AppColors.butterGold
                            : AppColors.primaryGold,
                        foregroundColor: const Color(0xFF141414),
                        isLoading: state.status == RecipeStatus.loading,
                        onPressed: state.status == RecipeStatus.loading
                            ? null
                            : () => _triggerSearch(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Results Section Header
                SectionHeader(
                  title: 'Recommended For You',
                  subtitle:
                      'Ranked by pantry overlap & ${moodState.selectedMood.name.toLowerCase()} mood',
                ),
                const SizedBox(height: AppSpacing.xs),

                // Content / States
                if (state.status == RecipeStatus.loading) ...[
                  const RecipeGridSkeleton(count: 4),
                ] else if (state.status == RecipeStatus.error) ...[
                  if (state.errorMessage == 'DAILY_LIMIT_REACHED' &&
                      !isPremium &&
                      !featureAccess.canGenerateRecipe())
                    _buildDailyLimitCard(context, isDark, textTheme, scheme)
                  else if (state.errorMessage == 'DAILY_LIMIT_REACHED')
                    EmptyState(
                      emoji: '🍳',
                      title: 'Ready to Cook!',
                      message:
                          'Tap "Generate Recipes ✨" above to discover dishes customized to your pantry and ${moodState.selectedMood.name.toLowerCase()} mood.',
                      actionLabel: 'Generate Recipes ✨',
                      onAction: () => _triggerSearch(),
                    )
                  else
                    ErrorState(
                      title: 'Could Not Generate Recipes',
                      message:
                          state.errorMessage ??
                          'Unable to connect to the recipe service right now. Please check your connection and try again.',
                      onRetry: () => _triggerSearch(),
                    ),
                ] else if (state.generatedRecipes.isEmpty) ...[
                  EmptyState(
                    emoji: '🍳',
                    title: 'No Matching Recipes Found',
                    message:
                        'No dishes matched your ${moodState.selectedMood.name.toLowerCase()} mood in under ${state.maxCookingTimeMinutes}m. Try increasing cooking time or adding more pantry items!',
                    actionLabel: 'Add Pantry Ingredients',
                    onAction: () => context.push(AppRoutes.ingredients),
                  ),
                ] else ...[
                  ...state.generatedRecipes.map((recipe) {
                    final isFav = favState.favoriteIds.contains(recipe.id);

                    return RecipeCard(
                      id: recipe.id,
                      title: recipe.title,
                      imageUrl: recipe.imageUrl,
                      matchPercentage: recipe.matchPercentage,
                      totalTimeMinutes: recipe.totalTimeMinutes,
                      difficulty: recipe.difficulty,
                      calories: recipe.calories,
                      isHorizontal: true,
                      isFavorite: isFav,
                      onTap: () {
                        cubit.setSelectedRecipe(recipe);
                        context.push(
                          AppRoutes.recipeDetailPath(recipe.id),
                          extra: recipe,
                        );
                      },
                      onFavoriteToggle: () =>
                          context.read<FavoritesCubit>().toggleFavorite(recipe),
                    );
                  }),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDailyLimitCard(
    BuildContext context,
    bool isDark,
    TextTheme textTheme,
    ColorScheme scheme,
  ) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF242018) : const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark ? const Color(0xFF4A3B1E) : AppColors.amberContainer,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGold.withValues(alpha: isDark ? 0.2 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: isDark ? AppColors.butterGold : AppColors.primaryGold,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryGold.withValues(alpha: 0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: Text('👑', style: TextStyle(fontSize: 32)),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Daily Recipe Limit Reached',
            textAlign: TextAlign.center,
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "You've unlocked all 3 free AI recipe creations for today. Upgrade to AnuMealAI Premium to unlock unlimited recipe generations, smart pantry auto-substitutions, and complete nutrition tracking.",
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 20),
          AppButton(
            label: 'Unlock Unlimited Recipes ✨',
            icon: Icons.star_rounded,
            backgroundColor: isDark
                ? AppColors.butterGold
                : AppColors.primaryGold,
            foregroundColor: const Color(0xFF141414),
            onPressed: () => context.push(AppRoutes.paywall),
          ),
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: () => context.push(AppRoutes.favorites),
            icon: const Icon(
              Icons.favorite_rounded,
              size: 16,
              color: AppColors.terracotta,
            ),
            label: Text(
              'Browse Saved Favorites',
              style: TextStyle(
                color: scheme.onSurface,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
