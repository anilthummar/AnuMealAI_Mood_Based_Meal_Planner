import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../theme/app_spacing.dart';

/// Shimmer loading container and standard skeleton layouts (§28).
/// Zero blank screens — every loading state is visually structured.
class LoadingShimmer extends StatelessWidget {
  final Widget child;

  const LoadingShimmer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = scheme.brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
      highlightColor: isDark ? Colors.grey.shade700 : Colors.grey.shade100,
      child: child,
    );
  }
}

class ShimmerBox extends StatelessWidget {
  final double? width;
  final double height;
  final double borderRadius;

  const ShimmerBox({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = AppSpacing.radiusSm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

class RecipeCardSkeleton extends StatelessWidget {
  const RecipeCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return LoadingShimmer(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ShimmerBox(height: 130, borderRadius: AppSpacing.radiusLg),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ShimmerBox(height: 16, width: double.infinity),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const ShimmerBox(height: 12, width: 80),
                      const SizedBox(width: 12),
                      const ShimmerBox(height: 12, width: 50),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RecipeGridSkeleton extends StatelessWidget {
  final int count;

  const RecipeGridSkeleton({super.key, this.count = 4});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.all(AppSpacing.md),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
        childAspectRatio: 0.76,
      ),
      itemCount: count,
      itemBuilder: (context, index) => const RecipeCardSkeleton(),
    );
  }
}

class ListSkeleton extends StatelessWidget {
  final int count;

  const ListSkeleton({super.key, this.count = 5});

  @override
  Widget build(BuildContext context) {
    return LoadingShimmer(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: count,
        separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.md),
        itemBuilder: (context, index) => Row(
          children: [
            const ShimmerBox(height: 56, width: 56, borderRadius: AppSpacing.radiusMd),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ShimmerBox(height: 16, width: 140),
                  const SizedBox(height: 8),
                  const ShimmerBox(height: 12, width: 200),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
