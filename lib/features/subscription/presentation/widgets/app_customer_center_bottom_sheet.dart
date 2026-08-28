import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_config.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/utils/subscription_error_mapper.dart';
import '../bloc/subscription_cubit.dart';
import '../bloc/subscription_state.dart';

/// Shows the custom on-theme Customer Center bottom sheet for AnuMealAI.
void showAppCustomerCenter(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (modalCtx) => BlocProvider.value(
      value: context.read<SubscriptionCubit>(),
      child: const AppCustomerCenterBottomSheet(),
    ),
  );
}

class AppCustomerCenterBottomSheet extends StatelessWidget {
  const AppCustomerCenterBottomSheet({super.key});

  Future<void> _openUrl(BuildContext context, String urlString) async {
    final uri = Uri.parse(urlString);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Could not open $urlString')));
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error opening link: $e')));
      }
    }
  }

  void _manageStoreSubscriptions(BuildContext context) {
    if (Platform.isAndroid) {
      _openUrl(context, 'https://play.google.com/store/account/subscriptions');
    } else if (Platform.isIOS) {
      _openUrl(context, 'https://apps.apple.com/account/subscriptions');
    } else {
      _openUrl(context, 'https://play.google.com/store/account/subscriptions');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return BlocConsumer<SubscriptionCubit, SubscriptionState>(
      listener: (context, state) {
        if (state.errorMessage != null &&
            state.errorMessage!.trim().isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.errorMessage == SubscriptionErrorMapper.storePendingCode
                    ? 'Google Play is currently reviewing billing for this version. You can unlock features with the Promo Pass.'
                    : state.errorMessage!,
              ),
              backgroundColor: const Color(0xFFD97706),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        final isPremium = state.subscription.isPremium;
        final isPromo =
            state.subscription.activeOfferingId == 'shipaton_judge_trial';

        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.1),
                blurRadius: 24,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Drag Handle
                  Center(
                    child: Container(
                      width: 44,
                      height: 4.5,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: scheme.outlineVariant.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),

                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.butterGold.withValues(alpha: 0.15)
                              : AppColors.amberContainer,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.manage_accounts_rounded,
                          color: isDark
                              ? AppColors.butterGold
                              : AppColors.primaryGoldDark,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Subscription & Account',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              'Manage your AnuMealAI Pro plan & purchases',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded),
                        style: IconButton.styleFrom(
                          backgroundColor: scheme.surfaceContainerHighest
                              .withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Current Tier Status Card
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isPremium
                            ? (isDark
                                  ? [
                                      const Color(0xFF2C2614),
                                      const Color(0xFF1E1A0E),
                                    ]
                                  : [
                                      AppColors.amberContainer,
                                      const Color(0xFFFDE68A),
                                    ])
                            : (isDark
                                  ? [
                                      AppColors.darkSurfaceContainer,
                                      AppColors.darkSurfaceVariant,
                                    ]
                                  : [
                                      AppColors.lightSurfaceContainer,
                                      AppColors.lightSurfaceContainerHighest,
                                    ]),
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isPremium
                            ? (isDark
                                  ? AppColors.butterGold.withValues(alpha: 0.4)
                                  : AppColors.primaryGold.withValues(
                                      alpha: 0.3,
                                    ))
                            : scheme.outlineVariant.withValues(alpha: 0.6),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isPremium
                                    ? (isDark
                                          ? AppColors.butterGold
                                          : AppColors.primaryGold)
                                    : scheme.outline.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isPremium
                                        ? Icons.stars_rounded
                                        : Icons.person_outline_rounded,
                                    size: 14,
                                    color: isPremium
                                        ? const Color(0xFF141414)
                                        : scheme.onSurface,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    isPremium
                                        ? (isPromo
                                              ? 'PRO (PROMO PASS)'
                                              : 'PRO ACTIVE')
                                        : 'FREE TIER',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 11,
                                      color: isPremium
                                          ? const Color(0xFF141414)
                                          : scheme.onSurface,
                                      letterSpacing: 0.6,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            if (isPremium)
                              const Icon(
                                Icons.verified_rounded,
                                color: AppColors.success,
                                size: 20,
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          isPremium
                              ? 'AnuMealAI Pro Membership'
                              : 'Free Starter Plan',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: isPremium && !isDark
                                ? AppColors.onAmberContainer
                                : scheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isPremium
                              ? 'Enjoy unlimited AI recipe generations, weekly meal plans, and mood recommendations.'
                              : 'Limited to 3 AI recipe generations/day and 1 weekly meal plan.',
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.35,
                            color: isPremium && !isDark
                                ? AppColors.onAmberContainer.withValues(
                                    alpha: 0.85,
                                  )
                                : scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // If Free tier: Upgrade CTA Button
                  if (!isPremium) ...[
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        context.push(AppRoutes.paywall);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark
                            ? AppColors.butterGold
                            : AppColors.primaryGold,
                        foregroundColor: const Color(0xFF141414),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 2,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.workspace_premium_rounded, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Upgrade to AnuMealAI Pro',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],

                  // Action: Restore Purchases
                  _CustomerCenterActionTile(
                    icon: Icons.restore_rounded,
                    iconColor: isDark
                        ? AppColors.butterGold
                        : AppColors.primaryGoldDark,
                    title: 'Restore Past Purchases',
                    subtitle:
                        'Check Google Play or App Store for previous subscriptions',
                    isLoading: state.isRestoring,
                    onTap: state.isRestoring
                        ? null
                        : () => context
                              .read<SubscriptionCubit>()
                              .restorePurchases(),
                  ),
                  const SizedBox(height: 10),

                  // Action: Manage on Google Play / App Store
                  _CustomerCenterActionTile(
                    icon: Icons.storefront_rounded,
                    iconColor: AppColors.sage,
                    title: Platform.isIOS
                        ? 'Manage in App Store'
                        : 'Manage on Google Play',
                    subtitle:
                        'Cancel, change payment method, or view billing history',
                    onTap: () => _manageStoreSubscriptions(context),
                  ),
                  const SizedBox(height: 10),

                  // Action: Native Store Customer Center
                  _CustomerCenterActionTile(
                    icon: Icons.receipt_long_rounded,
                    iconColor: AppColors.terracotta,
                    title: 'Store Billing Inquiries',
                    subtitle:
                        'Request refund or contact store customer support',
                    onTap: () => context
                        .read<SubscriptionCubit>()
                        .presentCustomerCenter(),
                  ),
                  const SizedBox(height: 10),

                  // If Promo active: Reset to free tier to test store billing
                  if (isPromo) ...[
                    _CustomerCenterActionTile(
                      icon: Icons.restart_alt_rounded,
                      iconColor: isDark
                          ? AppColors.butterGold
                          : AppColors.primaryGoldDark,
                      title: 'Reset to Free Starter Plan',
                      subtitle:
                          'Deactivate promo pass to test Google Play purchase checkout',
                      onTap: () {
                        context.read<SubscriptionCubit>().resetToFreeTier();
                        Navigator.of(context).pop();
                      },
                    ),
                    const SizedBox(height: 10),
                  ],
                  const SizedBox(height: 8),

                  // Legal Links Footer
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () =>
                            _openUrl(context, AppConfig.privacyPolicyUrl),
                        style: TextButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          foregroundColor: scheme.onSurfaceVariant,
                        ),
                        child: const Text(
                          'Privacy Policy',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                      Text('•', style: TextStyle(color: scheme.outline)),
                      TextButton(
                        onPressed: () =>
                            _openUrl(context, AppConfig.termsOfUseUrl),
                        style: TextButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          foregroundColor: scheme.onSurfaceVariant,
                        ),
                        child: const Text(
                          'Terms of Use',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CustomerCenterActionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool isLoading;

  const _CustomerCenterActionTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: isDark
          ? AppColors.darkSurfaceContainer
          : AppColors.lightSurfaceContainer,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: isDark ? 0.2 : 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
              if (isLoading)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                Icon(
                  Icons.chevron_right_rounded,
                  color: scheme.onSurfaceVariant.withValues(alpha: 0.6),
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
