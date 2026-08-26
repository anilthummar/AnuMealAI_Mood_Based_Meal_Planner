import 'package:equatable/equatable.dart';

import '../../domain/entities/user_preferences.dart';

enum ProfileStatus { initial, loading, loaded, saving, error }

class ProfileState extends Equatable {
  final ProfileStatus status;
  final UserPreferences preferences;
  final int mealsCooked;
  final int cookingStreak;
  final String? errorMessage;

  const ProfileState({
    this.status = ProfileStatus.initial,
    this.preferences = const UserPreferences(),
    this.mealsCooked = 0,
    this.cookingStreak = 1,
    this.errorMessage,
  });

  ProfileState copyWith({
    ProfileStatus? status,
    UserPreferences? preferences,
    int? mealsCooked,
    int? cookingStreak,
    String? errorMessage,
  }) {
    return ProfileState(
      status: status ?? this.status,
      preferences: preferences ?? this.preferences,
      mealsCooked: mealsCooked ?? this.mealsCooked,
      cookingStreak: cookingStreak ?? this.cookingStreak,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, preferences, mealsCooked, cookingStreak, errorMessage];
}
