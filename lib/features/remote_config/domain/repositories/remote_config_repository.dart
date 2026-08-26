import '../entities/remote_config_entity.dart';

/// Clean Architecture Remote Config Repository Interface (§2, §18).
abstract class RemoteConfigRepository {
  Future<RemoteConfigEntity> fetchAndActivate();
  RemoteConfigEntity getCachedConfig();
}
