import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

/// Premium elevated card with subtle drop shadow, smooth borders,
/// and responsive material ripple in both Light & Dark modes.
class AppCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final Color? borderColor;
  final Color? backgroundColor;
  final double borderRadius;
  final double elevation;

  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.borderColor,
    this.backgroundColor,
    this.borderRadius = 24,
    this.elevation = 0,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final border = borderColor != null
        ? Border.all(color: borderColor!, width: 1.5)
        : Border.all(
            color: isDark ? const Color(0xFF282828) : scheme.outlineVariant,
            width: 1.0,
          );

    return Container(
      decoration: BoxDecoration(
        color:
            backgroundColor ??
            (isDark ? scheme.surfaceContainerHigh : Colors.white),
        borderRadius: BorderRadius.circular(borderRadius),
        border: border,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
