import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'premium_badge.dart';
import 'recipe_image.dart';

/// Ultra-stylish luxury recipe card supporting both Light & Dark themes.
/// Features left details (Title, 🔥 flame score, butter-gold time pill) and right circular food plate.
class RecipeCard extends StatelessWidget {
  final String id;
  final String title;
  final String? imageUrl;
  final int matchPercentage;
  final int totalTimeMinutes;
  final String difficulty;
  final String? cuisine;
  final int? calories;
  final bool isFavorite;
  final bool locked;
  final bool isHorizontal;
  final VoidCallback onTap;
  final VoidCallback? onFavoriteToggle;

  const RecipeCard({
    super.key,
    required this.id,
    required this.title,
    required this.matchPercentage,
    required this.totalTimeMinutes,
    required this.difficulty,
    required this.onTap,
    this.imageUrl,
    this.cuisine,
    this.calories,
    this.isFavorite = false,
    this.locked = false,
    this.isHorizontal = true,
    this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Simulated flame score based on match percentage (e.g. 4.85)
    final ratingScore = (4.0 + (matchPercentage / 100))
        .clamp(4.2, 5.0)
        .toStringAsFixed(2);
    final ratingCount = ((matchPercentage * 3) + 120);

    final cardBg = isDark ? const Color(0xFF222222) : Colors.white;
    final cardBorder = isDark
        ? Border.all(color: Colors.transparent)
        : Border.all(color: scheme.outlineVariant, width: 1.0);
    final cardShadow = isDark
        ? [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ]
        : [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ];

    if (isHorizontal) {
      return Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(24),
          border: cardBorder,
          boxShadow: cardShadow,
        ),
        clipBehavior: Clip.antiAlias,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Left: Title, Flame Rating, Time Pill
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: scheme.onSurface,
                            fontSize: 16.5,
                            letterSpacing: -0.3,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Flame rating / match
                        Row(
                          children: [
                            const Text('🔥', style: TextStyle(fontSize: 14)),
                            const SizedBox(width: 4),
                            Text(
                              '$ratingScore ($ratingCount)',
                              style: TextStyle(
                                color: isDark
                                    ? AppColors.goldenFlame
                                    : AppColors.primaryGold,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Luxury Butter Gold Time Pill
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.butterGold
                                : scheme.primaryContainer,
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusPill,
                            ),
                          ),
                          child: Text(
                            '$totalTimeMinutes MIN',
                            style: TextStyle(
                              color: isDark
                                  ? const Color(0xFF141414)
                                  : AppColors.onAmberContainer,
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Right: Circular Gourmet Plate
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(
                                alpha: isDark ? 0.4 : 0.12,
                              ),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: RecipeImage(
                            seed: title,
                            imageUrl: imageUrl,
                            width: 110,
                            height: 110,
                            borderRadius: BorderRadius.zero,
                          ),
                        ),
                      ),
                      if (locked)
                        const Positioned(
                          top: 4,
                          right: 4,
                          child: PremiumBadge(),
                        ),
                      Positioned(
                        top: 2,
                        right: 2,
                        child: GestureDetector(
                          onTap: onFavoriteToggle,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.black.withValues(alpha: 0.55)
                                  : Colors.white.withValues(alpha: 0.85),
                              shape: BoxShape.circle,
                              boxShadow: isDark
                                  ? null
                                  : [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.08,
                                        ),
                                        blurRadius: 4,
                                      ),
                                    ],
                            ),
                            child: Icon(
                              isFavorite
                                  ? Icons.bookmark_rounded
                                  : Icons.bookmark_border_rounded,
                              color: isFavorite
                                  ? (isDark
                                        ? AppColors.butterGold
                                        : AppColors.primaryGold)
                                  : (isDark
                                        ? Colors.white
                                        : const Color(0xFF686259)),
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // Grid / Compact Variant
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        border: cardBorder,
        boxShadow: cardShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Plate
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(
                                alpha: isDark ? 0.35 : 0.1,
                              ),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: RecipeImage(
                            seed: title,
                            imageUrl: imageUrl,
                            width: 100,
                            height: 100,
                            borderRadius: BorderRadius.zero,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: onFavoriteToggle,
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.black.withValues(alpha: 0.55)
                                  : Colors.white.withValues(alpha: 0.85),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isFavorite
                                  ? Icons.bookmark_rounded
                                  : Icons.bookmark_border_rounded,
                              color: isFavorite
                                  ? (isDark
                                        ? AppColors.butterGold
                                        : AppColors.primaryGold)
                                  : (isDark
                                        ? Colors.white
                                        : const Color(0xFF686259)),
                              size: 15,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: scheme.onSurface,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Text('🔥', style: TextStyle(fontSize: 11)),
                    const SizedBox(width: 3),
                    Text(
                      ratingScore,
                      style: TextStyle(
                        color: isDark
                            ? AppColors.goldenFlame
                            : AppColors.primaryGold,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.butterGold
                        : scheme.primaryContainer,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                  ),
                  child: Text(
                    '$totalTimeMinutes MIN',
                    style: TextStyle(
                      color: isDark
                          ? const Color(0xFF141414)
                          : AppColors.onAmberContainer,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
