import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/premium_badge.dart';
import '../../../../core/widgets/recipe_image.dart';
import '../../../ingredients/presentation/bloc/ingredient_cubit.dart';
import '../../../mood/presentation/bloc/mood_cubit.dart';
import '../../../profile/presentation/bloc/profile_cubit.dart';
import '../../../recipes/presentation/bloc/recipe_cubit.dart';
import '../../../shopping_list/presentation/bloc/shopping_list_cubit.dart';
import '../../../subscription/presentation/bloc/subscription_cubit.dart';
import '../../domain/entities/weekly_meal_plan.dart';
import '../bloc/meal_planner_cubit.dart';
import '../bloc/meal_planner_state.dart';

class MealPlannerPage extends StatelessWidget {
  const MealPlannerPage({super.key});

  void _generate(BuildContext context) {
    final moodState = context.read<MoodCubit>().state;
    final ingState = context.read<IngredientCubit>().state;
    final profileState = context.read<ProfileCubit>().state;

    final availableNames = ingState.availableIngredients
        .map((i) => i.name)
        .toList();

    context.read<MealPlannerCubit>().generateWeekPlan(
      moodId: moodState.selectedMood.id,
      moodTraits: moodState.selectedMood.traits,
      availableIngredients: availableNames,
      dietaryRestrictions: profileState.preferences.dietaryRestrictions,
      favoriteCuisines: profileState.preferences.favoriteCuisines,
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocConsumer<MealPlannerCubit, MealPlannerState>(
      listener: (context, state) {
        if (state.errorMessage == 'PLAN_LIMIT_REACHED') {
          context.read<MealPlannerCubit>().clearError();
          context.push(AppRoutes.paywall);
        }
      },
      builder: (context, state) {
        final cubit = context.read<MealPlannerCubit>();
        final plan = state.currentPlan;
        final subState = context.watch<SubscriptionCubit>().state;
        final isPremium = subState.isPremium;

        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                const Text('Weekly Meal Planner'),
                if (isPremium) ...[
                  const SizedBox(width: AppSpacing.xs),
                  const PremiumBadge(compact: true),
                ],
              ],
            ),
            actions: [
              if (plan != null)
                IconButton(
                  icon: const Icon(Icons.auto_awesome_rounded),
                  tooltip: 'Regenerate full week',
                  onPressed: state.status == MealPlannerStatus.generating
                      ? null
                      : () => _generate(context),
                ),
            ],
          ),
          body: () {
            if (state.status == MealPlannerStatus.generating) {
              return Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                    vertical: AppSpacing.lg,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Radiant Culinary AI Pulse Hero
                      Container(
                        width: 92,
                        height: 92,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const RadialGradient(
                            colors: [Color(0xFFFEF3C7), Color(0xFFFDE68A)],
                          ),
                          border: Border.all(
                            color: isDark
                                ? AppColors.butterGold
                                : AppColors.primaryGold,
                            width: 2.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  (isDark
                                          ? AppColors.butterGold
                                          : AppColors.primaryGold)
                                      .withValues(alpha: isDark ? 0.35 : 0.25),
                              blurRadius: 24,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text('🥘', style: TextStyle(fontSize: 44)),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      Text(
                        'AI is Crafting Your 7-Day Menu ✨',
                        textAlign: TextAlign.center,
                        style: textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          fontSize: 22,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Balancing 21 delicious breakfast, lunch & dinner recipes personalized for your pantry and dietary goals.',
                        textAlign: TextAlign.center,
                        style: textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                          height: 1.35,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // Real-time Steps Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark
                              ? scheme.surfaceContainerHigh
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF2E2E2E)
                                : scheme.outlineVariant,
                            width: 1.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(
                                alpha: isDark ? 0.2 : 0.04,
                              ),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            _buildProgressMilestone(
                              context,
                              emoji: '🍅',
                              text:
                                  'Analyzing available pantry & fridge ingredients...',
                              isDone: true,
                            ),
                            const SizedBox(height: 10),
                            _buildProgressMilestone(
                              context,
                              emoji: '🥗',
                              text:
                                  'Pairing mood & dietary restriction parameters...',
                              isDone: true,
                            ),
                            const SizedBox(height: 10),
                            _buildProgressMilestone(
                              context,
                              emoji: '📅',
                              text:
                                  'Optimizing 7-day nutritional and prep balance...',
                              isDone: false,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // Golden Linear Progress Bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusPill,
                        ),
                        child: SizedBox(
                          height: 6,
                          child: LinearProgressIndicator(
                            backgroundColor: isDark
                                ? const Color(0xFF282828)
                                : scheme.surfaceContainerHighest,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              scheme.primary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (plan == null) {
              return EmptyState(
                emoji: '📅',
                title: 'No Meal Plan Generated Yet',
                message:
                    'Let AnuMealAI automatically balance 7 days of delicious, mood-tailored meals based on your available fridge ingredients!',
                actionLabel: 'Generate 7-Day Plan ✨',
                onAction: () => _generate(context),
              );
            }

            final dayEntries = plan.entriesForDay(state.selectedDayIndex);

            return Column(
              children: [
                // Day Selector Slider (Mon - Sun)
                Container(
                  height: 76,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                    itemCount: 7,
                    itemBuilder: (context, index) {
                      final isSelected = state.selectedDayIndex == index;
                      final dayName = WeeklyMealPlan.dayNames[index];
                      final shortDay = dayName.substring(0, 3);

                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: InkWell(
                          onTap: () => cubit.selectDay(index),
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusLg,
                          ),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            width: 62,
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? scheme.primary
                                  : scheme.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusLg,
                              ),
                              border: Border.all(
                                color: isSelected
                                    ? scheme.primary
                                    : Colors.transparent,
                                width: 1.5,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: scheme.primary.withValues(
                                          alpha: 0.3,
                                        ),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  shortDay,
                                  style: TextStyle(
                                    color: isSelected
                                        ? scheme.onPrimary
                                        : scheme.onSurface,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Day ${index + 1}',
                                  style: TextStyle(
                                    color: isSelected
                                        ? scheme.onPrimary.withValues(
                                            alpha: 0.85,
                                          )
                                        : scheme.onSurfaceVariant,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const Divider(height: 1),

                // Meal Slots for the Selected Day
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async => cubit.loadCurrentPlan(),
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md,
                        AppSpacing.sm,
                        AppSpacing.md,
                        AppSpacing.xxl,
                      ),
                      children: [
                        // Header & "Add Missing to Shopping List" Action
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${WeeklyMealPlan.dayNames[state.selectedDayIndex]} Menu',
                                  style: textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Text(
                                  'Tap meal to view or cook',
                                  style: textTheme.bodySmall?.copyWith(
                                    color: scheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                            TextButton.icon(
                              icon: const Icon(
                                Icons.add_shopping_cart_rounded,
                                size: 16,
                              ),
                              label: const Text('Add Missing 🛒'),
                              onPressed: () {
                                final allMissing = <String>{};
                                for (final entry in dayEntries) {
                                  allMissing.addAll(
                                    entry.recipe.missingIngredients,
                                  );
                                }
                                if (allMissing.isEmpty) {
                                  AppSnackbar.show(
                                    context,
                                    message:
                                        'You already have all ingredients for this day! 🎉',
                                  );
                                } else {
                                  for (final item in allMissing) {
                                    context.read<ShoppingListCubit>().addItem(
                                      name: item,
                                      category: 'Produce',
                                    );
                                  }
                                  AppSnackbar.show(
                                    context,
                                    message:
                                        'Added ${allMissing.length} ingredients to shopping list! 🛒',
                                    variant: SnackbarVariant.success,
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),

                        ...WeeklyMealPlan.slots.map((slot) {
                          final entry = dayEntries
                              .where(
                                (e) =>
                                    e.mealSlot.toLowerCase() ==
                                    slot.toLowerCase(),
                              )
                              .firstOrNull;

                          if (entry == null) {
                            return Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppSpacing.md,
                              ),
                              child: AppCard(
                                child: Row(
                                  children: [
                                    Text(
                                      _slotIcon(slot),
                                      style: const TextStyle(fontSize: 22),
                                    ),
                                    const SizedBox(width: AppSpacing.sm),
                                    Text(
                                      slot,
                                      style: textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const Spacer(),
                                    TextButton(
                                      onPressed: () => _generate(context),
                                      child: const Text('Add Meal'),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          final recipe = entry.recipe;

                          return Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.md,
                            ),
                            child: AppCard(
                              borderColor: entry.isCooked
                                  ? AppColors.sage
                                  : null,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Slot header
                                  Row(
                                    children: [
                                      Text(
                                        _slotIcon(slot),
                                        style: const TextStyle(fontSize: 18),
                                      ),
                                      const SizedBox(width: AppSpacing.xs),
                                      Text(
                                        slot.toUpperCase(),
                                        style: textTheme.labelSmall?.copyWith(
                                          color: _slotColor(slot),
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 1.1,
                                        ),
                                      ),
                                      const Spacer(),
                                      if (entry.isCooked)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 3,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.sage.withValues(
                                              alpha: 0.15,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              AppSpacing.radiusPill,
                                            ),
                                          ),
                                          child: const Row(
                                            children: [
                                              Icon(
                                                Icons.check_circle_rounded,
                                                color: AppColors.sage,
                                                size: 14,
                                              ),
                                              SizedBox(width: 4),
                                              Text(
                                                'COOKED',
                                                style: TextStyle(
                                                  color: AppColors.sage,
                                                  fontWeight: FontWeight.w900,
                                                  fontSize: 10,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                  const Divider(height: AppSpacing.md),

                                  // Recipe summary row
                                  InkWell(
                                    onTap: () {
                                      context
                                          .read<RecipeCubit>()
                                          .setSelectedRecipe(recipe);
                                      context.push(
                                        AppRoutes.recipeDetailPath(recipe.id),
                                        extra: recipe,
                                      );
                                    },
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 68,
                                          height: 68,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withValues(
                                                  alpha: 0.3,
                                                ),
                                                blurRadius: 6,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: ClipOval(
                                            child: RecipeImage(
                                              seed: recipe.title,
                                              imageUrl: recipe.imageUrl,
                                              width: 68,
                                              height: 68,
                                              borderRadius: BorderRadius.zero,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: AppSpacing.md),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                recipe.title,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: textTheme.titleSmall
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.w800,
                                                    ),
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 6,
                                                          vertical: 2,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: AppColors.sage
                                                          .withValues(
                                                            alpha: 0.15,
                                                          ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            AppSpacing
                                                                .radiusPill,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      '${recipe.matchPercentage}% match',
                                                      style: const TextStyle(
                                                        color: AppColors.sage,
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.w800,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    '${recipe.totalTimeMinutes}m • ${recipe.calories} kcal',
                                                    style: textTheme.bodySmall
                                                        ?.copyWith(
                                                          color: scheme
                                                              .onSurfaceVariant,
                                                          fontSize: 11,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.sm),

                                  // Actions: Swap / Cook
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.refresh_rounded,
                                          size: 20,
                                        ),
                                        tooltip: 'Swap this meal',
                                        onPressed: () {
                                          final moodState = context
                                              .read<MoodCubit>()
                                              .state;
                                          final ingState = context
                                              .read<IngredientCubit>()
                                              .state;
                                          cubit.swapMeal(
                                            entryId: entry.id,
                                            moodId: moodState.selectedMood.id,
                                            availableIngredients: ingState
                                                .availableIngredients
                                                .map((i) => i.name)
                                                .toList(),
                                          );
                                        },
                                      ),
                                      const SizedBox(width: 4),
                                      ElevatedButton.icon(
                                        icon: Icon(
                                          entry.isCooked
                                              ? Icons.check_rounded
                                              : Icons.restaurant_rounded,
                                          size: 16,
                                        ),
                                        label: Text(
                                          entry.isCooked
                                              ? 'Marked Cooked'
                                              : 'Cook',
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          visualDensity: VisualDensity.compact,
                                          minimumSize: const Size(0, 36),
                                          backgroundColor: entry.isCooked
                                              ? AppColors.sage
                                              : scheme.primary,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 14,
                                          ),
                                        ),
                                        onPressed: () {
                                          if (entry.isCooked) {
                                            cubit.toggleMealCooked(entry.id);
                                          } else {
                                            context
                                                .read<RecipeCubit>()
                                                .setSelectedRecipe(recipe);
                                            context.push(
                                              AppRoutes.cookingModePath(
                                                recipe.id,
                                              ),
                                              extra: recipe,
                                            );
                                            cubit.toggleMealCooked(entry.id);
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }(),
        );
      },
    );
  }

  Color _slotColor(String slot) {
    switch (slot.toLowerCase()) {
      case 'breakfast':
        return AppColors.golden;
      case 'lunch':
        return AppColors.sage;
      case 'dinner':
        return AppColors.terracotta;
      case 'snack':
        return const Color(0xFF8E44AD);
      default:
        return AppColors.charcoal;
    }
  }

  String _slotIcon(String slot) {
    switch (slot.toLowerCase()) {
      case 'breakfast':
        return '🥞';
      case 'lunch':
        return '🥗';
      case 'dinner':
        return '🍲';
      case 'snack':
        return '🍎';
      default:
        return '🍽️';
    }
  }

  Widget _buildProgressMilestone(
    BuildContext context, {
    required String emoji,
    required String text,
    required bool isDone,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: isDark
                ? scheme.surfaceContainerHighest
                : scheme.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Text(emoji, style: const TextStyle(fontSize: 14)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: scheme.onSurface,
            ),
          ),
        ),
        Icon(
          isDone ? Icons.check_circle_rounded : Icons.hourglass_top_rounded,
          size: 16,
          color: isDone
              ? (isDark ? AppColors.butterGold : AppColors.primaryGold)
              : scheme.onSurfaceVariant,
        ),
      ],
    );
  }
}
