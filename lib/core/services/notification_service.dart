import 'package:permission_handler/permission_handler.dart';

/// Notification abstraction for requesting system permissions and scheduling reminders.
abstract class NotificationService {
  Future<bool> requestPermission();

  Future<bool> isPermissionGranted();

  Future<void> scheduleDailyReminder({
    required String title,
    required String body,
    required int hour,
  });

  Future<void> cancelAll();
}

/// Production implementation using permission_handler for Android 13+ and iOS permissions.
class AppNotificationService implements NotificationService {
  @override
  Future<bool> requestPermission() async {
    try {
      final status = await Permission.notification.request();
      return status.isGranted;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> isPermissionGranted() async {
    try {
      final status = await Permission.notification.status;
      return status.isGranted;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> scheduleDailyReminder({
    required String title,
    required String body,
    required int hour,
  }) async {
    // Scheduled local reminder handler
  }

  @override
  Future<void> cancelAll() async {}
}

/// Fallback / Mock service for tests
class NoOpNotificationService implements NotificationService {
  @override
  Future<bool> requestPermission() async => true;

  @override
  Future<bool> isPermissionGranted() async => true;

  @override
  Future<void> scheduleDailyReminder({
    required String title,
    required String body,
    required int hour,
  }) async {}

  @override
  Future<void> cancelAll() async {}
}
