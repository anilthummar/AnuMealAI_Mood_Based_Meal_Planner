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

class RecipeHorizontalCardSkeleton extends StatelessWidget {
  const RecipeHorizontalCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF222222) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? const Color(0xFF333333) : const Color(0xFFEEEEEE),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ShimmerBox(height: 18, width: 170, borderRadius: 6),
                const SizedBox(height: 10),
                Row(
                  children: const [
                    ShimmerBox(height: 14, width: 60, borderRadius: 6),
                    SizedBox(width: 8),
                    ShimmerBox(height: 14, width: 70, borderRadius: 6),
                  ],
                ),
                const SizedBox(height: 10),
                const ShimmerBox(height: 22, width: 65, borderRadius: 12),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          const ShimmerBox(height: 96, width: 96, borderRadius: 48),
        ],
      ),
    );
  }
}

class HomeScreenSkeleton extends StatelessWidget {
  const HomeScreenSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return LoadingShimmer(
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          AppSpacing.xxl,
        ),
        children: [
          // 1. Top Header: Greeting + Subtitle + Avatar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  ShimmerBox(height: 26, width: 140, borderRadius: 8),
                  SizedBox(height: 6),
                  ShimmerBox(height: 14, width: 210, borderRadius: 6),
                ],
              ),
              const ShimmerBox(height: 48, width: 48, borderRadius: 24),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // 2. Mood Carousel Cards
          SizedBox(
            height: 86,
            child: Row(
              children: List.generate(
                4,
                (index) => Expanded(
                  child: Container(
                    margin: EdgeInsets.only(right: index < 3 ? 8 : 0),
                    child: const ShimmerBox(height: 86, borderRadius: 18),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // 3. Section Title + Category Chips
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              ShimmerBox(height: 22, width: 120, borderRadius: 6),
              ShimmerBox(height: 18, width: 24, borderRadius: 6),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: const [
              ShimmerBox(height: 36, width: 50, borderRadius: 18),
              SizedBox(width: 8),
              ShimmerBox(height: 36, width: 100, borderRadius: 18),
              SizedBox(width: 8),
              ShimmerBox(height: 36, width: 90, borderRadius: 18),
              SizedBox(width: 8),
              Expanded(child: ShimmerBox(height: 36, borderRadius: 18)),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // 4. Full-width Recipe Cards
          const RecipeHorizontalCardSkeleton(),
          const RecipeHorizontalCardSkeleton(),
          const RecipeHorizontalCardSkeleton(),
        ],
      ),
    );
  }
}

class RecipeListSkeleton extends StatelessWidget {
  final int count;

  const RecipeListSkeleton({super.key, this.count = 3});

  @override
  Widget build(BuildContext context) {
    return LoadingShimmer(
      child: Column(
        children: List.generate(
          count,
          (index) => const RecipeHorizontalCardSkeleton(),
        ),
      ),
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
        separatorBuilder: (context, index) =>
            const SizedBox(height: AppSpacing.md),
        itemBuilder: (context, index) => Row(
          children: [
            const ShimmerBox(
              height: 56,
              width: 56,
              borderRadius: AppSpacing.radiusMd,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  ShimmerBox(height: 16, width: 140),
                  SizedBox(height: 8),
                  ShimmerBox(height: 12, width: 200),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
