import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/loading_shimmer.dart';
import '../../../../core/widgets/mood_card.dart';
import '../../../../core/widgets/recipe_card.dart';
import '../../../favorites/presentation/bloc/favorites_cubit.dart';
import '../../../mood/presentation/bloc/mood_cubit.dart';
import '../../../profile/presentation/bloc/profile_cubit.dart';
import '../../../recipes/presentation/bloc/recipe_cubit.dart';
import '../bloc/home_cubit.dart';
import '../bloc/home_state.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    context.read<HomeCubit>().loadDashboard();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final profileState = context.watch<ProfileCubit>().state;
    final displayName = profileState.preferences.name.isNotEmpty
        ? profileState.preferences.name
        : 'Julia';

    final cardBg = isDark ? const Color(0xFF222222) : Colors.white;
    final cardBorder = isDark
        ? null
        : Border.all(color: scheme.outlineVariant, width: 1.0);
    final cardShadow = isDark
        ? [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ]
        : [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ];

    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => context.read<HomeCubit>().loadDashboard(),
          color: scheme.primary,
          child: BlocBuilder<HomeCubit, HomeState>(
            builder: (context, state) {
              if (state.status == HomeStatus.loading &&
                  state.quickSuggestions.isEmpty) {
                return const ListSkeleton(count: 6);
              }

              final moodState = context.watch<MoodCubit>().state;
              final favState = context.watch<FavoritesCubit>().state;

              return ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.lg,
                  AppSpacing.xxl + 20,
                ),
                children: [
                  // 1. Top Header: "Hi Julia" + Subtitle + Avatar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hi $displayName',
                            style: textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: scheme.onSurface,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'We hope you are in\ngood mood for cooking',
                            style: TextStyle(
                              color: scheme.onSurfaceVariant,
                              fontSize: 14,
                              height: 1.25,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      // Circular Profile Avatar (Default Monogram)
                      GestureDetector(
                        onTap: () => context.go(AppRoutes.profile),
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [AppColors.terracotta, AppColors.golden],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            border: Border.all(
                              color: isDark
                                  ? AppColors.butterGold
                                  : AppColors.primaryGold,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    (isDark
                                            ? AppColors.butterGold
                                            : AppColors.primaryGold)
                                        .withValues(alpha: isDark ? 0.3 : 0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              displayName.isNotEmpty
                                  ? displayName[0].toUpperCase()
                                  : 'A',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // 2. Mood Carousel with glow
                  SizedBox(
                    height: 94,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      clipBehavior: Clip.none,
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      itemCount: moodState.allMoods.length,
                      itemBuilder: (context, index) {
                        final mood = moodState.allMoods[index];
                        final isSelected = moodState.selectedMood.id == mood.id;

                        return Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: MoodCard(
                            emoji: mood.emoji,
                            name: mood.name,
                            description: mood.description,
                            isSelected: isSelected,
                            onTap: () {
                              context.read<MoodCubit>().selectMood(mood);
                              context.read<HomeCubit>().loadDashboard();
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // 3. Section Title: "New dishes 42" with filter icon
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            'New dishes',
                            style: TextStyle(
                              color: scheme.onSurface,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${state.quickSuggestions.isNotEmpty ? state.quickSuggestions.length * 7 + 7 : 42}',
                            style: TextStyle(
                              color: isDark
                                  ? AppColors.butterGold
                                  : AppColors.primaryGold,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.tune_rounded,
                          color: isDark
                              ? AppColors.butterGold
                              : AppColors.primaryGold,
                          size: 22,
                        ),
                        onPressed: () => context.go(AppRoutes.recipes),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // 4. Filter Chips: "Main dishes ×", "Deserts ×", "Meat", "Produce", etc.
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip(
                          'All',
                          isSelected: _selectedCategory == 'All',
                        ),
                        _buildFilterChip(
                          'Main dishes',
                          isSelected: _selectedCategory == 'Main dishes',
                          hasRemove: true,
                        ),
                        _buildFilterChip(
                          'Breakfast',
                          isSelected: _selectedCategory == 'Breakfast',
                          hasRemove: true,
                        ),
                        _buildFilterChip(
                          'Quick & Easy',
                          isSelected: _selectedCategory == 'Quick & Easy',
                        ),
                        _buildFilterChip(
                          'Desserts',
                          isSelected: _selectedCategory == 'Desserts',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // 5. List of Luxury Horizontal Recipe Cards
                  if (state.quickSuggestions.isNotEmpty) ...[
                    ...state.quickSuggestions.map((recipe) {
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
                          context.read<RecipeCubit>().setSelectedRecipe(recipe);
                          context.push(
                            AppRoutes.recipeDetailPath(recipe.id),
                            extra: recipe,
                          );
                        },
                        onFavoriteToggle: () => context
                            .read<FavoritesCubit>()
                            .toggleFavorite(recipe),
                      );
                    }),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(24),
                        border: cardBorder,
                        boxShadow: cardShadow,
                      ),
                      child: Row(
                        children: [
                          const Text('🍳', style: TextStyle(fontSize: 32)),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              'Add ingredients to unlock chef-crafted dishes for your mood!',
                              style: TextStyle(
                                color: scheme.onSurface,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.md),

                  // 6. Kitchen & Planner Shortcuts Row
                  Row(
                    children: [
                      // Pantry shortcut
                      Expanded(
                        child: InkWell(
                          onTap: () => context.push(AppRoutes.ingredients),
                          borderRadius: BorderRadius.circular(24),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: cardBg,
                              borderRadius: BorderRadius.circular(24),
                              border: cardBorder,
                              boxShadow: cardShadow,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.sage.withValues(
                                      alpha: 0.18,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Text(
                                    '🥬',
                                    style: TextStyle(fontSize: 20),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${state.availableIngredientsCount} In Pantry',
                                        style: TextStyle(
                                          color: scheme.onSurface,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        'Manage fridge →',
                                        style: TextStyle(
                                          color: isDark
                                              ? AppColors.butterGold
                                              : AppColors.primaryGold,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),

                      // Meal Planner shortcut
                      Expanded(
                        child: InkWell(
                          onTap: () => context.go(AppRoutes.planner),
                          borderRadius: BorderRadius.circular(24),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: cardBg,
                              borderRadius: BorderRadius.circular(24),
                              border: cardBorder,
                              boxShadow: cardShadow,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: scheme.primaryContainer,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Text(
                                    '📅',
                                    style: TextStyle(fontSize: 20),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Meal Planner',
                                        style: TextStyle(
                                          color: scheme.onSurface,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        'Plan 7 days →',
                                        style: TextStyle(
                                          color: isDark
                                              ? AppColors.butterGold
                                              : AppColors.primaryGold,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    String label, {
    bool isSelected = false,
    bool hasRemove = false,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bg = isSelected
        ? scheme.primaryContainer
        : (isDark ? const Color(0xFF1E1E1E) : scheme.surfaceContainer);

    final border = Border.all(
      color: isSelected
          ? scheme.primary
          : (isDark ? Colors.transparent : scheme.outlineVariant),
      width: 1.2,
    );

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: () => setState(() => _selectedCategory = label),
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
            border: border,
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: scheme.primary.withValues(
                        alpha: isDark ? 0.25 : 0.12,
                      ),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? (isDark
                            ? scheme.onPrimaryContainer
                            : AppColors.onAmberContainer)
                      : scheme.onSurfaceVariant,
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
              if (hasRemove) ...[
                const SizedBox(width: 6),
                Icon(
                  Icons.close_rounded,
                  size: 14,
                  color: isSelected
                      ? (isDark
                            ? scheme.onPrimaryContainer
                            : AppColors.onAmberContainer)
                      : scheme.onSurfaceVariant,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
