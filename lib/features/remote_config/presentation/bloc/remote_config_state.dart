import 'package:equatable/equatable.dart';
import '../../domain/entities/remote_config_entity.dart';

/// Remote Config & App Update State Machine (§18, §20, §21, §24).
class RemoteConfigState extends Equatable {
  final RemoteConfigEntity config;
  final String currentVersion;
  final bool isLoading;
  final bool isMaintenanceMode;
  final bool isForceUpdateRequired;
  final bool isSoftUpdateAvailable;
  final bool softUpdateDismissed;

  const RemoteConfigState({
    required this.config,
    this.currentVersion = '1.0.0',
    this.isLoading = false,
    this.isMaintenanceMode = false,
    this.isForceUpdateRequired = false,
    this.isSoftUpdateAvailable = false,
    this.softUpdateDismissed = false,
  });

  RemoteConfigState copyWith({
    RemoteConfigEntity? config,
    String? currentVersion,
    bool? isLoading,
    bool? isMaintenanceMode,
    bool? isForceUpdateRequired,
    bool? isSoftUpdateAvailable,
    bool? softUpdateDismissed,
  }) {
    return RemoteConfigState(
      config: config ?? this.config,
      currentVersion: currentVersion ?? this.currentVersion,
      isLoading: isLoading ?? this.isLoading,
      isMaintenanceMode: isMaintenanceMode ?? this.isMaintenanceMode,
      isForceUpdateRequired:
          isForceUpdateRequired ?? this.isForceUpdateRequired,
      isSoftUpdateAvailable:
          isSoftUpdateAvailable ?? this.isSoftUpdateAvailable,
      softUpdateDismissed: softUpdateDismissed ?? this.softUpdateDismissed,
    );
  }

  @override
  List<Object?> get props => [
    config,
    currentVersion,
    isLoading,
    isMaintenanceMode,
    isForceUpdateRequired,
    isSoftUpdateAvailable,
    softUpdateDismissed,
  ];
}
