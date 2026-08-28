import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/ingredient_categories.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_chip.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_shimmer.dart';
import '../bloc/ingredient_cubit.dart';
import '../bloc/ingredient_state.dart';
import '../widgets/add_ingredient_sheet.dart';

class IngredientsPage extends StatelessWidget {
  const IngredientsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Kitchen & Pantry'),
        leading: BackButton(onPressed: () => context.pop()),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded),
            tooltip: 'Add ingredient',
            onPressed: () => _openAddSheet(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddSheet(context),
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Ingredient'),
      ),
      body: BlocBuilder<IngredientCubit, IngredientState>(
        builder: (context, state) {
          if (state.status == IngredientStatus.loading && state.ingredients.isEmpty) {
            return const ListSkeleton(count: 6);
          }

          final cubit = context.read<IngredientCubit>();
          final filtered = state.filteredIngredients;

          return Column(
            children: [
              // Search and Category filter
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0),
                child: AppTextField(
                  label: 'Search ingredients...',
                  prefixIcon: Icons.search_rounded,
                  onChanged: (val) => cubit.setSearchQuery(val),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              // Categories row
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: AppChip(
                        label: 'All (${state.ingredients.length})',
                        isSelected: state.selectedCategory == null || state.selectedCategory == 'All',
                        onTap: () => cubit.selectCategory('All'),
                      ),
                    ),
                    ...IngredientCategory.values.map((cat) {
                      final isSelected = state.selectedCategory == cat.label;
                      final count = state.ingredients.where((i) => i.category == cat.label).length;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: AppChip(
                          label: '${cat.emoji} ${cat.label} ($count)',
                          isSelected: isSelected,
                          onTap: () => cubit.selectCategory(cat.label),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              // Summary bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${state.availableCount} available items in kitchen',
                      style: textTheme.labelMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (state.searchQuery.isNotEmpty || state.selectedCategory != null)
                      TextButton(
                        onPressed: () {
                          cubit.setSearchQuery('');
                          cubit.selectCategory('All');
                        },
                        style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                        child: const Text('Clear Filters'),
                      ),
                  ],
                ),
              ),

              // Items List or Empty State
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => cubit.loadIngredients(),
                  child: filtered.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.4,
                              child: EmptyState(
                                emoji: '🥦',
                                title: state.ingredients.isEmpty
                                    ? 'Your fridge is looking empty'
                                    : 'No matching ingredients',
                                message: state.ingredients.isEmpty
                                    ? 'Add what you have at home to get personalized, mood-matching recipes.'
                                    : 'Try adjusting your search or category filter.',
                                actionLabel: state.ingredients.isEmpty
                                    ? 'Add Ingredients'
                                    : 'Add New Item',
                                actionIcon: Icons.add_rounded,
                                onAction: () => _openAddSheet(context),
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.md,
                            AppSpacing.xs,
                            AppSpacing.md,
                            AppSpacing.xxl + AppSpacing.xl,
                          ),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                          final item = filtered[index];
                          final catEnum = IngredientCategoryX.fromName(item.category.toLowerCase());

                          return Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                            child: Dismissible(
                              key: Key(item.id),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: AppSpacing.lg),
                                decoration: BoxDecoration(
                                  color: scheme.error,
                                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                                ),
                                child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
                              ),
                              onDismissed: (_) {
                                cubit.deleteIngredient(item.id);
                                AppSnackbar.show(
                                  context,
                                  message: 'Removed ${item.name}',
                                  actionLabel: 'Undo',
                                  onAction: () => cubit.addIngredient(
                                    name: item.name,
                                    category: item.category,
                                    quantity: item.quantity,
                                    unit: item.unit,
                                    expiryDate: item.expiryDate,
                                  ),
                                );
                              },
                              child: AppCard(
                                child: Row(
                                  children: [
                                    // Checkbox for availability
                                    Checkbox(
                                      value: item.isAvailable,
                                      activeColor: scheme.primary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      onChanged: (_) => cubit.toggleAvailability(item.id),
                                    ),
                                    const SizedBox(width: 4),

                                    // Category emoji avatar
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: scheme.surfaceContainerHighest,
                                        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                                      ),
                                      child: Text(
                                        catEnum.emoji,
                                        style: const TextStyle(fontSize: 22),
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.md),

                                    // Details
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.name,
                                            style: textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.w700,
                                              decoration: item.isAvailable
                                                  ? null
                                                  : TextDecoration.lineThrough,
                                              color: item.isAvailable
                                                  ? scheme.onSurface
                                                  : scheme.onSurfaceVariant,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Row(
                                            children: [
                                              Text(
                                                '${item.quantity} ${item.unit} • ${item.category}',
                                                style: textTheme.bodySmall?.copyWith(
                                                  color: scheme.onSurfaceVariant,
                                                ),
                                              ),
                                              if (item.expiryDate != null) ...[
                                                const SizedBox(width: 6),
                                                Text(
                                                  '• Exp ${DateFormat('MM/dd').format(item.expiryDate!)}',
                                                  style: textTheme.bodySmall?.copyWith(
                                                    color: item.expiryDate!.difference(DateTime.now()).inDays < 2
                                                        ? AppColors.terracotta
                                                        : scheme.onSurfaceVariant,
                                                    fontWeight: item.expiryDate!.difference(DateTime.now()).inDays < 2
                                                        ? FontWeight.bold
                                                        : FontWeight.normal,
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Edit action
                                    IconButton(
                                      icon: const Icon(Icons.edit_outlined, size: 18),
                                      onPressed: () {
                                        AddIngredientSheet.show(
                                          context,
                                          initialIngredient: item,
                                          onSave: ({
                                            required String name,
                                            required String category,
                                            required String quantity,
                                            required String unit,
                                            DateTime? expiryDate,
                                          }) {
                                            cubit.updateIngredient(
                                              item.copyWith(
                                                name: name,
                                                category: category,
                                                quantity: quantity,
                                                unit: unit,
                                                expiryDate: expiryDate,
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _openAddSheet(BuildContext context) {
    AddIngredientSheet.show(
      context,
      onSave: ({
        required String name,
        required String category,
        required String quantity,
        required String unit,
        DateTime? expiryDate,
      }) {
        context.read<IngredientCubit>().addIngredient(
              name: name,
              category: category,
              quantity: quantity,
              unit: unit,
              expiryDate: expiryDate,
            );
      },
    );
  }
}
