import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../domain/entities/remote_config_entity.dart';

/// Non-blocking Soft Update Notification Dialog (§21).
class SoftUpdateDialog extends StatelessWidget {
  final RemoteConfigEntity config;
  final VoidCallback onDismiss;

  const SoftUpdateDialog({
    super.key,
    required this.config,
    required this.onDismiss,
  });

  static void show({
    required BuildContext context,
    required RemoteConfigEntity config,
    required VoidCallback onDismiss,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => SoftUpdateDialog(
        config: config,
        onDismiss: () {
          Navigator.of(ctx).pop();
          onDismiss();
        },
      ),
    );
  }

  void _launchStore() {
    HapticFeedback.selectionClick();
    final url = Platform.isIOS ? config.iosStoreUrl : config.androidStoreUrl;
    debugPrint('[SoftUpdate] Redirecting to store: $url');
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF2C2614)
                    : const Color(0xFFFEF3C7),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? AppColors.butterGold : AppColors.primaryGold,
                ),
              ),
              child: const Center(
                child: Text('✨', style: TextStyle(fontSize: 30)),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            Text(
              'New Version Available!',
              textAlign: TextAlign.center,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),

            Text(
              'An updated version (${config.latestVersion}) of AnuMealAI is ready with fresh improvements.',
              textAlign: TextAlign.center,
              style: textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.35,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            AppButton(label: 'Update Now', onPressed: _launchStore),
            const SizedBox(height: AppSpacing.sm),

            TextButton(
              onPressed: onDismiss,
              child: Text(
                'Maybe Later',
                style: TextStyle(
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
