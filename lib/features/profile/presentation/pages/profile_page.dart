import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

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
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
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

  Future<void> _pickImage(ImageSource source) async {
    try {
      if (source == ImageSource.camera) {
        final cameraStatus = await Permission.camera.request();
        if (cameraStatus.isPermanentlyDenied) {
          if (mounted) {
            _showPermissionSettingsDialog(
              title: 'Camera Permission Needed',
              message:
                  'Camera access is required to take a chef selfie. Please enable it in Settings.',
            );
          }
          return;
        }
        if (!cameraStatus.isGranted && !cameraStatus.isLimited) {
          if (mounted) {
            AppSnackbar.show(
              context,
              message: 'Camera permission was not granted.',
              variant: SnackbarVariant.error,
            );
          }
          return;
        }
      } else if (source == ImageSource.gallery) {
        if (Platform.isIOS) {
          final photoStatus = await Permission.photos.request();
          if (photoStatus.isPermanentlyDenied) {
            if (mounted) {
              _showPermissionSettingsDialog(
                title: 'Photo Library Permission Needed',
                message:
                    'Photo Library access is required to choose a profile picture. Please enable it in Settings.',
              );
            }
            return;
          }
        }
      }

      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (picked != null && mounted) {
        context.read<ProfileCubit>().updateAvatar(picked.path);
        AppSnackbar.show(
          context,
          message: 'Profile photo updated! 📸✨',
          variant: SnackbarVariant.success,
        );
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.show(
          context,
          message: 'Unable to pick image. Please verify device permissions.',
          variant: SnackbarVariant.error,
        );
      }
    }
  }

  void _showPermissionSettingsDialog({
    required String title,
    required String message,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  void _showAvatarOptions(BuildContext context, String? currentPath) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final scheme = Theme.of(context).colorScheme;
        final textTheme = Theme.of(context).textTheme;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: scheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Change Profile Photo',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.golden.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: AppColors.primaryGoldDark,
                    ),
                  ),
                  title: const Text(
                    'Take Photo with Camera',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: const Text(
                    'Capture a fresh chef selfie',
                    style: TextStyle(fontSize: 12),
                  ),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.terracotta.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.photo_library_rounded,
                      color: AppColors.terracotta,
                    ),
                  ),
                  title: const Text(
                    'Choose from Gallery',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: const Text(
                    'Select photo from device storage',
                    style: TextStyle(fontSize: 12),
                  ),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _pickImage(ImageSource.gallery);
                  },
                ),
                if (currentPath != null && currentPath.isNotEmpty) ...[
                  const Divider(),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.red,
                      ),
                    ),
                    title: const Text(
                      'Remove Photo',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    onTap: () {
                      Navigator.of(ctx).pop();
                      context.read<ProfileCubit>().removeAvatar();
                      AppSnackbar.show(
                        context,
                        message: 'Profile photo removed',
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
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
              textInputAction: TextInputAction.done,
              onSubmitted: (val) {
                if (val.trim().isNotEmpty) {
                  FocusScope.of(ctx).unfocus();
                  context.read<ProfileCubit>().updateName(val.trim());
                  Navigator.pop(ctx);
                  AppSnackbar.show(
                    context,
                    message: 'Name updated! ✨',
                    variant: SnackbarVariant.success,
                  );
                }
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: 'Save Name',
              onPressed: () {
                FocusScope.of(ctx).unfocus();
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
                      InkWell(
                        onTap: () =>
                            _showAvatarOptions(context, prefs.avatarPath),
                        borderRadius: BorderRadius.circular(34),
                        child: Stack(
                          children: [
                            Container(
                              width: 68,
                              height: 68,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    AppColors.terracotta,
                                    AppColors.golden,
                                  ],
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
                              child: ClipOval(
                                child:
                                    (prefs.avatarPath != null &&
                                        File(prefs.avatarPath!).existsSync())
                                    ? Image.file(
                                        File(prefs.avatarPath!),
                                        width: 68,
                                        height: 68,
                                        fit: BoxFit.cover,
                                        errorBuilder: (ctx, err, stack) =>
                                            Center(
                                              child: Text(
                                                displayName.isNotEmpty
                                                    ? displayName[0]
                                                          .toUpperCase()
                                                    : 'A',
                                                style: const TextStyle(
                                                  fontSize: 26,
                                                  fontWeight: FontWeight.w900,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                      )
                                    : Center(
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
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: scheme.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: scheme.surface,
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.camera_alt_rounded,
                                  size: 13,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
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
                                            ? '👑 AnuMealAI Pro'
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
                                        ? 'All Pro features unlocked • Unlimited AI Planner'
                                        : '3 recipes / day • Tap to unlock unlimited Pro',
                                    style: TextStyle(
                                      color: isPremium
                                          ? const Color(0xFFFFE082)
                                          : scheme.onPrimaryContainer
                                                .withValues(alpha: 0.8),
                                      fontSize: 12,
                                      fontWeight: isPremium
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isPremium)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2E7D32),
                                  borderRadius: BorderRadius.circular(
                                    AppSpacing.radiusPill,
                                  ),
                                ),
                                child: const Text(
                                  'ACTIVE ✨',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              )
                            else
                              Icon(
                                Icons.chevron_right_rounded,
                                color: scheme.primary,
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
                const SizedBox(height: AppSpacing.lg),

                // Account & Session Section (§7, §44, §45)
                const SectionHeader(title: 'Account & Session'),
                BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, authState) {
                    final user = authState is Authenticated
                        ? authState.user
                        : null;
                    final isGuest = user?.isAnonymous ?? true;

                    return AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: isDark
                                    ? AppColors.primaryGold.withValues(
                                        alpha: 0.2,
                                      )
                                    : const Color(0xFFFEF3C7),
                                child: Text(
                                  isGuest
                                      ? '👤'
                                      : (user?.displayName.isNotEmpty == true
                                            ? user!.displayName[0].toUpperCase()
                                            : '👨‍🍳'),
                                  style: const TextStyle(fontSize: 18),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isGuest
                                          ? 'Guest Chef'
                                          : (user?.displayName ?? 'Chef'),
                                      style: textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    Text(
                                      isGuest
                                          ? 'Session stored locally'
                                          : (user?.email ?? ''),
                                      style: textTheme.bodySmall?.copyWith(
                                        color: scheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),
                          const Divider(),
                          const SizedBox(height: AppSpacing.xs),
                          if (isGuest)
                            AppButton(
                              label: 'Sign In / Create Account 🔐',
                              onPressed: () => context.push(AppRoutes.login),
                            )
                          else
                            OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              icon: const Icon(Icons.logout_rounded, size: 18),
                              label: const Text(
                                'Sign Out',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Sign Out?'),
                                    content: const Text(
                                      'Are you sure you want to sign out of AnuMealAI?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(ctx, false),
                                        child: const Text('Cancel'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () =>
                                            Navigator.pop(ctx, true),
                                        child: const Text('Sign Out'),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirm == true && context.mounted) {
                                  await context.read<AuthCubit>().signOut();
                                  if (context.mounted) {
                                    context.go(AppRoutes.login);
                                  }
                                }
                              },
                            ),
                        ],
                      ),
                    );
                  },
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
