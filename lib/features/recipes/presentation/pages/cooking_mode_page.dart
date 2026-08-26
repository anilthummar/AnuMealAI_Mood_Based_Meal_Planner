import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../profile/presentation/bloc/profile_cubit.dart';
import '../../domain/entities/recipe.dart';
import '../bloc/recipe_cubit.dart';

class CookingModePage extends StatefulWidget {
  final String recipeId;
  final Recipe recipe;

  const CookingModePage({
    super.key,
    required this.recipeId,
    required this.recipe,
  });

  @override
  State<CookingModePage> createState() => _CookingModePageState();
}

class _CookingModePageState extends State<CookingModePage> {
  int _currentStepIndex = 0;
  Timer? _timer;
  int _timerSecondsRemaining = 0;
  bool _isTimerRunning = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer(int seconds) {
    _timer?.cancel();
    setState(() {
      _timerSecondsRemaining = seconds;
      _isTimerRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_timerSecondsRemaining <= 1) {
        t.cancel();
        setState(() {
          _timerSecondsRemaining = 0;
          _isTimerRunning = false;
        });
        AppSnackbar.show(
          context,
          message: '⏰ Timer finished for step ${_currentStepIndex + 1}!',
          variant: SnackbarVariant.success,
        );
      } else {
        setState(() {
          _timerSecondsRemaining--;
        });
      }
    });
  }

  void _pauseResumeTimer() {
    if (_isTimerRunning) {
      _timer?.cancel();
      setState(() => _isTimerRunning = false);
    } else if (_timerSecondsRemaining > 0) {
      _startTimer(_timerSecondsRemaining);
    }
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _timerSecondsRemaining = 0;
      _isTimerRunning = false;
    });
  }

  String _formatTimer(int totalSeconds) {
    final m = totalSeconds ~/ 60;
    final s = totalSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void _completeCooking() {
    context.read<RecipeCubit>().markRecipeCooked(widget.recipe.id);
    context.read<ProfileCubit>().recordMealCooked();

    _showRatingDialog();
  }

  void _showRatingDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Celebration Hero Badge
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [const Color(0xFF2C2614), const Color(0xFF382E18)]
                        : [const Color(0xFFFFFBEB), const Color(0xFFFEF3C7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark
                        ? AppColors.butterGold
                        : AppColors.primaryGold,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color:
                          (isDark
                                  ? AppColors.butterGold
                                  : AppColors.primaryGold)
                              .withValues(alpha: 0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text('🎉', style: TextStyle(fontSize: 28)),
                ),
              ),
              const SizedBox(height: 14),

              // Title
              Text(
                'How was your meal?',
                textAlign: TextAlign.center,
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 6),

              // Recipe Title Tag
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF282828)
                      : scheme.surfaceContainerHighest.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  widget.recipe.title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.butterGold
                        : AppColors.primaryGoldDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 10),

              // Friendly explanation
              Text(
                'Your feedback trains AnuMealAI to learn your taste preferences and refine future recommendations.',
                textAlign: TextAlign.center,
                style: textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 16),

              // 4 Polished Rating Option Cards
              _buildRatingOptionCard(
                ctx: ctx,
                emoji: '❤️',
                title: 'Loved it!',
                subtitle: 'Super delicious, recommend often',
                ratingKey: 'loved',
                accentColor: AppColors.terracotta,
                isDark: isDark,
              ),
              const SizedBox(height: 8),
              _buildRatingOptionCard(
                ctx: ctx,
                emoji: '😋',
                title: 'Tasty & Good',
                subtitle: 'Enjoyed it, great staple meal',
                ratingKey: 'good',
                accentColor: isDark
                    ? AppColors.butterGold
                    : AppColors.primaryGoldDark,
                isDark: isDark,
              ),
              const SizedBox(height: 8),
              _buildRatingOptionCard(
                ctx: ctx,
                emoji: '😐',
                title: 'It was Okay',
                subtitle: 'Decent, but needs tweaks',
                ratingKey: 'okay',
                accentColor: scheme.onSurfaceVariant,
                isDark: isDark,
              ),
              const SizedBox(height: 8),
              _buildRatingOptionCard(
                ctx: ctx,
                emoji: '👎',
                title: 'Not for me',
                subtitle: 'Skip similar meals in future',
                ratingKey: 'not_for_me',
                accentColor: scheme.error,
                isDark: isDark,
              ),
              const SizedBox(height: 12),

              // Skip Action
              TextButton(
                onPressed: () {
                  HapticFeedback.selectionClick();
                  Navigator.pop(ctx);
                  context.pop();
                  AppSnackbar.show(
                    context,
                    message: '🎉 Meal recorded! Cooking streak updated.',
                    variant: SnackbarVariant.success,
                  );
                },
                child: Text(
                  'Skip for now',
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRatingOptionCard({
    required BuildContext ctx,
    required String emoji,
    required String title,
    required String subtitle,
    required String ratingKey,
    required Color accentColor,
    required bool isDark,
  }) {
    final scheme = Theme.of(ctx).colorScheme;

    return Material(
      color: isDark ? const Color(0xFF262626) : const Color(0xFFFAF9F6),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () {
          HapticFeedback.mediumImpact();
          context.read<RecipeCubit>().rateRecipe(widget.recipe.id, ratingKey);
          Navigator.pop(ctx);
          context.pop();
          AppSnackbar.show(
            context,
            message: '🎉 Meal recorded! Cooking streak updated.',
            variant: SnackbarVariant.success,
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? const Color(0xFF383838) : const Color(0xFFEBE6DD),
              width: 1.2,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF333333) : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF444444)
                        : const Color(0xFFEDE8DF),
                  ),
                ),
                child: Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 18)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: scheme.onSurface,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: scheme.onSurfaceVariant,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: scheme.onSurfaceVariant.withValues(alpha: 0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final instructions = widget.recipe.instructions;
    final totalSteps = instructions.length;
    final currentInstruction = instructions[_currentStepIndex];

    final hasTimerInStep =
        currentInstruction.toLowerCase().contains('min') ||
        currentInstruction.toLowerCase().contains('minute');

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recipe.title),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          tooltip: 'Exit Cooking Mode',
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: _completeCooking,
            child: const Text(
              'Finish',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress Bar
            LinearProgressIndicator(
              value: (totalSteps > 0)
                  ? (_currentStepIndex + 1) / totalSteps
                  : 1.0,
              minHeight: 6,
              backgroundColor: scheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(scheme.primary),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Step Counter
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: scheme.primaryContainer,
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusPill,
                        ),
                      ),
                      child: Text(
                        'STEP ${_currentStepIndex + 1} OF $totalSteps',
                        style: textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                          color: scheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Instruction Card
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (hasTimerInStep) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: scheme.primaryContainer,
                                borderRadius: BorderRadius.circular(
                                  AppSpacing.radiusPill,
                                ),
                              ),
                              child: Text(
                                '⏱️ Timer step',
                                style: textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: scheme.onPrimaryContainer,
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                          ],
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.sm,
                            ),
                            child: Text(
                              currentInstruction,
                              style: textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Timer Card
                    AppCard(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.timer_outlined,
                                    color: scheme.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Step Timer',
                                    style: textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                _formatTimer(_timerSecondsRemaining),
                                style: textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: _isTimerRunning
                                      ? AppColors.terracotta
                                      : scheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () =>
                                      _startTimer(300), // 5 min default
                                  child: const Text('5 min'),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => _startTimer(600), // 10 min
                                  child: const Text('10 min'),
                                ),
                              ),
                              const SizedBox(width: 6),
                              if (_timerSecondsRemaining > 0) ...[
                                IconButton(
                                  icon: Icon(
                                    _isTimerRunning
                                        ? Icons.pause_rounded
                                        : Icons.play_arrow_rounded,
                                  ),
                                  color: scheme.primary,
                                  onPressed: _pauseResumeTimer,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.stop_rounded),
                                  color: scheme.error,
                                  onPressed: _resetTimer,
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Navigation
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: scheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  if (_currentStepIndex > 0) ...[
                    Expanded(
                      flex: 2,
                      child: AppButton(
                        label: 'Back',
                        variant: AppButtonVariant.outlined,
                        icon: Icons.chevron_left_rounded,
                        onPressed: () {
                          setState(() {
                            _currentStepIndex--;
                            _resetTimer();
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  Expanded(
                    flex: 3,
                    child: AppButton(
                      label: _currentStepIndex < totalSteps - 1
                          ? 'Next Step ➔'
                          : 'Complete Meal 🎉',
                      icon: _currentStepIndex == totalSteps - 1
                          ? Icons.check_circle_rounded
                          : null,
                      onPressed: () {
                        if (_currentStepIndex < totalSteps - 1) {
                          setState(() {
                            _currentStepIndex++;
                            _resetTimer();
                          });
                        } else {
                          _completeCooking();
                        }
                      },
                    ),
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
