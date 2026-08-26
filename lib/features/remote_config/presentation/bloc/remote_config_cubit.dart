import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/app_version_service.dart';
import '../../domain/entities/remote_config_entity.dart';
import '../../domain/repositories/remote_config_repository.dart';
import 'remote_config_state.dart';

/// Production RemoteConfigCubit (§18, §20, §21, §58).
/// Evaluates maintenance mode and semantic version updates.
class RemoteConfigCubit extends Cubit<RemoteConfigState> {
  final RemoteConfigRepository remoteConfigRepository;
  final AppVersionService appVersionService;

  RemoteConfigCubit({
    required this.remoteConfigRepository,
    required this.appVersionService,
  }) : super(RemoteConfigState(config: RemoteConfigEntity.fallback())) {
    loadConfiguration();
  }

  Future<void> loadConfiguration() async {
    emit(state.copyWith(isLoading: true));

    final currentVersion = await appVersionService.getCurrentVersion();
    final config = await remoteConfigRepository.fetchAndActivate();

    final isMaintenance = config.maintenanceMode;
    final isForceUpdate =
        config.forceUpdate ||
        AppVersionService.isUpdateRequired(
          currentVersion: currentVersion,
          minVersion: config.minimumSupportedVersion,
        );

    final isSoftUpdate =
        !isForceUpdate &&
        AppVersionService.isUpdateAvailable(
          currentVersion: currentVersion,
          latestVersion: config.latestVersion,
        );

    emit(
      state.copyWith(
        config: config,
        currentVersion: currentVersion,
        isLoading: false,
        isMaintenanceMode: isMaintenance,
        isForceUpdateRequired: isForceUpdate,
        isSoftUpdateAvailable: isSoftUpdate,
      ),
    );
  }

  void dismissSoftUpdate() {
    emit(state.copyWith(softUpdateDismissed: true));
  }
}
