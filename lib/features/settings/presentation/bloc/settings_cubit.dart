import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/preference_keys.dart';
import '../../../../core/services/notification_service.dart';
import '../../../subscription/domain/repositories/subscription_repository.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final SharedPreferences prefs;
  final SubscriptionRepository? subscriptionRepository;
  final NotificationService? notificationService;

  SettingsCubit({
    required this.prefs,
    this.subscriptionRepository,
    this.notificationService,
  }) : super(const SettingsState()) {
    _init();
  }

  Future<void> _init() async {
    final modeIndex = prefs.getInt(PreferenceKeys.themeModeIndex) ?? 0;
    final themeMode = switch (modeIndex) {
      1 => ThemeMode.light,
      2 => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    final notifs = prefs.getBool(PreferenceKeys.notificationsEnabled) ?? false;

    String version = '1.0.0';
    try {
      final info = await PackageInfo.fromPlatform();
      version = '${info.version} (${info.buildNumber})';
    } catch (_) {}

    emit(
      state.copyWith(
        themeMode: themeMode,
        notificationsEnabled: notifs,
        appVersion: version,
      ),
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final index = switch (mode) {
      ThemeMode.system => 0,
      ThemeMode.light => 1,
      ThemeMode.dark => 2,
    };
    await prefs.setInt(PreferenceKeys.themeModeIndex, index);
    emit(state.copyWith(themeMode: mode));
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    if (enabled && notificationService != null) {
      final granted = await notificationService!.requestPermission();
      await prefs.setBool(PreferenceKeys.notificationsEnabled, granted);
      emit(state.copyWith(notificationsEnabled: granted));
      return;
    }
    await prefs.setBool(PreferenceKeys.notificationsEnabled, enabled);
    emit(state.copyWith(notificationsEnabled: enabled));
  }

  Future<void> restorePurchases() async {
    if (subscriptionRepository == null) return;
    emit(state.copyWith(isRestoringPurchases: true, restoreFeedback: null));
    try {
      final result = await subscriptionRepository!.restorePurchases();
      if (result.isSuccess) {
        emit(
          state.copyWith(
            isRestoringPurchases: false,
            restoreFeedback: 'Purchases restored successfully! ✨',
          ),
        );
      } else {
        emit(
          state.copyWith(
            isRestoringPurchases: false,
            restoreFeedback:
                result.failureOrNull?.message ??
                'No previous active purchases found.',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          isRestoringPurchases: false,
          restoreFeedback:
              'Failed to restore purchases. Please check your network connection.',
        ),
      );
    }
  }

  void clearRestoreFeedback() {
    emit(state.copyWith(restoreFeedback: null));
  }
}
