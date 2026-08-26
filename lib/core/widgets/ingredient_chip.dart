import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

/// Reusable ingredient chip supporting selected, unselected, and deletable states (§25).
class IngredientChip extends StatelessWidget {
  final String label;
  final String? emoji;
  final String? quantity;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const IngredientChip({
    super.key,
    required this.label,
    this.emoji,
    this.quantity,
    this.isSelected = false,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: isSelected ? scheme.primaryContainer : scheme.surfaceContainerHigh,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        side: BorderSide(
          color: isSelected ? scheme.primary : scheme.outlineVariant.withValues(alpha: 0.5),
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs + 2,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (emoji != null) ...[
                Text(emoji!, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: textTheme.labelLarge?.copyWith(
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? scheme.onPrimaryContainer : scheme.onSurface,
                ),
              ),
              if (quantity != null && quantity!.isNotEmpty) ...[
                const SizedBox(width: 4),
                Text(
                  '($quantity)',
                  style: textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
              if (onDelete != null) ...[
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: onDelete,
                  child: Icon(
                    Icons.close_rounded,
                    size: 16,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
