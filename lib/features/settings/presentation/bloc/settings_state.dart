import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class SettingsState extends Equatable {
  final ThemeMode themeMode;
  final bool notificationsEnabled;
  final String appVersion;
  final bool isRestoringPurchases;
  final String? restoreFeedback;

  const SettingsState({
    this.themeMode = ThemeMode.system,
    this.notificationsEnabled = true,
    this.appVersion = '1.0.0',
    this.isRestoringPurchases = false,
    this.restoreFeedback,
  });

  SettingsState copyWith({
    ThemeMode? themeMode,
    bool? notificationsEnabled,
    String? appVersion,
    bool? isRestoringPurchases,
    String? restoreFeedback,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      appVersion: appVersion ?? this.appVersion,
      isRestoringPurchases: isRestoringPurchases ?? this.isRestoringPurchases,
      restoreFeedback: restoreFeedback,
    );
  }

  @override
  List<Object?> get props => [
        themeMode,
        notificationsEnabled,
        appVersion,
        isRestoringPurchases,
        restoreFeedback,
      ];
}
