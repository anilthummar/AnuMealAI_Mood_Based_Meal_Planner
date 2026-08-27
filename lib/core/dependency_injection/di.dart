import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/hive_boxes.dart';
import '../network/dio_client.dart';
import '../network/network_info.dart';
import '../services/ai/ai_recipe_service.dart';
import '../services/ai/gemini_ai_recipe_service.dart';
import '../services/ai/local_recipe_generator.dart';
import '../services/ai/resilient_ai_recipe_service.dart';
import '../services/analytics_service.dart';
import '../services/app_version_service.dart';
import '../services/crashlytics_service.dart';
import '../services/feature_access_service.dart';
import '../services/firebase_service.dart';
import '../services/notification_service.dart';
import '../services/premium_status_provider.dart';
import '../services/sync_service.dart';

// Features
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/bloc/auth_cubit.dart';

import '../../features/favorites/data/datasources/favorites_local_data_source.dart';
import '../../features/favorites/data/repositories/favorites_repository_impl.dart';
import '../../features/favorites/domain/repositories/favorites_repository.dart';
import '../../features/favorites/presentation/bloc/favorites_cubit.dart';

import '../../features/home/presentation/bloc/home_cubit.dart';

import '../../features/ingredients/data/datasources/ingredient_local_data_source.dart';
import '../../features/ingredients/data/repositories/ingredient_repository_impl.dart';
import '../../features/ingredients/domain/repositories/ingredient_repository.dart';
import '../../features/ingredients/presentation/bloc/ingredient_cubit.dart';

import '../../features/meal_planner/data/datasources/meal_planner_local_data_source.dart';
import '../../features/meal_planner/data/repositories/meal_planner_repository_impl.dart';
import '../../features/meal_planner/domain/repositories/meal_planner_repository.dart';
import '../../features/meal_planner/presentation/bloc/meal_planner_cubit.dart';

import '../../features/mood/data/repositories/mood_repository_impl.dart';
import '../../features/mood/domain/repositories/mood_repository.dart';
import '../../features/mood/presentation/bloc/mood_cubit.dart';

import '../../features/onboarding/presentation/bloc/onboarding_cubit.dart';

import '../../features/profile/data/datasources/profile_local_data_source.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/presentation/bloc/profile_cubit.dart';

import '../../features/recipes/data/datasources/recipe_local_data_source.dart';
import '../../features/recipes/data/repositories/recipe_repository_impl.dart';
import '../../features/recipes/domain/repositories/recipe_repository.dart';
import '../../features/recipes/presentation/bloc/recipe_cubit.dart';

import '../../features/remote_config/data/datasources/remote_config_data_source.dart';
import '../../features/remote_config/data/repositories/remote_config_repository_impl.dart';
import '../../features/remote_config/domain/repositories/remote_config_repository.dart';
import '../../features/remote_config/presentation/bloc/remote_config_cubit.dart';

import '../../features/settings/presentation/bloc/settings_cubit.dart';

import '../../features/shopping_list/data/datasources/shopping_list_local_data_source.dart';
import '../../features/shopping_list/data/repositories/shopping_list_repository_impl.dart';
import '../../features/shopping_list/domain/repositories/shopping_list_repository.dart';
import '../../features/shopping_list/presentation/bloc/shopping_list_cubit.dart';

import '../../features/subscription/data/datasources/revenuecat_data_source.dart';
import '../../features/subscription/data/repositories/subscription_repository_impl.dart';
import '../../features/subscription/domain/repositories/subscription_repository.dart';
import '../../features/subscription/presentation/bloc/subscription_cubit.dart';

final sl = GetIt.instance;

