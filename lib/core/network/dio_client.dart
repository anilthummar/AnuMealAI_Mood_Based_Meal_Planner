import 'package:dio/dio.dart';

/// Single Dio instance factory. Construct clean HTTP client for cloud APIs.
class DioClient {
  DioClient._();

  static Dio create() {
    return Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );
  }
}
