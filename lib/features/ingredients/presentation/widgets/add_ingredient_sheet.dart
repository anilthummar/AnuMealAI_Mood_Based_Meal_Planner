import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/ingredient_categories.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_chip.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../domain/entities/ingredient.dart';

class AddIngredientSheet extends StatefulWidget {
  final Ingredient? initialIngredient;
  final Function({
    required String name,
    required String category,
    required String quantity,
    required String unit,
    DateTime? expiryDate,
  }) onSave;

  const AddIngredientSheet({
    super.key,
    this.initialIngredient,
    required this.onSave,
  });

  static Future<void> show(
    BuildContext context, {
    Ingredient? initialIngredient,
    required Function({
      required String name,
      required String category,
      required String quantity,
      required String unit,
      DateTime? expiryDate,
    }) onSave,
  }) {
    return AppBottomSheet.show(
      context: context,
      builder: (ctx) => AddIngredientSheet(
        initialIngredient: initialIngredient,
        onSave: onSave,
      ),
    );
  }

  @override
  State<AddIngredientSheet> createState() => _AddIngredientSheetState();
}

class _AddIngredientSheetState extends State<AddIngredientSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _qtyController;
  late final TextEditingController _unitController;
  late String _selectedCategory;
  DateTime? _expiryDate;

  static const _quickStaples = [
    ('Eggs', 'Eggs'),
    ('Milk', 'Dairy'),
    ('Tomato', 'Vegetables'),
    ('Onion', 'Vegetables'),
    ('Garlic', 'Spices'),
    ('Pasta', 'Grains'),
    ('Rice', 'Grains'),
    ('Chicken', 'Meat'),
    ('Bread', 'Pantry'),
    ('Cheese', 'Dairy'),
    ('Spinach', 'Vegetables'),
    ('Olive Oil', 'Pantry'),
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialIngredient?.name ?? '');
    _qtyController = TextEditingController(text: widget.initialIngredient?.quantity ?? '1');
    _unitController = TextEditingController(text: widget.initialIngredient?.unit ?? 'pcs');
    _selectedCategory = widget.initialIngredient?.category ?? 'Vegetables';
    _expiryDate = widget.initialIngredient?.expiryDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _qtyController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  Future<void> _pickExpiryDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? now.add(const Duration(days: 7)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _expiryDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AppBottomSheet(
      title: widget.initialIngredient != null ? 'Edit Ingredient' : 'Add to Fridge / Pantry',
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick suggestions if new
            if (widget.initialIngredient == null) ...[
              Text(
                'Quick Add Staples',
                style: textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _quickStaples.map((staple) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ActionChip(
                        label: Text(staple.$1),
                        visualDensity: VisualDensity.compact,
                        onPressed: () {
                          setState(() {
                            _nameController.text = staple.$1;
                            _selectedCategory = staple.$2;
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],

            // Name
            AppTextField(
              label: 'Ingredient Name',
              controller: _nameController,
              hint: 'e.g. Cherry Tomatoes',
              prefixIcon: Icons.restaurant_menu_rounded,
            ),
            const SizedBox(height: AppSpacing.md),

            // Category selector
            Text(
              'Category',
              style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppSpacing.xs),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: IngredientCategory.values.map((cat) {
                  final isSelected = _selectedCategory == cat.label;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: AppChip(
                      label: '${cat.emoji} ${cat.label}',
                      isSelected: isSelected,
                      onTap: () {
                        setState(() => _selectedCategory = cat.label);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Quantity & Unit
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: AppTextField(
                    label: 'Quantity',
                    controller: _qtyController,
                    hint: '1, 500, etc.',
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  flex: 3,
                  child: AppTextField(
                    label: 'Unit',
                    controller: _unitController,
                    hint: 'pcs, grams, cups, tbsp',
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // Optional Expiry Date
            InkWell(
              onTap: _pickExpiryDate,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm + 4),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.5)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.event_outlined, color: scheme.primary, size: 20),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        _expiryDate != null
                            ? 'Expires: ${DateFormat('MMM dd, yyyy').format(_expiryDate!)}'
                            : 'Add Expiry Date (optional)',
                        style: textTheme.bodyMedium?.copyWith(
                          color: _expiryDate != null ? scheme.onSurface : scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    if (_expiryDate != null)
                      GestureDetector(
                        onTap: () => setState(() => _expiryDate = null),
                        child: Icon(Icons.clear_rounded, size: 18, color: scheme.onSurfaceVariant),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Save button
            AppButton(
              label: widget.initialIngredient != null ? 'Save Changes' : 'Add Ingredient',
              icon: Icons.check_rounded,
              onPressed: () {
                FocusScope.of(context).unfocus();
                if (_nameController.text.trim().isEmpty) return;
                widget.onSave(
                  name: _nameController.text.trim(),
                  category: _selectedCategory,
                  quantity: _qtyController.text.trim().isEmpty ? '1' : _qtyController.text.trim(),
                  unit: _unitController.text.trim().isEmpty ? 'pcs' : _unitController.text.trim(),
                  expiryDate: _expiryDate,
                );
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
