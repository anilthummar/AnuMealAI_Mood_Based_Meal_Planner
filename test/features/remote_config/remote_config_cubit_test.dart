import 'package:flutter_test/flutter_test.dart';
import 'package:anu_meal_ai/core/services/app_version_service.dart';
import 'package:anu_meal_ai/features/remote_config/domain/entities/remote_config_entity.dart';
import 'package:anu_meal_ai/features/remote_config/domain/repositories/remote_config_repository.dart';
import 'package:anu_meal_ai/features/remote_config/presentation/bloc/remote_config_cubit.dart';

class MockRemoteConfigRepository implements RemoteConfigRepository {
  RemoteConfigEntity _config = RemoteConfigEntity.fallback();

  void setMockConfig(RemoteConfigEntity config) {
    _config = config;
  }

  @override
  Future<RemoteConfigEntity> fetchAndActivate() async => _config;

  @override
  RemoteConfigEntity getCachedConfig() => _config;
}

class MockAppVersionService extends AppVersionService {
  final String version;
  MockAppVersionService({this.version = '1.0.0'});

  @override
  Future<String> getCurrentVersion() async => version;
}

void main() {
  group('RemoteConfigCubit State Machine Tests (§18, §20, §21, §58)', () {
    test(
      'Default configuration evaluates to no maintenance and no update needed',
      () async {
        final mockRepo = MockRemoteConfigRepository();
        final mockVersionService = MockAppVersionService(version: '1.0.0');
        final cubit = RemoteConfigCubit(
          remoteConfigRepository: mockRepo,
          appVersionService: mockVersionService,
        );

        await cubit.loadConfiguration();

        expect(cubit.state.isMaintenanceMode, isFalse);
        expect(cubit.state.isForceUpdateRequired, isFalse);
        expect(cubit.state.isSoftUpdateAvailable, isFalse);

        cubit.close();
      },
    );

    test('Maintenance mode triggers isMaintenanceMode flag', () async {
      final mockRepo = MockRemoteConfigRepository();
      mockRepo.setMockConfig(
        const RemoteConfigEntity(
          minimumSupportedVersion: '1.0.0',
          latestVersion: '1.0.0',
          forceUpdate: false,
          updateMessage: 'Update now',
          androidStoreUrl: '',
          iosStoreUrl: '',
          maintenanceMode: true,
          maintenanceMessage: 'System undergoing maintenance.',
          freeDailyRecipeLimit: 3,
          freeWeeklyPlanLimit: 1,
          freeFavoriteLimit: 20,
          enableAiRecipes: true,
          enableWeeklyPlanner: true,
          enableNotifications: true,
          enableMoodRecommendations: true,
          enableNewHome: true,
          enablePremiumFeatures: true,
        ),
      );

      final mockVersionService = MockAppVersionService(version: '1.0.0');
      final cubit = RemoteConfigCubit(
        remoteConfigRepository: mockRepo,
        appVersionService: mockVersionService,
      );

      await cubit.loadConfiguration();

      expect(cubit.state.isMaintenanceMode, isTrue);
      expect(
        cubit.state.config.maintenanceMessage,
        equals('System undergoing maintenance.'),
      );

      cubit.close();
    });

    test(
      'Semantic version gap triggers force update when minVersion > currentVersion',
      () async {
        final mockRepo = MockRemoteConfigRepository();
        mockRepo.setMockConfig(
          const RemoteConfigEntity(
            minimumSupportedVersion: '1.0.10',
            latestVersion: '1.1.0',
            forceUpdate: false,
            updateMessage: 'Critical security update required.',
            androidStoreUrl: '',
            iosStoreUrl: '',
            maintenanceMode: false,
            maintenanceMessage: '',
            freeDailyRecipeLimit: 3,
            freeWeeklyPlanLimit: 1,
            freeFavoriteLimit: 20,
            enableAiRecipes: true,
            enableWeeklyPlanner: true,
            enableNotifications: true,
            enableMoodRecommendations: true,
            enableNewHome: true,
            enablePremiumFeatures: true,
          ),
        );

        final mockVersionService = MockAppVersionService(version: '1.0.9');
        final cubit = RemoteConfigCubit(
          remoteConfigRepository: mockRepo,
          appVersionService: mockVersionService,
        );

        await cubit.loadConfiguration();

        expect(cubit.state.isForceUpdateRequired, isTrue);

        cubit.close();
      },
    );

    test(
      'Soft update is flagged when latestVersion > currentVersion and minVersion <= currentVersion',
      () async {
        final mockRepo = MockRemoteConfigRepository();
        mockRepo.setMockConfig(
          const RemoteConfigEntity(
            minimumSupportedVersion: '1.0.0',
            latestVersion: '1.1.0',
            forceUpdate: false,
            updateMessage: '',
            androidStoreUrl: '',
            iosStoreUrl: '',
            maintenanceMode: false,
            maintenanceMessage: '',
            freeDailyRecipeLimit: 3,
            freeWeeklyPlanLimit: 1,
            freeFavoriteLimit: 20,
            enableAiRecipes: true,
            enableWeeklyPlanner: true,
            enableNotifications: true,
            enableMoodRecommendations: true,
            enableNewHome: true,
            enablePremiumFeatures: true,
          ),
        );

        final mockVersionService = MockAppVersionService(version: '1.0.0');
        final cubit = RemoteConfigCubit(
          remoteConfigRepository: mockRepo,
          appVersionService: mockVersionService,
        );

        await cubit.loadConfiguration();

        expect(cubit.state.isForceUpdateRequired, isFalse);
        expect(cubit.state.isSoftUpdateAvailable, isTrue);

        cubit.dismissSoftUpdate();
        expect(cubit.state.softUpdateDismissed, isTrue);

        cubit.close();
      },
    );
  });
}
