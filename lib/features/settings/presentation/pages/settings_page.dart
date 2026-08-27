import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/services/url_launcher_service.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../subscription/presentation/widgets/app_customer_center_bottom_sheet.dart';
import '../bloc/settings_cubit.dart';
import '../bloc/settings_state.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BlocConsumer<SettingsCubit, SettingsState>(
      listener: (context, state) {
        if (state.restoreFeedback != null) {
          AppSnackbar.show(
            context,
            message: state.restoreFeedback!,
            variant: state.restoreFeedback!.contains('success')
                ? SnackbarVariant.success
                : SnackbarVariant.info,
          );
          context.read<SettingsCubit>().clearRestoreFeedback();
        }
      },
      builder: (context, state) {
        final cubit = context.read<SettingsCubit>();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Settings'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => context.pop(),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              // Appearance
              const SectionHeader(title: 'Appearance'),
              AppCard(
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.brightness_auto_rounded),
                      title: const Text('System Default'),
                      subtitle: const Text('Follow your device appearance'),
                      trailing: state.themeMode == ThemeMode.system
                          ? Icon(
                              Icons.check_circle_rounded,
                              color: scheme.primary,
                            )
                          : null,
                      onTap: () => cubit.setThemeMode(ThemeMode.system),
                    ),
                    const Divider(),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.light_mode_rounded),
                      title: const Text('Light Mode'),
                      trailing: state.themeMode == ThemeMode.light
                          ? Icon(
                              Icons.check_circle_rounded,
                              color: scheme.primary,
                            )
                          : null,
                      onTap: () => cubit.setThemeMode(ThemeMode.light),
                    ),
                    const Divider(),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.dark_mode_rounded),
                      title: const Text('Dark Mode'),
                      trailing: state.themeMode == ThemeMode.dark
                          ? Icon(
                              Icons.check_circle_rounded,
                              color: scheme.primary,
                            )
                          : null,
                      onTap: () => cubit.setThemeMode(ThemeMode.dark),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Notifications
              const SectionHeader(title: 'Notifications'),
              AppCard(
                child: SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Daily Meal Inspiration'),
                  subtitle: const Text(
                    'Gentle recommendations for dinner ideas',
                  ),
                  value: state.notificationsEnabled,
                  onChanged: (val) => cubit.setNotificationsEnabled(val),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Subscriptions & Purchases
              const SectionHeader(title: 'Subscription & Purchases'),
              AppCard(
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.auto_awesome, color: scheme.primary),
                      title: const Text('Manage Premium'),
                      subtitle: const Text(
                        'View plans & unlock unlimited AI recipes',
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => context.push(AppRoutes.paywall),
                    ),
                    const Divider(),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        Icons.manage_accounts_outlined,
                        color: scheme.primary,
                      ),
                      title: const Text('Customer Center'),
                      subtitle: const Text(
                        'Manage subscription, change plan or request refund',
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => showAppCustomerCenter(context),
                    ),
                    const Divider(),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        Icons.restore_rounded,
                        color: scheme.secondary,
                      ),
                      title: const Text('Restore Purchases'),
                      subtitle: const Text(
                        'Restore existing App Store or Play Store purchases',
                      ),
                      trailing: state.isRestoringPurchases
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.chevron_right_rounded),
                      onTap: state.isRestoringPurchases
                          ? null
                          : () => cubit.restorePurchases(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Legal & About
              const SectionHeader(title: 'Legal & About'),
              AppCard(
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Version'),
                      trailing: Text(
                        state.appVersion,
                        style: textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const Divider(),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Privacy Policy'),
                      trailing: const Icon(Icons.open_in_new_rounded, size: 18),
                      onTap: () => UrlLauncherService.openPrivacyPolicy(),
                    ),
                    const Divider(),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Terms of Use'),
                      trailing: const Icon(Icons.open_in_new_rounded, size: 18),
                      onTap: () => UrlLauncherService.openTermsOfUse(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Account & Security
              const SectionHeader(title: 'Account & Security'),
              AppCard(
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        Icons.delete_forever_rounded,
                        color: scheme.error,
                      ),
                      title: Text(
                        'Delete Account',
                        style: TextStyle(
                          color: scheme.error,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      subtitle: const Text(
                        'Permanently wipe your account and data',
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => context.push(AppRoutes.deleteAccount),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        );
      },
    );
  }
}
