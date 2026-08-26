import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

enum SnackbarVariant { success, error, info }

/// Reusable snackbar helper with themed variants (§25).
class AppSnackbar {
  AppSnackbar._();

  static void show(
    BuildContext context, {
    required String message,
    SnackbarVariant variant = SnackbarVariant.info,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 3),
  }) {
    final messenger = ScaffoldMessenger.of(context);
    final scheme = Theme.of(context).colorScheme;

    final (bg, fg, icon) = switch (variant) {
      SnackbarVariant.success => (
          const Color(0xFF2E7D32),
          Colors.white,
          Icons.check_circle_outline_rounded
        ),
      SnackbarVariant.error => (
          scheme.error,
          scheme.onError,
          Icons.error_outline_rounded
        ),
      SnackbarVariant.info => (
          scheme.inverseSurface,
          scheme.onInverseSurface,
          Icons.info_outline_rounded
        ),
    };

    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        duration: duration,
        backgroundColor: bg,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        content: Row(
          children: [
            Icon(icon, color: fg, size: 20),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: fg, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        action: actionLabel != null && onAction != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: fg,
                onPressed: onAction,
              )
            : null,
      ),
    );
  }
}
