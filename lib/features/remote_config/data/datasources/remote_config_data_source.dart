import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/constants/remote_config_keys.dart';
import '../../domain/entities/remote_config_entity.dart';

abstract class RemoteConfigDataSource {
  Future<RemoteConfigEntity> fetchAndActivate();
  RemoteConfigEntity getCachedConfig();
}

class FirebaseRemoteConfigDataSource implements RemoteConfigDataSource {
  final FirebaseRemoteConfig? firebaseRemoteConfig;
  RemoteConfigEntity _cachedConfig = RemoteConfigEntity.fallback();

  FirebaseRemoteConfigDataSource({this.firebaseRemoteConfig});

  @override
  RemoteConfigEntity getCachedConfig() => _cachedConfig;

  @override
  Future<RemoteConfigEntity> fetchAndActivate() async {
    if (firebaseRemoteConfig == null) {
      debugPrint(
        '[RemoteConfig] FirebaseRemoteConfig not available, using local defaults.',
      );
      return _cachedConfig;
    }

    try {
      await firebaseRemoteConfig!.setDefaults(RemoteConfigDefaults.defaults);
      await firebaseRemoteConfig!.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: kDebugMode
              ? const Duration(seconds: 0)
              : const Duration(hours: 1),
        ),
      );

      // Fetch with timeout to prevent startup deadlock (§57)
      await firebaseRemoteConfig!.fetchAndActivate().timeout(
        const Duration(seconds: 5),
        onTimeout: () => false,
      );

      _cachedConfig = _parseRemoteConfig(firebaseRemoteConfig!);
      return _cachedConfig;
    } catch (e) {
      debugPrint(
        '[RemoteConfig] fetchAndActivate error, returning defaults: $e',
      );
      return _cachedConfig;
    }
  }

  RemoteConfigEntity _parseRemoteConfig(FirebaseRemoteConfig rc) {
    return RemoteConfigEntity(
      minimumSupportedVersion:
          rc.getString(RemoteConfigKeys.appMinimumSupportedVersion).isNotEmpty
          ? rc.getString(RemoteConfigKeys.appMinimumSupportedVersion)
          : '1.0.0',
      latestVersion: rc.getString(RemoteConfigKeys.appLatestVersion).isNotEmpty
          ? rc.getString(RemoteConfigKeys.appLatestVersion)
          : '1.0.0',
      forceUpdate: rc.getBool(RemoteConfigKeys.appForceUpdate),
      updateMessage: rc.getString(RemoteConfigKeys.appUpdateMessage).isNotEmpty
          ? rc.getString(RemoteConfigKeys.appUpdateMessage)
          : RemoteConfigDefaults.defaults[RemoteConfigKeys.appUpdateMessage],
      androidStoreUrl: rc.getString(RemoteConfigKeys.androidStoreUrl).isNotEmpty
          ? rc.getString(RemoteConfigKeys.androidStoreUrl)
          : RemoteConfigDefaults.defaults[RemoteConfigKeys.androidStoreUrl],
      iosStoreUrl: rc.getString(RemoteConfigKeys.iosStoreUrl).isNotEmpty
          ? rc.getString(RemoteConfigKeys.iosStoreUrl)
          : RemoteConfigDefaults.defaults[RemoteConfigKeys.iosStoreUrl],
      maintenanceMode: rc.getBool(RemoteConfigKeys.maintenanceMode),
      maintenanceMessage:
          rc.getString(RemoteConfigKeys.maintenanceMessage).isNotEmpty
          ? rc.getString(RemoteConfigKeys.maintenanceMessage)
          : RemoteConfigDefaults.defaults[RemoteConfigKeys.maintenanceMessage],
      freeDailyRecipeLimit: rc.getInt(RemoteConfigKeys.freeDailyRecipeLimit) > 0
          ? rc.getInt(RemoteConfigKeys.freeDailyRecipeLimit)
          : 3,
      freeWeeklyPlanLimit: rc.getInt(RemoteConfigKeys.freeWeeklyPlanLimit) > 0
          ? rc.getInt(RemoteConfigKeys.freeWeeklyPlanLimit)
          : 1,
      freeFavoriteLimit: rc.getInt(RemoteConfigKeys.freeFavoriteLimit) > 0
          ? rc.getInt(RemoteConfigKeys.freeFavoriteLimit)
          : 20,
      enableAiRecipes: rc.getBool(RemoteConfigKeys.enableAiRecipes),
      enableWeeklyPlanner: rc.getBool(RemoteConfigKeys.enableWeeklyPlanner),
      enableNotifications: rc.getBool(RemoteConfigKeys.enableNotifications),
      enableMoodRecommendations: rc.getBool(
        RemoteConfigKeys.enableMoodRecommendations,
      ),
      enableNewHome: rc.getBool(RemoteConfigKeys.enableNewHome),
      enablePremiumFeatures: rc.getBool(RemoteConfigKeys.enablePremiumFeatures),
    );
  }
}
