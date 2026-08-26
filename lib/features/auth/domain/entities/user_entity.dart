import 'package:equatable/equatable.dart';

/// Production User Domain Entity (§10).
/// Strictly excludes passwords and sensitive payment credentials.
class UserEntity extends Equatable {
  final String id;
  final String email;
  final String displayName;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool onboardingCompleted;
  final String preferredLanguage;
  final List<String> dietaryPreferences;
  final List<String> cuisinePreferences;
  final String cookingSkill;
  final int preferredCookingTime;
  final bool notificationEnabled;
  final bool isAnonymous;

  const UserEntity({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoUrl,
    required this.createdAt,
    required this.updatedAt,
    this.onboardingCompleted = false,
    this.preferredLanguage = 'en',
    this.dietaryPreferences = const [],
    this.cuisinePreferences = const [],
    this.cookingSkill = 'intermediate',
    this.preferredCookingTime = 30,
    this.notificationEnabled = true,
    this.isAnonymous = false,
  });

  /// Factory for Guest / Anonymous sessions
  factory UserEntity.guest({String? id}) {
    final now = DateTime.now();
    return UserEntity(
      id: id ?? 'guest_user',
      email: 'guest@anumealai.app',
      displayName: 'Guest Chef',
      createdAt: now,
      updatedAt: now,
      onboardingCompleted: true,
      isAnonymous: true,
    );
  }

  UserEntity copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? onboardingCompleted,
    String? preferredLanguage,
    List<String>? dietaryPreferences,
    List<String>? cuisinePreferences,
    String? cookingSkill,
    int? preferredCookingTime,
    bool? notificationEnabled,
    bool? isAnonymous,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      dietaryPreferences: dietaryPreferences ?? this.dietaryPreferences,
      cuisinePreferences: cuisinePreferences ?? this.cuisinePreferences,
      cookingSkill: cookingSkill ?? this.cookingSkill,
      preferredCookingTime: preferredCookingTime ?? this.preferredCookingTime,
      notificationEnabled: notificationEnabled ?? this.notificationEnabled,
      isAnonymous: isAnonymous ?? this.isAnonymous,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'onboardingCompleted': onboardingCompleted,
      'preferredLanguage': preferredLanguage,
      'dietaryPreferences': dietaryPreferences,
      'cuisinePreferences': cuisinePreferences,
      'cookingSkill': cookingSkill,
      'preferredCookingTime': preferredCookingTime,
      'notificationEnabled': notificationEnabled,
      'isAnonymous': isAnonymous,
    };
  }

  factory UserEntity.fromMap(Map<String, dynamic> map, {String? fallbackId}) {
    return UserEntity(
      id: map['id'] as String? ?? fallbackId ?? 'unknown_id',
      email: map['email'] as String? ?? '',
      displayName: map['displayName'] as String? ?? 'Chef',
      photoUrl: map['photoUrl'] as String?,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      onboardingCompleted: map['onboardingCompleted'] as bool? ?? false,
      preferredLanguage: map['preferredLanguage'] as String? ?? 'en',
      dietaryPreferences: (map['dietaryPreferences'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      cuisinePreferences: (map['cuisinePreferences'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      cookingSkill: map['cookingSkill'] as String? ?? 'intermediate',
      preferredCookingTime: map['preferredCookingTime'] as int? ?? 30,
      notificationEnabled: map['notificationEnabled'] as bool? ?? true,
      isAnonymous: map['isAnonymous'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        displayName,
        photoUrl,
        createdAt,
        updatedAt,
        onboardingCompleted,
        preferredLanguage,
        dietaryPreferences,
        cuisinePreferences,
        cookingSkill,
        preferredCookingTime,
        notificationEnabled,
        isAnonymous,
      ];
}
