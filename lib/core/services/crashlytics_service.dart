import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// Crashlytics Service interface for enterprise crash reporting and observability.
abstract class CrashlyticsService {
  Future<void> recordError(
    dynamic exception,
    StackTrace? stack, {
    dynamic reason,
    Iterable<Object> information = const [],
    bool fatal = false,
  });

  Future<void> log(String message);
  Future<void> setCustomKey(String key, Object value);
  Future<void> setUserIdentifier(String identifier);
}

/// Production Firebase Crashlytics Implementation
class FirebaseCrashlyticsService implements CrashlyticsService {
  final FirebaseCrashlytics _crashlytics;

  FirebaseCrashlyticsService({FirebaseCrashlytics? crashlytics})
      : _crashlytics = crashlytics ?? FirebaseCrashlytics.instance;

  @override
  Future<void> recordError(
    dynamic exception,
    StackTrace? stack, {
    dynamic reason,
    Iterable<Object> information = const [],
    bool fatal = false,
  }) async {
    try {
      await _crashlytics.recordError(
        exception,
        stack,
        reason: reason,
        information: information,
        fatal: fatal,
      );
    } catch (e) {
      debugPrint('[Crashlytics] recordError fallback: $exception ($e)');
    }
  }

  @override
  Future<void> log(String message) async {
    try {
      await _crashlytics.log(message);
    } catch (e) {
      debugPrint('[Crashlytics] log fallback: $message');
    }
  }

  @override
  Future<void> setCustomKey(String key, Object value) async {
    try {
      await _crashlytics.setCustomKey(key, value);
    } catch (e) {
      debugPrint('[Crashlytics] setCustomKey fallback: $key=$value');
    }
  }

  @override
  Future<void> setUserIdentifier(String identifier) async {
    try {
      await _crashlytics.setUserIdentifier(identifier);
    } catch (e) {
      debugPrint('[Crashlytics] setUserIdentifier fallback: $identifier');
    }
  }
}

/// Development & Offline Console Crashlytics Implementation
class ConsoleCrashlyticsService implements CrashlyticsService {
  const ConsoleCrashlyticsService();

  @override
  Future<void> recordError(
    dynamic exception,
    StackTrace? stack, {
    dynamic reason,
    Iterable<Object> information = const [],
    bool fatal = false,
  }) async {
    debugPrint(
      '[ConsoleCrashlytics] recordError (fatal=$fatal): $exception | reason: $reason\n$stack',
    );
  }

  @override
  Future<void> log(String message) async {
    debugPrint('[ConsoleCrashlytics] log: $message');
  }

  @override
  Future<void> setCustomKey(String key, Object value) async {
    debugPrint('[ConsoleCrashlytics] setCustomKey: $key=$value');
  }

  @override
  Future<void> setUserIdentifier(String identifier) async {
    debugPrint('[ConsoleCrashlytics] setUserIdentifier: $identifier');
  }
}
