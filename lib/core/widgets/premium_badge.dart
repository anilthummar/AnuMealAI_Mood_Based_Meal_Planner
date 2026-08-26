import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Reusable premium badge with sparkling golden style (§25).
class PremiumBadge extends StatelessWidget {
  final String text;
  final double fontSize;
  final bool compact;

  const PremiumBadge({
    super.key,
    this.text = 'PREMIUM',
    this.fontSize = 10,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : AppSpacing.sm,
        vertical: compact ? 2 : 4,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.golden, AppColors.terracotta],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        boxShadow: [
          BoxShadow(
            color: AppColors.golden.withValues(alpha: 0.35),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.auto_awesome,
            color: Colors.white,
            size: fontSize + 2,
          ),
          if (!compact) ...[
            const SizedBox(width: 4),
            Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: fontSize,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
