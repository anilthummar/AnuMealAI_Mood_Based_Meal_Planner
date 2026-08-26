import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_chip.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_shimmer.dart';
import '../bloc/shopping_list_cubit.dart';
import '../bloc/shopping_list_state.dart';

class ShoppingListPage extends StatelessWidget {
  const ShoppingListPage({super.key});

  void _showAddItemSheet(BuildContext context) {
    final cubit = context.read<ShoppingListCubit>();
    final nameController = TextEditingController();
    final quantityController = TextEditingController(text: '1');
    String selectedCategory = 'Produce';
    String? validationError;

    final quickPicks = [
      {'name': 'Milk', 'cat': 'Dairy', 'emoji': '🥛'},
      {'name': 'Eggs', 'cat': 'Dairy', 'emoji': '🥚'},
      {'name': 'Bread', 'cat': 'Bakery', 'emoji': '🍞'},
      {'name': 'Spinach', 'cat': 'Produce', 'emoji': '🥬'},
      {'name': 'Tomatoes', 'cat': 'Produce', 'emoji': '🍅'},
      {'name': 'Chicken Breast', 'cat': 'Meat', 'emoji': '🍗'},
      {'name': 'Olive Oil', 'cat': 'Pantry', 'emoji': '🫒'},
      {'name': 'Black Pepper', 'cat': 'Spices', 'emoji': '🧂'},
    ];

    AppBottomSheet.show(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) {
          final textTheme = Theme.of(ctx).textTheme;
          final scheme = Theme.of(ctx).colorScheme;

          return AppBottomSheet(
            title: 'Add to Shopping List',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Quick Pick Suggestions
                Text(
                  'Quick Add Suggestions',
                  style: textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: quickPicks.map((pick) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ActionChip(
                          avatar: Text(pick['emoji']!),
                          label: Text(pick['name']!),
                          backgroundColor: scheme.surfaceContainerHighest,
                          onPressed: () {
                            setState(() {
                              nameController.text = pick['name']!;
                              selectedCategory = pick['cat']!;
                              validationError = null;
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Item Name Input
                AppTextField(
                  label: 'Item Name',
                  hint: 'e.g. Fresh Basil, Olive Oil',
                  controller: nameController,
                  prefixIcon: Icons.shopping_basket_outlined,
                  onChanged: (_) {
                    if (validationError != null) {
                      setState(() => validationError = null);
                    }
                  },
                ),
                if (validationError != null) ...[
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(
                      validationError!,
                      style: const TextStyle(color: AppColors.error, fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.md),

                // Quantity Input
                AppTextField(
                  label: 'Quantity / Unit',
                  hint: 'e.g. 2 bunches, 500g, 1 bottle',
                  controller: quantityController,
                  prefixIcon: Icons.scale_outlined,
                ),
                const SizedBox(height: AppSpacing.md),

                // Category Chips
                Text('Category', style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: AppSpacing.xs),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    'Produce 🥬',
                    'Dairy 🧀',
                    'Meat 🥩',
                    'Pantry 🥫',
                    'Spices 🧂',
                    'Bakery 🍞',
                  ].map((cat) {
                    final cleanCat = cat.split(' ').first;
                    final isSelected = selectedCategory.toLowerCase() == cleanCat.toLowerCase();
                    return AppChip(
                      label: cat,
                      isSelected: isSelected,
                      onTap: () => setState(() => selectedCategory = cleanCat),
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Add Button
                AppButton(
                  label: 'Add to List 🛒',
                  onPressed: () {
                    final text = nameController.text.trim();
                    if (text.isEmpty) {
                      setState(() {
                        validationError = 'Please enter an item name';
                      });
                      return;
                    }

                    cubit.addItem(
                      name: text,
                      category: selectedCategory,
                      quantity: quantityController.text.trim().isNotEmpty
                          ? quantityController.text.trim()
                          : '1 pcs',
                    );

                    Navigator.of(ctx).pop();
                    AppSnackbar.show(
                      context,
                      message: 'Added "$text" to shopping list! 🛒',
                      variant: SnackbarVariant.success,
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping List'),
        actions: [
          BlocBuilder<ShoppingListCubit, ShoppingListState>(
            builder: (context, state) {
              if (state.completedCount == 0) return const SizedBox.shrink();
              return TextButton.icon(
                icon: const Icon(Icons.cleaning_services_rounded, size: 16),
                label: const Text('Clear Done'),
                onPressed: () => context.read<ShoppingListCubit>().clearCompleted(),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddItemSheet(context),
        icon: const Icon(Icons.add_shopping_cart_rounded),
        label: const Text('Add Item'),
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
      ),
      body: BlocBuilder<ShoppingListCubit, ShoppingListState>(
        builder: (context, state) {
          if (state.status == ShoppingListStatus.loading && state.items.isEmpty) {
            return const ListSkeleton(count: 6);
          }

          if (state.items.isEmpty) {
            return EmptyState(
              emoji: '🛒',
              title: 'Your Grocery List is Empty',
              message: 'Generate a meal plan or explore recipes to add missing ingredients in one tap!',
              actionLabel: 'Discover Recipes 🍳',
              onAction: () => context.go(AppRoutes.recipes),
            );
          }

          final grouped = state.groupedByCategory;
          final progressPercent = state.items.isEmpty ? 0.0 : state.completedCount / state.items.length;

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.xs,
              AppSpacing.md,
              AppSpacing.xxl + 40,
            ),
            children: [
              // Progress Banner Card
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${state.completedCount} of ${state.items.length} items gathered',
                          style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        Text(
                          '${(progressPercent * 100).toInt()}%',
                          style: textTheme.titleSmall?.copyWith(
                            color: progressPercent == 1.0 ? AppColors.sage : scheme.primary,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                      child: LinearProgressIndicator(
                        value: progressPercent,
                        minHeight: 8,
                        backgroundColor: scheme.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          progressPercent == 1.0 ? AppColors.sage : scheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Grouped Grocery Categories
              ...grouped.entries.map((entry) {
                final category = entry.key;
                final items = entry.value;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                      child: Row(
                        children: [
                          Text(_categoryEmoji(category), style: const TextStyle(fontSize: 18)),
                          const SizedBox(width: 6),
                          Text(
                            category,
                            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: scheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                            ),
                            child: Text(
                              '${items.length}',
                              style: TextStyle(
                                color: scheme.onSurfaceVariant,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ...items.map((item) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: Dismissible(
                          key: ValueKey(item.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: AppSpacing.md),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                            ),
                            child: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                          ),
                          onDismissed: (_) {
                            context.read<ShoppingListCubit>().deleteItem(item.id);
                          },
                          child: AppCard(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: AppSpacing.xs,
                            ),
                            child: Row(
                              children: [
                                Checkbox(
                                  value: item.isChecked,
                                  activeColor: AppColors.sage,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  onChanged: (_) => context.read<ShoppingListCubit>().toggleCheck(item.id),
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.name,
                                        style: textTheme.bodyLarge?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          decoration: item.isChecked ? TextDecoration.lineThrough : null,
                                          color: item.isChecked
                                              ? scheme.onSurfaceVariant.withValues(alpha: 0.6)
                                              : scheme.onSurface,
                                        ),
                                      ),
                                      if (item.quantity.isNotEmpty)
                                        Text(
                                          item.quantity,
                                          style: textTheme.bodySmall?.copyWith(
                                            color: scheme.onSurfaceVariant,
                                            fontSize: 12,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close_rounded, size: 18),
                                  color: scheme.onSurfaceVariant.withValues(alpha: 0.5),
                                  onPressed: () => context.read<ShoppingListCubit>().deleteItem(item.id),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                );
              }),
            ],
          );
        },
      ),
    );
  }

  String _categoryEmoji(String cat) {
    switch (cat.toLowerCase()) {
      case 'produce':
        return '🥬';
      case 'dairy':
        return '🧀';
      case 'meat':
      case 'protein':
        return '🥩';
      case 'pantry':
        return '🥫';
      case 'spices':
        return '🧂';
      case 'bakery':
        return '🍞';
      default:
        return '🛒';
    }
  }
}
