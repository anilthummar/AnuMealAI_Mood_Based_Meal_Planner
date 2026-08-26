import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Highly polished mood card with gradient highlight, glow,
/// emoji badge, and clean non-clipped border layout in both Light & Dark modes.
class MoodCard extends StatelessWidget {
  final String emoji;
  final String name;
  final String? description;
  final bool isSelected;
  final VoidCallback onTap;

  const MoodCard({
    super.key,
    required this.emoji,
    required this.name,
    this.description,
    bool? isSelected,
    bool selected = false,
    required this.onTap,
  }) : isSelected = isSelected ?? selected;

  Color _getMoodColor(String moodName) {
    final m = moodName.toLowerCase();
    if (m.contains('happy')) return const Color(0xFFE67E22);
    if (m.contains('relaxed')) return const Color(0xFF27AE60);
    if (m.contains('energetic')) return const Color(0xFFF39C12);
    if (m.contains('tired')) return const Color(0xFF4A69BD);
    if (m.contains('creative')) return const Color(0xFF8E44AD);
    if (m.contains('adventur')) return const Color(0xFFD35400);
    if (m.contains('healthy')) return const Color(0xFF16A085);
    if (m.contains('cozy')) return const Color(0xFFC0392B);
    if (m.contains('celebrat')) return const Color(0xFFE84393);
    if (m.contains('lazy')) return const Color(0xFF00B894);
    return AppColors.terracotta;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final moodColor = _getMoodColor(name);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 96,
          height: 82,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    colors: [
                      moodColor,
                      moodColor.withValues(alpha: 0.85),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isSelected
                ? null
                : (isDark ? scheme.surfaceContainerHigh : Colors.white),
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(
              color: isSelected
                  ? Colors.white.withValues(alpha: 0.6)
                  : (isDark ? Colors.transparent : scheme.outlineVariant),
              width: isSelected ? 1.8 : 1.0,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: moodColor.withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.04 : 0.03),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.25)
                      : scheme.surfaceContainerHighest.withValues(alpha: 0.8),
                  shape: BoxShape.circle,
                ),
                child: Text(emoji, style: const TextStyle(fontSize: 20, height: 1.1)),
              ),
              const SizedBox(height: 5),
              Text(
                name,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: isSelected ? Colors.white : scheme.onSurface,
                  fontSize: 11.5,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
