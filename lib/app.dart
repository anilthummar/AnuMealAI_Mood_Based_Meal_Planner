import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'core/dependency_injection/di.dart';
import 'core/router/app_router.dart';
import 'core/router/app_routes.dart';
import 'core/services/analytics_service.dart';
import 'core/services/sync_service.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_cubit.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'features/favorites/presentation/bloc/favorites_cubit.dart';
import 'features/home/presentation/bloc/home_cubit.dart';
import 'features/ingredients/presentation/bloc/ingredient_cubit.dart';
import 'features/meal_planner/presentation/bloc/meal_planner_cubit.dart';
import 'features/mood/presentation/bloc/mood_cubit.dart';
import 'features/onboarding/presentation/bloc/onboarding_cubit.dart';
import 'features/profile/presentation/bloc/profile_cubit.dart';
import 'features/recipes/presentation/bloc/recipe_cubit.dart';
import 'features/remote_config/presentation/bloc/remote_config_cubit.dart';
import 'features/remote_config/presentation/bloc/remote_config_state.dart';
import 'features/remote_config/presentation/widgets/force_update_dialog.dart';
import 'features/remote_config/presentation/widgets/soft_update_dialog.dart';
import 'features/settings/presentation/bloc/settings_cubit.dart';
import 'features/settings/presentation/bloc/settings_state.dart';
import 'features/shopping_list/presentation/bloc/shopping_list_cubit.dart';
import 'features/subscription/data/datasources/revenuecat_data_source.dart';
import 'features/subscription/presentation/bloc/subscription_cubit.dart';

class AnuMealAiApp extends StatefulWidget {
  final bool isOnboardingComplete;

  const AnuMealAiApp({
    super.key,
    required this.isOnboardingComplete,
  });

  @override
  State<AnuMealAiApp> createState() => _AnuMealAiAppState();
}

class _AnuMealAiAppState extends State<AnuMealAiApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = AppRouter.createRouter(
      isOnboardingComplete: widget.isOnboardingComplete,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(create: (_) => sl<AuthCubit>()),
        BlocProvider<RemoteConfigCubit>(
          create: (_) => sl<RemoteConfigCubit>()..loadConfiguration(),
        ),
        BlocProvider<SettingsCubit>(create: (_) => sl<SettingsCubit>()),
        BlocProvider<MoodCubit>(create: (_) => sl<MoodCubit>()),
        BlocProvider<ProfileCubit>(
          create: (_) => sl<ProfileCubit>()..loadProfile(),
        ),
        BlocProvider<OnboardingCubit>(create: (_) => sl<OnboardingCubit>()),
        BlocProvider<IngredientCubit>(create: (_) => sl<IngredientCubit>()),
        BlocProvider<RecipeCubit>(create: (_) => sl<RecipeCubit>()),
        BlocProvider<FavoritesCubit>(create: (_) => sl<FavoritesCubit>()),
        BlocProvider<ShoppingListCubit>(create: (_) => sl<ShoppingListCubit>()),
        BlocProvider<MealPlannerCubit>(create: (_) => sl<MealPlannerCubit>()),
        BlocProvider<SubscriptionCubit>(create: (_) => sl<SubscriptionCubit>()),
        BlocProvider<HomeCubit>(create: (_) => sl<HomeCubit>()),
      ],
      child: Builder(
        builder: (context) {
          return MultiBlocListener(
            listeners: [
              // 1. Auth Sync Listener (§27, §40, §62, §65)
              BlocListener<AuthCubit, AuthState>(
                listener: (context, authState) {
                  if (authState is Authenticated) {
                    final uid = authState.user.id;
                    sl<RevenueCatDataSource>().logIn(uid);
                    sl<SyncService>().syncDown(uid);
                    sl<AnalyticsService>().setUserId(uid);
                  } else if (authState is Unauthenticated) {
                    sl<RevenueCatDataSource>().logOut();
                    sl<SyncService>().clearLocalUserData();
                  }
                },
              ),
              // 2. Remote Config Update & Maintenance Guard (§20, §21, §24)
              BlocListener<RemoteConfigCubit, RemoteConfigState>(
                listener: (context, rcState) {
                  if (rcState.isMaintenanceMode) {
                    _router.go(AppRoutes.maintenance);
                  } else if (rcState.isForceUpdateRequired) {
                    ForceUpdateDialog.show(context, rcState.config);
                  } else if (rcState.isSoftUpdateAvailable &&
                      !rcState.softUpdateDismissed) {
                    SoftUpdateDialog.show(
                      context: context,
                      config: rcState.config,
                      onDismiss: () {
                        context
                            .read<RemoteConfigCubit>()
                            .dismissSoftUpdate();
                      },
                    );
                  }
                },
              ),
            ],
            child: BlocBuilder<SettingsCubit, SettingsState>(
              builder: (context, settingsState) {
                return MaterialApp.router(
                  title: 'AnuMealAI',
                  debugShowCheckedModeBanner: false,
                  theme: AppTheme.light,
                  darkTheme: AppTheme.dark,
                  themeMode: settingsState.themeMode,
                  routerConfig: _router,
                );
              },
            ),
          );
        },
      ),
    );
  }
}
