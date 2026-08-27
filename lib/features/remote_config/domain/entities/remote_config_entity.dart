import 'package:equatable/equatable.dart';

/// Remote Configuration Domain Entity (§18, §20, §24, §55).
class RemoteConfigEntity extends Equatable {
  final String minimumSupportedVersion;
  final String latestVersion;
  final bool forceUpdate;
  final String updateMessage;
  final String androidStoreUrl;
  final String iosStoreUrl;
  final bool maintenanceMode;
  final String maintenanceMessage;
  final int freeDailyRecipeLimit;
  final int freeWeeklyPlanLimit;
  final int freeFavoriteLimit;
  final bool enableAiRecipes;
  final bool enableWeeklyPlanner;
  final bool enableNotifications;
  final bool enableMoodRecommendations;
  final bool enableNewHome;
  final bool enablePremiumFeatures;
  final String geminiApiKey;
  final String geminiModel;
  final String revenueCatApiKeyAndroid;
  final String revenueCatApiKeyIos;

  const RemoteConfigEntity({
    required this.minimumSupportedVersion,
    required this.latestVersion,
    required this.forceUpdate,
    required this.updateMessage,
    required this.androidStoreUrl,
    required this.iosStoreUrl,
    required this.maintenanceMode,
    required this.maintenanceMessage,
    required this.freeDailyRecipeLimit,
    required this.freeWeeklyPlanLimit,
    required this.freeFavoriteLimit,
    required this.enableAiRecipes,
    required this.enableWeeklyPlanner,
    required this.enableNotifications,
    required this.enableMoodRecommendations,
    required this.enableNewHome,
    required this.enablePremiumFeatures,
    this.geminiApiKey = '',
    this.geminiModel = 'gemini-3.6-flash',
    this.revenueCatApiKeyAndroid = '',
    this.revenueCatApiKeyIos = '',
  });

  factory RemoteConfigEntity.fallback() {
    return const RemoteConfigEntity(
      minimumSupportedVersion: '1.0.0',
      latestVersion: '1.0.0',
      forceUpdate: false,
      updateMessage:
          "You're using an older version of AnuMealAI. Update now to continue.",
      androidStoreUrl:
          'https://play.google.com/store/apps/details?id=com.anumealai.anu_meal_ai',
      iosStoreUrl: 'https://apps.apple.com/app/id6740123456',
      maintenanceMode: false,
      maintenanceMessage:
          "AnuMealAI is getting better! We're performing a quick service update. Please check back shortly.",
      freeDailyRecipeLimit: 3,
      freeWeeklyPlanLimit: 1,
      freeFavoriteLimit: 20,
      enableAiRecipes: true,
      enableWeeklyPlanner: true,
      enableNotifications: true,
      enableMoodRecommendations: true,
      enableNewHome: true,
      enablePremiumFeatures: true,
      geminiApiKey: '',
      geminiModel: 'gemini-3.6-flash',
      revenueCatApiKeyAndroid: '',
      revenueCatApiKeyIos: '',
    );
  }

  @override
  List<Object?> get props => [
    minimumSupportedVersion,
    latestVersion,
    forceUpdate,
    updateMessage,
    androidStoreUrl,
    iosStoreUrl,
    maintenanceMode,
    maintenanceMessage,
    freeDailyRecipeLimit,
    freeWeeklyPlanLimit,
    freeFavoriteLimit,
    enableAiRecipes,
    enableWeeklyPlanner,
    enableNotifications,
    enableMoodRecommendations,
    enableNewHome,
    enablePremiumFeatures,
    geminiApiKey,
    geminiModel,
    revenueCatApiKeyAndroid,
    revenueCatApiKeyIos,
  ];
}