Future<void> initDependencyInjection() async {
  // 1. Core / External
  final prefs = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(prefs);

  final connectivity = Connectivity();
  sl.registerSingleton<Connectivity>(connectivity);
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  sl.registerLazySingleton<Dio>(() => DioClient.create());
  sl.registerLazySingleton<FirebaseService>(() => FirebaseService());
  sl.registerLazySingleton<AppVersionService>(() => AppVersionService());

  sl.registerLazySingleton<AnalyticsService>(
    () => sl<FirebaseService>().analytics != null
        ? FirebaseAnalyticsService(analytics: sl<FirebaseService>().analytics!)
        : const ConsoleAnalyticsService(),
  );

  sl.registerLazySingleton<CrashlyticsService>(
    () => sl<FirebaseService>().crashlytics != null
        ? FirebaseCrashlyticsService(
            crashlytics: sl<FirebaseService>().crashlytics!,
          )
        : const ConsoleCrashlyticsService(),
  );

  sl.registerLazySingleton<NotificationService>(() => AppNotificationService());
  sl.registerLazySingleton<SyncService>(
    () => SyncService(firebaseService: sl()),
  );

  // AI Services
  sl.registerLazySingleton<LocalRecipeGenerator>(() => LocalRecipeGenerator());
  sl.registerLazySingleton<GeminiAiRecipeService>(
    () => GeminiAiRecipeService(dio: sl()),
  );
  sl.registerLazySingleton<AIRecipeService>(
    () => ResilientAIRecipeService(
      gemini: sl(),
      local: sl(),
      networkInfo: sl(),
      remoteConfig: sl<FirebaseService>().remoteConfig,
    ),
  );

  // 2. DataSources
  sl.registerLazySingleton<RevenueCatDataSource>(
    () => RevenueCatDataSource(
      firebaseRemoteConfig: sl<FirebaseService>().remoteConfig,
    ),
  );
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => FirebaseAuthRemoteDataSource(
      firebaseAuth: sl<FirebaseService>().auth,
      firestore: sl<FirebaseService>().firestore,
      prefs: sl(),
    ),
  );
  sl.registerLazySingleton<RemoteConfigDataSource>(
    () => FirebaseRemoteConfigDataSource(
      firebaseRemoteConfig: sl<FirebaseService>().remoteConfig,
    ),
  );
  sl.registerLazySingleton<ProfileLocalDataSource>(
    () => ProfileLocalDataSource(prefs: sl()),
  );
  sl.registerLazySingleton<IngredientLocalDataSource>(
    () => IngredientLocalDataSource(box: Hive.box<Map>(HiveBoxes.ingredients)),
  );
  sl.registerLazySingleton<RecipeLocalDataSource>(
    () => RecipeLocalDataSource(
      cacheBox: Hive.box<Map>(HiveBoxes.recipesCache),
      feedbackBox: Hive.box<Map>(HiveBoxes.mealFeedback),
    ),
  );
  sl.registerLazySingleton<FavoritesLocalDataSource>(
    () => FavoritesLocalDataSource(box: Hive.box<Map>(HiveBoxes.favorites)),
  );
  sl.registerLazySingleton<ShoppingListLocalDataSource>(
    () =>
        ShoppingListLocalDataSource(box: Hive.box<Map>(HiveBoxes.shoppingList)),
  );
  sl.registerLazySingleton<MealPlannerLocalDataSource>(
    () => MealPlannerLocalDataSource(box: Hive.box<Map>(HiveBoxes.mealPlans)),
  );

  // 3. Repositories
  final subRepoImpl = SubscriptionRepositoryImpl(dataSource: sl());
  sl.registerSingleton<SubscriptionRepositoryImpl>(subRepoImpl);
  sl.registerSingleton<SubscriptionRepository>(subRepoImpl);
  sl.registerSingleton<PremiumStatusProvider>(subRepoImpl);

  sl.registerLazySingleton<RemoteConfigRepository>(
    () => RemoteConfigRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      firebaseService: sl(),
      analytics: sl(),
    ),
  );

  sl.registerLazySingleton<FeatureAccessService>(
    () => FeatureAccessService(
      premiumStatus: sl(),
      prefs: sl(),
      remoteConfigRepository: sl(),
    ),
  );

  sl.registerLazySingleton<MoodRepository>(
    () => MoodRepositoryImpl(prefs: sl()),
  );
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton<IngredientRepository>(
    () => IngredientRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton<RecipeRepository>(
    () => RecipeRepositoryImpl(aiService: sl(), localDataSource: sl()),
  );
  sl.registerLazySingleton<FavoritesRepository>(
    () => FavoritesRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton<ShoppingListRepository>(
    () => ShoppingListRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton<MealPlannerRepository>(
    () => MealPlannerRepositoryImpl(
      localDataSource: sl(),
      recipeRepository: sl(),
    ),
  );

  // 4. Cubits
  sl.registerFactory<AuthCubit>(() => AuthCubit(authRepository: sl()));
  sl.registerFactory<RemoteConfigCubit>(
    () => RemoteConfigCubit(
      remoteConfigRepository: sl(),
      appVersionService: sl(),
    ),
  );
  sl.registerFactory<MoodCubit>(() => MoodCubit(moodRepository: sl()));
  sl.registerFactory<ProfileCubit>(() => ProfileCubit(profileRepository: sl()));
  sl.registerFactory<OnboardingCubit>(
    () => OnboardingCubit(
      profileRepository: sl(),
      analytics: sl(),
      notificationService: sl(),
    ),
  );
  sl.registerFactory<IngredientCubit>(
    () => IngredientCubit(ingredientRepository: sl(), analytics: sl()),
  );
  sl.registerFactory<RecipeCubit>(
    () => RecipeCubit(
      recipeRepository: sl(),
      featureAccess: sl(),
      analytics: sl(),
    ),
  );
  sl.registerFactory<FavoritesCubit>(
    () => FavoritesCubit(favoritesRepository: sl(), analytics: sl()),
  );
  sl.registerFactory<ShoppingListCubit>(
    () => ShoppingListCubit(shoppingListRepository: sl(), analytics: sl()),
  );
  sl.registerFactory<MealPlannerCubit>(
    () => MealPlannerCubit(
      mealPlannerRepository: sl(),
      featureAccess: sl(),
      analytics: sl(),
    ),
  );
  sl.registerFactory<SubscriptionCubit>(
    () => SubscriptionCubit(subscriptionRepository: sl(), analytics: sl()),
  );
  sl.registerFactory<HomeCubit>(
    () => HomeCubit(
      profileRepository: sl(),
      ingredientRepository: sl(),
      recipeRepository: sl(),
      moodRepository: sl(),
    ),
  );
  sl.registerFactory<SettingsCubit>(
    () => SettingsCubit(
      prefs: sl(),
      subscriptionRepository: sl(),
      notificationService: sl(),
    ),
  );
}
