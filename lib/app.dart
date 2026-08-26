import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'core/dependency_injection/di.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/favorites/presentation/bloc/favorites_cubit.dart';
import 'features/home/presentation/bloc/home_cubit.dart';
import 'features/ingredients/presentation/bloc/ingredient_cubit.dart';
import 'features/meal_planner/presentation/bloc/meal_planner_cubit.dart';
import 'features/mood/presentation/bloc/mood_cubit.dart';
import 'features/onboarding/presentation/bloc/onboarding_cubit.dart';
import 'features/profile/presentation/bloc/profile_cubit.dart';
import 'features/recipes/presentation/bloc/recipe_cubit.dart';
import 'features/settings/presentation/bloc/settings_cubit.dart';
import 'features/settings/presentation/bloc/settings_state.dart';
import 'features/shopping_list/presentation/bloc/shopping_list_cubit.dart';
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
    _router = AppRouter.createRouter(isOnboardingComplete: widget.isOnboardingComplete);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SettingsCubit>(create: (_) => sl<SettingsCubit>()),
        BlocProvider<MoodCubit>(create: (_) => sl<MoodCubit>()),
        BlocProvider<ProfileCubit>(create: (_) => sl<ProfileCubit>()..loadProfile()),
        BlocProvider<OnboardingCubit>(create: (_) => sl<OnboardingCubit>()),
        BlocProvider<IngredientCubit>(create: (_) => sl<IngredientCubit>()),
        BlocProvider<RecipeCubit>(create: (_) => sl<RecipeCubit>()),
        BlocProvider<FavoritesCubit>(create: (_) => sl<FavoritesCubit>()),
        BlocProvider<ShoppingListCubit>(create: (_) => sl<ShoppingListCubit>()),
        BlocProvider<MealPlannerCubit>(create: (_) => sl<MealPlannerCubit>()),
        BlocProvider<SubscriptionCubit>(create: (_) => sl<SubscriptionCubit>()),
        BlocProvider<HomeCubit>(create: (_) => sl<HomeCubit>()),
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
  }
}
