import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../domain/entities/remote_config_entity.dart';

/// Non-bypassable Force Update Modal Dialog (§20, §74).
class ForceUpdateDialog extends StatelessWidget {
  final RemoteConfigEntity config;

  const ForceUpdateDialog({super.key, required this.config});

  static void show(BuildContext context, RemoteConfigEntity config) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) =>
          PopScope(canPop: false, child: ForceUpdateDialog(config: config)),
    );
  }

  void _launchStore() {
    HapticFeedback.selectionClick();
    final url = Platform.isIOS ? config.iosStoreUrl : config.androidStoreUrl;
    debugPrint('[ForceUpdate] Redirecting to store URL: $url');
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
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF2C2614), const Color(0xFF382E18)]
                      : [const Color(0xFFFFFBEB), const Color(0xFFFEF3C7)],
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? AppColors.butterGold : AppColors.primaryGold,
                  width: 2,
                ),
              ),
              child: const Center(
                child: Text('🚀', style: TextStyle(fontSize: 34)),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            Text(
              'Update Required',
              textAlign: TextAlign.center,
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            Text(
              config.updateMessage,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.35,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            AppButton(label: 'Update Now ✨', onPressed: _launchStore),
          ],
        ),
      ),
    );
  }
}
