import 'package:equatable/equatable.dart';

class UserPreferences extends Equatable {
  final String name;
  final String? avatarPath;
  final List<String> dietaryRestrictions;
  final List<String> favoriteCuisines;
  final String cookingSkill;
  final int typicalCookingTimeMinutes;
  final List<String> mealGoals;
  final bool notificationsEnabled;
  final bool isOnboardingCompleted;

  const UserPreferences({
    this.name = 'Anu',
    this.avatarPath,
    this.dietaryRestrictions = const [],
    this.favoriteCuisines = const ['Italian', 'Mexican', 'Asian'],
    this.cookingSkill = 'Intermediate',
    this.typicalCookingTimeMinutes = 30,
    this.mealGoals = const [
      'Quick meals',
      'Reduce food waste',
      'Eat healthier',
    ],
    this.notificationsEnabled = false,
    this.isOnboardingCompleted = false,
  });

  UserPreferences copyWith({
    String? name,
    String? avatarPath,
    bool clearAvatar = false,
    List<String>? dietaryRestrictions,
    List<String>? favoriteCuisines,
    String? cookingSkill,
    int? typicalCookingTimeMinutes,
    List<String>? mealGoals,
    bool? notificationsEnabled,
    bool? isOnboardingCompleted,
  }) {
    return UserPreferences(
      name: name ?? this.name,
      avatarPath: clearAvatar ? null : (avatarPath ?? this.avatarPath),
      dietaryRestrictions: dietaryRestrictions ?? this.dietaryRestrictions,
      favoriteCuisines: favoriteCuisines ?? this.favoriteCuisines,
      cookingSkill: cookingSkill ?? this.cookingSkill,
      typicalCookingTimeMinutes:
          typicalCookingTimeMinutes ?? this.typicalCookingTimeMinutes,
      mealGoals: mealGoals ?? this.mealGoals,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      isOnboardingCompleted:
          isOnboardingCompleted ?? this.isOnboardingCompleted,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'avatarPath': avatarPath,
      'dietaryRestrictions': dietaryRestrictions,
      'favoriteCuisines': favoriteCuisines,
      'cookingSkill': cookingSkill,
      'typicalCookingTimeMinutes': typicalCookingTimeMinutes,
      'mealGoals': mealGoals,
      'notificationsEnabled': notificationsEnabled,
      'isOnboardingCompleted': isOnboardingCompleted,
    };
  }

  factory UserPreferences.fromMap(Map<String, dynamic> map) {
    return UserPreferences(
      name: map['name'] as String? ?? 'Anu',
      avatarPath: map['avatarPath'] as String?,
      dietaryRestrictions: List<String>.from(
        map['dietaryRestrictions'] as List? ?? [],
      ),
      favoriteCuisines: List<String>.from(
        map['favoriteCuisines'] as List? ?? ['Italian', 'Mexican', 'Asian'],
      ),
      cookingSkill: map['cookingSkill'] as String? ?? 'Intermediate',
      typicalCookingTimeMinutes:
          (map['typicalCookingTimeMinutes'] as num?)?.toInt() ?? 30,
      mealGoals: List<String>.from(
        map['mealGoals'] as List? ?? ['Quick meals', 'Reduce food waste'],
      ),
      notificationsEnabled: map['notificationsEnabled'] as bool? ?? true,
      isOnboardingCompleted: map['isOnboardingCompleted'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [
    name,
    avatarPath,
    dietaryRestrictions,
    favoriteCuisines,
    cookingSkill,
    typicalCookingTimeMinutes,
    mealGoals,
    notificationsEnabled,
    isOnboardingCompleted,
  ];
}
