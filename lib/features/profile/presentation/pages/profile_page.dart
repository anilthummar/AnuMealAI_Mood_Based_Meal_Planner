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
import '../../../../core/widgets/premium_badge.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../subscription/presentation/bloc/subscription_cubit.dart';
import '../../../subscription/presentation/bloc/subscription_state.dart';
import '../bloc/profile_cubit.dart';
import '../bloc/profile_state.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileCubit>().loadProfile();
  }

  void _showEditNameDialog(BuildContext context, String currentName) {
    final controller = TextEditingController(text: currentName);
    AppBottomSheet.show(
      context: context,
      builder: (ctx) => AppBottomSheet(
        title: 'Edit Display Name',
        child: Column(
          children: [
            AppTextField(
              label: 'Your Name',
              controller: controller,
              prefixIcon: Icons.person_outline_rounded,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: 'Save Name',
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  context.read<ProfileCubit>().updateName(
                    controller.text.trim(),
                  );
                  Navigator.pop(ctx);
                  AppSnackbar.show(
                    context,
                    message: 'Name updated! ✨',
                    variant: SnackbarVariant.success,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile & Preferences'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => context.push(AppRoutes.settings),
          ),
        ],
      ),
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          final prefs = state.preferences;
          final cubit = context.read<ProfileCubit>();
          final displayName = prefs.name.isNotEmpty ? prefs.name : 'Anu';

          return RefreshIndicator(
            onRefresh: () => cubit.loadProfile(),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.xs,
                AppSpacing.md,
                AppSpacing.xxl,
              ),
              children: [
                // User Header Profile Card
                AppCard(
                  child: Row(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.terracotta, AppColors.golden],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.terracotta.withValues(
                                alpha: 0.3,
                              ),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            displayName.isNotEmpty
                                ? displayName[0].toUpperCase()
                                : 'A',
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  displayName,
                                  style: textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit_outlined,
                                    size: 18,
                                  ),
                                  visualDensity: VisualDensity.compact,
                                  onPressed: () =>
                                      _showEditNameDialog(context, displayName),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: scheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(
                                      AppSpacing.radiusPill,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text(
                                        '🔥',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${state.cookingStreak} day streak',
                                        style: textTheme.labelSmall?.copyWith(
                                          color: isDark
                                              ? scheme.onPrimaryContainer
                                              : AppColors.onAmberContainer,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: scheme.surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(
                                      AppSpacing.radiusPill,
                                    ),
                                  ),
                                  child: Text(
                                    '🍳 ${state.mealsCooked} cooked',
                                    style: textTheme.labelSmall?.copyWith(
                                      color: scheme.onSurfaceVariant,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Subscription Status Card
                BlocBuilder<SubscriptionCubit, SubscriptionState>(
                  builder: (context, subState) {
                    final isPremium = subState.isPremium;

                    return InkWell(
                      onTap: () => context.push(AppRoutes.paywall),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          gradient: isPremium
                              ? const LinearGradient(
                                  colors: [
                                    Color(0xFF2C2416),
                                    Color(0xFF1E1911),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : LinearGradient(
                                  colors: [
                                    scheme.primaryContainer,
                                    scheme.primaryContainer.withValues(
                                      alpha: 0.7,
                                    ),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusLg,
                          ),
                          border: Border.all(
                            color: isPremium
                                ? AppColors.golden
                                : scheme.primary.withValues(alpha: 0.3),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isPremium
                                  ? AppColors.golden.withValues(alpha: 0.15)
                                  : scheme.primary.withValues(alpha: 0.1),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    AppColors.golden,
                                    AppColors.terracotta,
                                  ],
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.auto_awesome_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        isPremium
                                            ? 'AnuMealAI Premium'
                                            : 'Free Tier',
                                        style: TextStyle(
                                          color: isPremium
                                              ? Colors.white
                                              : scheme.onPrimaryContainer,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 16,
                                        ),
                                      ),
                                      if (isPremium) ...[
                                        const SizedBox(width: 8),
                                        const PremiumBadge(compact: true),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    isPremium
                                        ? 'Unlimited AI generations • 7-day planner • Chef Mode'
                                        : '3 recipes / day • Upgrade to unlock all features',
                                    style: TextStyle(
                                      color: isPremium
                                          ? Colors.white.withValues(alpha: 0.75)
                                          : scheme.onPrimaryContainer
                                                .withValues(alpha: 0.8),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.chevron_right_rounded,
                              color: isPremium
                                  ? AppColors.golden
                                  : scheme.primary,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.lg),

                // Dietary Restrictions
                SectionHeader(
                  title: 'Dietary Restrictions',
                  subtitle: 'Personalize recommendations to your diet',
                ),
                const SizedBox(height: AppSpacing.xs),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children:
                      [
                        'Vegetarian',
                        'Vegan',
                        'Keto',
                        'Pescatarian',
                        'Gluten-Free',
                        'Dairy-Free',
                        'Low-Carb',
                        'Nut-Free',
                      ].map((diet) {
                        final selected = prefs.dietaryRestrictions.contains(
                          diet,
                        );
                        return AppChip(
                          label: diet,
                          isSelected: selected,
                          onTap: () => cubit.toggleDietaryRestriction(diet),
                        );
                      }).toList(),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Favorite Cuisines
                SectionHeader(
                  title: 'Favorite Cuisines',
                  subtitle: 'Select culinary traditions you love',
                ),
                const SizedBox(height: AppSpacing.xs),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children:
                      [
                        'Italian 🍝',
                        'Mexican 🌮',
                        'Asian 🥢',
                        'Indian 🍛',
                        'Mediterranean 🫒',
                        'American 🍔',
                        'Japanese 🍱',
                        'Thai 🍲',
                        'Middle Eastern 🧆',
                        'French 🥐',
                      ].map((c) {
                        final pureName = c.split(' ').first;
                        final selected = prefs.favoriteCuisines.any(
                          (fav) => fav.toLowerCase().contains(
                            pureName.toLowerCase(),
                          ),
                        );
                        return AppChip(
                          label: c,
                          isSelected: selected,
                          onTap: () => cubit.toggleCuisine(pureName),
                        );
                      }).toList(),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Cooking Skill Level
                SectionHeader(
                  title: 'Cooking Skill Level',
                  subtitle: 'Tailors recipe complexity and step detail',
                ),
                const SizedBox(height: AppSpacing.xs),
                AppCard(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children:
                        [
                          {'name': 'Beginner', 'emoji': '🍳'},
                          {'name': 'Intermediate', 'emoji': '👨‍🍳'},
                          {'name': 'Advanced', 'emoji': '🌟'},
                        ].map((item) {
                          final name = item['name']!;
                          final emoji = item['emoji']!;
                          final isSelected =
                              prefs.cookingSkill.toLowerCase() ==
                              name.toLowerCase();

                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              child: InkWell(
                                onTap: () => cubit.setCookingSkill(name),
                                borderRadius: BorderRadius.circular(
                                  AppSpacing.radiusMd,
                                ),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? scheme.primary
                                        : scheme.surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(
                                      AppSpacing.radiusMd,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        emoji,
                                        style: const TextStyle(fontSize: 20),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        name,
                                        style: TextStyle(
                                          color: isSelected
                                              ? scheme.onPrimary
                                              : scheme.onSurface,
                                          fontWeight: isSelected
                                              ? FontWeight.w800
                                              : FontWeight.w500,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Typical Cooking Time
                SectionHeader(
                  title: 'Target Prep & Cook Time',
                  subtitle: 'How much time do you usually want to spend?',
                ),
                const SizedBox(height: AppSpacing.xs),
                AppCard(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [15, 30, 45, 60].map((minutes) {
                      final isSelected =
                          prefs.typicalCookingTimeMinutes == minutes;

                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: InkWell(
                            onTap: () => cubit.setCookingTime(minutes),
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusMd,
                            ),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.sage
                                    : scheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(
                                  AppSpacing.radiusMd,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    '${minutes}m',
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : scheme.onSurface,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    minutes <= 15
                                        ? 'Quick'
                                        : (minutes <= 30
                                              ? 'Medium'
                                              : 'Relaxed'),
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white.withValues(alpha: 0.8)
                                          : scheme.onSurfaceVariant,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          );
        },
      ),
    );
  }
}
