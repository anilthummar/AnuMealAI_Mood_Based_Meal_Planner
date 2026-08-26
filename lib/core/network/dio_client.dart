import 'package:dio/dio.dart';

import '../constants/app_config.dart';

/// Single Dio instance factory. Any data source that talks HTTP takes a
/// [Dio] injected via GetIt — nobody constructs their own client.
class DioClient {
  DioClient._();

  static Dio create() {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.aiApiBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          if (AppConfig.aiApiKey.isNotEmpty) 'Authorization': 'Bearer ${AppConfig.aiApiKey}',
        },
      ),
    );
    return dio;
  }
}
