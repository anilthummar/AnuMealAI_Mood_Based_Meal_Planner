import '../../domain/entities/remote_config_entity.dart';
import '../../domain/repositories/remote_config_repository.dart';
import '../datasources/remote_config_data_source.dart';

/// Production Remote Config Repository Implementation (§2, §18).
class RemoteConfigRepositoryImpl implements RemoteConfigRepository {
  final RemoteConfigDataSource remoteDataSource;

  RemoteConfigRepositoryImpl({required this.remoteDataSource});

  @override
  Future<RemoteConfigEntity> fetchAndActivate() =>
      remoteDataSource.fetchAndActivate();

  @override
  RemoteConfigEntity getCachedConfig() => remoteDataSource.getCachedConfig();
}
