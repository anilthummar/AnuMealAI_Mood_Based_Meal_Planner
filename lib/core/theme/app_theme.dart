import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'app_spacing.dart';

/// Ultra-modern luxury culinary design system supporting seamless
/// high-end visual experiences in both Light (Gourmet Porcelain) and Dark (Obsidian Gold) modes.
class AppTheme {
  AppTheme._();

  static ThemeData get light => _build(_lightScheme);
  static ThemeData get dark => _build(_darkScheme);

  static const ColorScheme _lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primaryGold,
    onPrimary: Color(0xFF141414),
    primaryContainer: AppColors.amberContainer,
    onPrimaryContainer: AppColors.onAmberContainer,
    secondary: AppColors.sage,
    onSecondary: Colors.white,
    secondaryContainer: AppColors.sageLight,
    onSecondaryContainer: Color(0xFF1B3822),
    tertiary: AppColors.terracotta,
    onTertiary: Colors.white,
    surface: AppColors.lightBackground,
    onSurface: AppColors.charcoal,
    surfaceContainer: AppColors.lightSurfaceContainer,
    surfaceContainerHigh: AppColors.lightSurface,
    surfaceContainerHighest: AppColors.lightSurfaceContainerHighest,
    onSurfaceVariant: Color(0xFF6B665E),
    outline: AppColors.lightOutline,
    outlineVariant: AppColors.lightOutlineVariant,
    error: AppColors.error,
    onError: Colors.white,
  );

  static const ColorScheme _darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.butterGold,
    onPrimary: Color(0xFF121212),
    primaryContainer: Color(0xFF2C2614),
    onPrimaryContainer: AppColors.butterGold,
    secondary: Color(0xFF86B392),
    onSecondary: Color(0xFF121212),
    secondaryContainer: Color(0xFF1C2B1E),
    onSecondaryContainer: AppColors.sageLight,
    tertiary: AppColors.goldenFlame,
    onTertiary: Color(0xFF121212),
    surface: AppColors.darkBackground,
    onSurface: Colors.white,
    surfaceContainer: AppColors.darkSurface,
    surfaceContainerHigh: AppColors.darkSurfaceContainer,
    surfaceContainerHighest: AppColors.darkSurfaceVariant,
    onSurfaceVariant: Color(0xFFA6A29A),
    outline: Color(0xFF383838),
    outlineVariant: Color(0xFF282828),
    error: AppColors.error,
    onError: Colors.white,
  );

  static ThemeData _build(ColorScheme scheme) {
    final isDark = scheme.brightness == Brightness.dark;
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      brightness: scheme.brightness,
    );
    final baseTextTheme = GoogleFonts.plusJakartaSansTextTheme(base.textTheme);
    final textTheme = baseTextTheme.copyWith(
      displayLarge: GoogleFonts.plusJakartaSans(
        fontSize: 34,
        fontWeight: FontWeight.w900,
        letterSpacing: -0.9,
        height: 1.15,
        color: scheme.onSurface,
      ),
      displayMedium: GoogleFonts.plusJakartaSans(
        fontSize: 28,
        fontWeight: FontWeight.w900,
        letterSpacing: -0.7,
        height: 1.2,
        color: scheme.onSurface,
      ),
      displaySmall: GoogleFonts.plusJakartaSans(
        fontSize: 24,
        fontWeight: FontWeight.w900,
        letterSpacing: -0.5,
        height: 1.25,
        color: scheme.onSurface,
      ),
      headlineLarge: GoogleFonts.plusJakartaSans(
        fontSize: 26,
        fontWeight: FontWeight.w900,
        letterSpacing: -0.6,
        height: 1.2,
        color: scheme.onSurface,
      ),
      headlineMedium: GoogleFonts.plusJakartaSans(
        fontSize: 22,
        fontWeight: FontWeight.w900,
        letterSpacing: -0.5,
        height: 1.25,
        color: scheme.onSurface,
      ),
      headlineSmall: GoogleFonts.plusJakartaSans(
        fontSize: 20,
        fontWeight: FontWeight.w900,
        letterSpacing: -0.4,
        height: 1.25,
        color: scheme.onSurface,
      ),
      titleLarge: GoogleFonts.plusJakartaSans(
        fontSize: 19,
        fontWeight: FontWeight.w900,
        letterSpacing: -0.35,
        height: 1.3,
        color: scheme.onSurface,
      ),
      titleMedium: GoogleFonts.plusJakartaSans(
        fontSize: 16.5,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.25,
        height: 1.35,
        color: scheme.onSurface,
      ),
      titleSmall: GoogleFonts.plusJakartaSans(
        fontSize: 14.5,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.15,
        height: 1.35,
        color: scheme.onSurface,
      ),
      bodyLarge: GoogleFonts.plusJakartaSans(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        letterSpacing: -0.1,
        height: 1.45,
        color: scheme.onSurface,
      ),
      bodyMedium: GoogleFonts.plusJakartaSans(
        fontSize: 13.5,
        fontWeight: FontWeight.w500,
        height: 1.4,
        color: scheme.onSurface,
      ),
      bodySmall: GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.35,
        color: scheme.onSurfaceVariant,
      ),
      labelLarge: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.2,
        color: scheme.onSurface,
      ),
      labelMedium: GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.3,
        color: scheme.onSurface,
      ),
      labelSmall: GoogleFonts.plusJakartaSans(
        fontSize: 10.5,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.5,
        color: scheme.onSurfaceVariant,
      ),
    );

    return base.copyWith(
      textTheme: textTheme,
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 21,
          fontWeight: FontWeight.w900,
          color: scheme.onSurface,
          letterSpacing: -0.5,
        ),
      ),
      cardTheme: CardThemeData(
        color: scheme.surfaceContainerHigh,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: isDark ? const Color(0xFF2E2E2E) : scheme.outlineVariant,
            width: 1.0,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.surfaceContainer,
        selectedColor: scheme.primaryContainer,
        labelStyle: textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: scheme.onSurface,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        ),
        side: BorderSide(color: scheme.outlineVariant, width: 1.0),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          minimumSize: const Size(64, 50),
          elevation: isDark ? 0 : 2,
          shadowColor: scheme.primary.withValues(alpha: 0.35),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 50),
          side: BorderSide(color: scheme.outline, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: isDark ? scheme.primary : const Color(0xFFB47200),
          textStyle: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xFF222222) : const Color(0xFFF7F5EE),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        hintStyle: TextStyle(
          color: scheme.onSurfaceVariant.withValues(alpha: 0.75),
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        labelStyle: TextStyle(
          color: scheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: isDark ? const Color(0xFF333333) : const Color(0xFFE2DDD2),
            width: 1.2,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: isDark ? const Color(0xFF333333) : const Color(0xFFE2DDD2),
            width: 1.2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: scheme.primary, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: scheme.error, width: 1.5),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: isDark ? const Color(0xFF181818) : Colors.white,
        indicatorColor: scheme.primary,
        elevation: isDark ? 0 : 4,
        height: 68,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return textTheme.labelSmall?.copyWith(
              color: isDark ? scheme.primary : const Color(0xFF141414),
              fontWeight: FontWeight.w800,
            );
          }
          return textTheme.labelSmall?.copyWith(
            color: scheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: scheme.onPrimary, size: 24);
          }
          return IconThemeData(color: scheme.onSurfaceVariant, size: 24);
        }),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark
            ? scheme.surfaceContainerHighest
            : const Color(0xFF202020),
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
      ),
      dividerTheme: DividerThemeData(color: scheme.outlineVariant, space: 1),
    );
  }
}
