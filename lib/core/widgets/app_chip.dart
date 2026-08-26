import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Generic selectable chip supporting dual Light & Dark themes.
class AppChip extends StatelessWidget {
  final String label;
  final String? emoji;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onDeleted;

  const AppChip({
    super.key,
    required this.label,
    this.emoji,
    bool? isSelected,
    bool selected = false,
    this.onTap,
    this.onDeleted,
  }) : isSelected = isSelected ?? selected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bg = isSelected
        ? scheme.primaryContainer
        : (isDark ? scheme.surfaceContainerHighest : scheme.surfaceContainer);

    final border = Border.all(
      color: isSelected
          ? scheme.primary
          : (isDark ? const Color(0xFF333333) : scheme.outlineVariant),
      width: isSelected ? 1.4 : 1.0,
    );

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(999),
          border: border,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: scheme.primary.withValues(
                      alpha: isDark ? 0.25 : 0.15,
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
            if (emoji != null) ...[
              Text(emoji!, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: isSelected
                    ? (isDark
                          ? scheme.onPrimaryContainer
                          : AppColors.onAmberContainer)
                    : scheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                fontSize: 13.5,
              ),
            ),
            if (onDeleted != null) ...[
              const SizedBox(width: 6),
              GestureDetector(
                onTap: onDeleted,
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
    );
  }
}
