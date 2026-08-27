import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/url_launcher_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../bloc/subscription_cubit.dart';
import '../bloc/subscription_state.dart';
import '../widgets/app_customer_center_bottom_sheet.dart';

class PaywallPage extends StatefulWidget {
  const PaywallPage({super.key});

  @override
  State<PaywallPage> createState() => _PaywallPageState();
}

class _PaywallPageState extends State<PaywallPage> {
  bool _isYearlySelected = true;

  void _showPromoCodeDialog(BuildContext context) {
    AppBottomSheet.show(
      context: context,
      builder: (ctx) => _JudgePromoBottomSheet(
        onRedeem: (code) {
          context.read<SubscriptionCubit>().redeemPromoOrTrial(code);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocConsumer<SubscriptionCubit, SubscriptionState>(
      listener: (context, state) {
        if (state.successMessage != null) {
          AppSnackbar.show(
            context,
            message: state.successMessage!,
            variant: SnackbarVariant.success,
          );
          context.read<SubscriptionCubit>().clearMessages();
        }
        if (state.errorMessage != null) {
          AppSnackbar.show(
            context,
            message: state.errorMessage!,
            variant: SnackbarVariant.error,
          );
          context.read<SubscriptionCubit>().clearMessages();
        }
      },
      builder: (context, state) {
        final cubit = context.read<SubscriptionCubit>();
        final isPremium = state.isPremium;
        final isPromoActive =
            state.subscription.activeOfferingId == 'shipaton_judge_trial';

        return Scaffold(
          body: SafeArea(
            child: Stack(
              children: [
                // Scrollable Content
                ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.xl,
                    AppSpacing.lg,
                    AppSpacing.xxl + AppSpacing.xl,
                  ),
                  children: [
                    const SizedBox(height: AppSpacing.md),

                    if (isPremium) ...[
                      // ============================================
                      // 👑 PREVIEW: ACTIVE PREMIUM CELEBRATION VIEW
                      // ============================================
                      Center(
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.golden, AppColors.terracotta],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.golden.withValues(alpha: 0.35),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text('👑', style: TextStyle(fontSize: 40)),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      Text(
                        "You're an AnuMealAI Pro!",
                        textAlign: TextAlign.center,
                        style: textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),

                      Text(
                        "All AI culinary intelligence, 7-day meal planner, and smart pantry features are completely unlocked.",
                        textAlign: TextAlign.center,
                        style: textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // Status Badge Card
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF262015)
                              : const Color(0xFFFEF9EE),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: isDark
                                ? AppColors.butterGold.withValues(alpha: 0.8)
                                : AppColors.primaryGold,
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryGold.withValues(
                                alpha: isDark ? 0.2 : 0.1,
                              ),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Text(
                                      '⭐',
                                      style: TextStyle(fontSize: 18),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Membership Status',
                                      style: textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: -0.2,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: isPromoActive
                                          ? [
                                              AppColors.golden,
                                              AppColors.terracotta,
                                            ]
                                          : [
                                              const Color(0xFF2E7D32),
                                              const Color(0xFF1B5E20),
                                            ],
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      AppSpacing.radiusPill,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            (isPromoActive
                                                    ? AppColors.golden
                                                    : const Color(0xFF2E7D32))
                                                .withValues(alpha: 0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    isPromoActive ? 'PROMO PASS ✨' : 'ACTIVE ✨',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (isPromoActive) ...[
                              const SizedBox(height: AppSpacing.sm),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.golden.withValues(
                                    alpha: 0.12,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.golden.withValues(
                                      alpha: 0.25,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Text(
                                      '🎁',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Active via Promo Pass: Unlimited AI, meal plans & full features enabled.',
                                        style: textTheme.bodySmall?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 11.5,
                                          color: isDark
                                              ? AppColors.butterGold
                                              : AppColors.primaryGoldDark,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            const SizedBox(height: AppSpacing.sm),
                            const Divider(),
                            const SizedBox(height: AppSpacing.sm),
                            _buildFeatureRow(
                              context,
                              'Unlimited AI meal recommendations',
                              unlocked: true,
                            ),
                            _buildFeatureRow(
                              context,
                              'Full 7-day personalized weekly meal planner',
                              unlocked: true,
                            ),
                            _buildFeatureRow(
                              context,
                              'Deep mood & pantry ingredient optimization',
                              unlocked: true,
                            ),
                            _buildFeatureRow(
                              context,
                              'Chef cooking mode with smart timers',
                              unlocked: true,
                            ),
                            _buildFeatureRow(
                              context,
                              'Smart waste reduction & grocery sync',
                              unlocked: true,
                            ),
                            _buildFeatureRow(
                              context,
                              'Unlimited saved recipes & taste learning',
                              unlocked: true,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      AppButton(
                        label: 'Return to Kitchen 🍳',
                        onPressed: () => context.pop(),
                      ),
                      const SizedBox(height: AppSpacing.sm),

                      Center(
                        child: TextButton.icon(
                          icon: const Icon(
                            Icons.manage_accounts_outlined,
                            size: 16,
                          ),
                          label: const Text(
                            'Manage Subscription (Customer Center)',
                          ),
                          onPressed: () =>
                              _handleCustomerCenter(context, state),
                        ),
                      ),
                      Center(
                        child: TextButton.icon(
                          icon: const Icon(
                            Icons.confirmation_num_outlined,
                            size: 16,
                          ),
                          label: const Text('Judge / Promo Code Settings'),
                          onPressed: () => _showPromoCodeDialog(context),
                        ),
                      ),
                    ] else ...[
                      // ============================================
                      // ⚡ PREVIEW: UPGRADE / PURCHASE VIEW
                      // ============================================
                      // Header badge
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.golden, AppColors.terracotta],
                            ),
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusPill,
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.auto_awesome,
                                color: Colors.white,
                                size: 16,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'ANUMEALAI PREMIUM',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                  letterSpacing: 1.1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Headline
                      Text(
                        "Turn ingredients into meals you'll actually want to cook.",
                        textAlign: TextAlign.center,
                        style: textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // Value Propositions
                      AppCard(
                        child: Column(
                          children: [
                            _buildFeatureRow(
                              context,
                              'Unlimited AI meal recommendations',
                            ),
                            _buildFeatureRow(
                              context,
                              'Full 7-day personalized weekly meal planner',
                            ),
                            _buildFeatureRow(
                              context,
                              'Deep mood & pantry ingredient optimization',
                            ),
                            _buildFeatureRow(
                              context,
                              'Chef cooking mode with smart timers',
                            ),
                            _buildFeatureRow(
                              context,
                              'Smart waste reduction & instant grocery list',
                            ),
                            _buildFeatureRow(
                              context,
                              'Unlimited saved recipes & full taste learning',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // Plans Selector
                      Row(
                        children: [
                          // Monthly Option
                          Expanded(
                            child: InkWell(
                              onTap: () =>
                                  setState(() => _isYearlySelected = false),
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusLg,
                              ),
                              child: AppCard(
                                borderColor: !_isYearlySelected
                                    ? scheme.primary
                                    : null,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Monthly',
                                      style: textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '\$4.99 / month',
                                      style: textTheme.bodyLarge?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: scheme.primary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Billed monthly',
                                      style: textTheme.bodySmall?.copyWith(
                                        color: scheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),

                          // Yearly Option
                          Expanded(
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                InkWell(
                                  onTap: () =>
                                      setState(() => _isYearlySelected = true),
                                  borderRadius: BorderRadius.circular(
                                    AppSpacing.radiusLg,
                                  ),
                                  child: AppCard(
                                    borderColor: _isYearlySelected
                                        ? scheme.primary
                                        : null,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Yearly',
                                          style: textTheme.titleMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w800,
                                              ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '\$39.99 / year',
                                          style: textTheme.bodyLarge?.copyWith(
                                            fontWeight: FontWeight.w700,
                                            color: scheme.primary,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '\$3.33 / mo (Save 33%)',
                                          style: textTheme.bodySmall?.copyWith(
                                            color: AppColors.sage,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: -10,
                                  right: 12,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.terracotta,
                                      borderRadius: BorderRadius.circular(
                                        AppSpacing.radiusPill,
                                      ),
                                    ),
                                    child: const Text(
                                      'BEST VALUE',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // CTA Button
                      AppButton(
                        label: _isYearlySelected
                            ? 'Unlock Yearly Access'
                            : 'Unlock Monthly Access',
                        isLoading: state.isPurchasing,
                        onPressed: () {
                          if (_isYearlySelected) {
                            cubit.purchaseYearly();
                          } else {
                            cubit.purchaseMonthly();
                          }
                        },
                      ),
                      const SizedBox(height: AppSpacing.sm),

                      // Restore & Promo Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: state.isRestoring
                                ? null
                                : () => cubit.restorePurchases(),
                            child: Text(
                              state.isRestoring
                                  ? 'Restoring...'
                                  : 'Restore Purchases',
                              style: TextStyle(color: scheme.onSurfaceVariant),
                            ),
                          ),
                          Text(
                            '•',
                            style: TextStyle(color: scheme.onSurfaceVariant),
                          ),
                          TextButton(
                            onPressed: () => _showPromoCodeDialog(context),
                            child: const Text(
                              'Judge / Promo Code',
                              style: TextStyle(
                                color: AppColors.primaryGoldDark,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Legal Footnote & Links
                      Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.sm),
                        child: Column(
                          children: [
                            Text(
                              'Recurring billing. Cancel anytime in App Store / Google Play settings at least 24 hours before renewal.',
                              textAlign: TextAlign.center,
                              style: textTheme.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant.withValues(
                                  alpha: 0.8,
                                ),
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                InkWell(
                                  onTap: () =>
                                      UrlLauncherService.openTermsOfUse(),
                                  child: Text(
                                    'Terms of Use',
                                    style: textTheme.bodySmall?.copyWith(
                                      color: scheme.primary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 11,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                                Text(
                                  '  •  ',
                                  style: textTheme.bodySmall?.copyWith(
                                    color: scheme.onSurfaceVariant,
                                    fontSize: 11,
                                  ),
                                ),
                                InkWell(
                                  onTap: () =>
                                      UrlLauncherService.openPrivacyPolicy(),
                                  child: Text(
                                    'Privacy Policy',
                                    style: textTheme.bodySmall?.copyWith(
                                      color: scheme.primary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 11,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),

                // Close Button
                Positioned(
                  top: AppSpacing.sm,
                  right: AppSpacing.md,
                  child: IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerHighest,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close_rounded, size: 20),
                    ),
                    onPressed: () => context.pop(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeatureRow(
    BuildContext context,
    String text, {
    bool unlocked = false,
  }) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_rounded,
            color: unlocked ? const Color(0xFF2E7D32) : AppColors.sage,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (unlocked)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'UNLOCKED',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF2E7D32),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _handleCustomerCenter(BuildContext context, SubscriptionState state) {
    showAppCustomerCenter(context);
  }
}

class _JudgePromoBottomSheet extends StatefulWidget {
  final ValueChanged<String> onRedeem;

  const _JudgePromoBottomSheet({required this.onRedeem});

  @override
  State<_JudgePromoBottomSheet> createState() => _JudgePromoBottomSheetState();
}

class _JudgePromoBottomSheetState extends State<_JudgePromoBottomSheet> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit(String code) {
    if (code.trim().isNotEmpty) {
      FocusManager.instance.primaryFocus?.unfocus();
      Navigator.of(context).pop();
      widget.onRedeem(code.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppBottomSheet(
      title: 'Redeem Shipaton Judge Code',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Tap a preset code below or enter your reviewer token to unlock full premium features.',
            textAlign: TextAlign.center,
            style: textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.35,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // 1-Tap Preset Judge Buttons (§21)
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark
                        ? const Color(0xFF2C2416)
                        : const Color(0xFFFEF3C7),
                    foregroundColor: isDark
                        ? AppColors.butterGold
                        : AppColors.primaryGoldDark,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color:
                            (isDark
                                    ? AppColors.butterGold
                                    : AppColors.primaryGold)
                                .withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                  onPressed: () => _submit('SHIPATON2026'),
                  child: const Column(
                    children: [
                      Text(
                        'SHIPATON2026',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                        ),
                      ),
                      Text('1-Tap Unlock 🚀', style: TextStyle(fontSize: 10)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark
                        ? const Color(0xFF242C20)
                        : const Color(0xFFE8F5E9),
                    foregroundColor: isDark
                        ? const Color(0xFF81C784)
                        : const Color(0xFF2E7D32),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: const Color(0xFF2E7D32).withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                  onPressed: () => _submit('JUDGE_ACCESS'),
                  child: const Column(
                    children: [
                      Text(
                        'JUDGE_ACCESS',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                        ),
                      ),
                      Text('Judge Pass 🏆', style: TextStyle(fontSize: 10)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Custom Input Field
          AppTextField(
            label: 'Enter Code manually',
            controller: _controller,
            textCapitalization: TextCapitalization.characters,
            prefixIcon: Icons.card_giftcard_rounded,
            onSubmitted: (val) => _submit(val),
          ),
          const SizedBox(height: AppSpacing.lg),

          AppButton(
            label: 'Redeem Code ✨',
            onPressed: () => _submit(_controller.text),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }
}
