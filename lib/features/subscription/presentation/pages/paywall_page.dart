import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../bloc/subscription_cubit.dart';
import '../bloc/subscription_state.dart';

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
          context.pop();
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
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    state.monthlyPrice,
                                    style: textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
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
                        const SizedBox(width: AppSpacing.sm),

                        // Yearly Option
                        Expanded(
                          child: InkWell(
                            onTap: () =>
                                setState(() => _isYearlySelected = true),
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusLg,
                            ),
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                AppCard(
                                  borderColor: _isYearlySelected
                                      ? scheme.primary
                                      : null,
                                  backgroundColor: _isYearlySelected
                                      ? scheme.primaryContainer.withValues(
                                          alpha: 0.25,
                                        )
                                      : null,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Yearly',
                                        style: textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        state.yearlyPrice,
                                        style: textTheme.bodyLarge?.copyWith(
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '\$3.33 / mo (Save 33%)',
                                        style: textTheme.bodySmall?.copyWith(
                                          color: AppColors.sage,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Positioned(
                                  top: -10,
                                  right: 12,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? AppColors.butterGold
                                          : AppColors.primaryGold,
                                      borderRadius: BorderRadius.circular(
                                        AppSpacing.radiusPill,
                                      ),
                                    ),
                                    child: const Text(
                                      'BEST VALUE',
                                      style: TextStyle(
                                        color: Color(0xFF141414),
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
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Primary CTA
                    AppButton(
                      label: _isYearlySelected
                          ? 'Start 7-Day Free Trial ✨'
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
                          child: const Text('Judge / Promo Code'),
                        ),
                      ],
                    ),

                    // Legal Footnote
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.sm),
                      child: Text(
                        'Recurring billing. Cancel anytime in App Store / Google Play settings at least 24 hours before renewal.',
                        textAlign: TextAlign.center,
                        style: textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant.withValues(alpha: 0.8),
                          fontSize: 11,
                        ),
                      ),
                    ),
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

  Widget _buildFeatureRow(BuildContext context, String text) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_rounded,
            color: AppColors.sage,
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
        ],
      ),
    );
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
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
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
          const SizedBox(height: AppSpacing.md),

          // Quick 1-Tap Preset Chips for Judges
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => _submit('SHIPATON2026'),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF2C2614)
                          : const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark
                            ? AppColors.butterGold
                            : AppColors.primaryGold,
                        width: 1.2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '🎟️ SHIPATON2026',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: isDark
                              ? AppColors.butterGold
                              : AppColors.primaryGoldDark,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: InkWell(
                  onTap: () => _submit('JUDGE_ACCESS'),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF282828)
                          : const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF444444)
                            : const Color(0xFFD1D5DB),
                        width: 1.2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '⚖️ JUDGE_ACCESS',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: scheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          AppTextField(
            label: 'Promo / Judge Code',
            controller: _controller,
            focusNode: _focusNode,
            prefixIcon: Icons.card_giftcard_rounded,
            onSubmitted: _submit,
          ),
          const SizedBox(height: AppSpacing.lg),

          AppButton(
            label: 'Unlock Premium ✨',
            backgroundColor: isDark
                ? AppColors.butterGold
                : AppColors.primaryGold,
            foregroundColor: const Color(0xFF141414),
            onPressed: () => _submit(_controller.text),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }
}
