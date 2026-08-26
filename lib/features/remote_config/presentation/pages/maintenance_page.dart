import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../bloc/remote_config_cubit.dart';
import '../bloc/remote_config_state.dart';

/// Clean, graceful Maintenance Mode Page (§24).
class MaintenancePage extends StatelessWidget {
  const MaintenancePage({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<RemoteConfigCubit, RemoteConfigState>(
          builder: (context, state) {
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Maintenance Icon Avatar
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isDark
                              ? [
                                  const Color(0xFF2C2614),
                                  const Color(0xFF382E18),
                                ]
                              : [
                                  const Color(0xFFFFFBEB),
                                  const Color(0xFFFEF3C7),
                                ],
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
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text('🛠️', style: TextStyle(fontSize: 42)),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    Text(
                      'AnuMealAI is getting better!',
                      textAlign: TextAlign.center,
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    Text(
                      state.config.maintenanceMessage,
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),

                    AppButton(
                      label: 'Check Again 🔄',
                      isLoading: state.isLoading,
                      onPressed: () {
                        context.read<RemoteConfigCubit>().loadConfiguration();
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
