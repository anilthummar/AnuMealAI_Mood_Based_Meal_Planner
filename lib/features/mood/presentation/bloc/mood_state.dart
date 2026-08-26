import 'package:equatable/equatable.dart';

import '../../domain/entities/mood.dart';

class MoodState extends Equatable {
  final List<Mood> allMoods;
  final Mood selectedMood;
  final List<String> recentMoodIds;

  const MoodState({
    required this.allMoods,
    required this.selectedMood,
    this.recentMoodIds = const [],
  });

  MoodState copyWith({
    List<Mood>? allMoods,
    Mood? selectedMood,
    List<String>? recentMoodIds,
  }) {
    return MoodState(
      allMoods: allMoods ?? this.allMoods,
      selectedMood: selectedMood ?? this.selectedMood,
      recentMoodIds: recentMoodIds ?? this.recentMoodIds,
    );
  }

  @override
  List<Object?> get props => [allMoods, selectedMood, recentMoodIds];
}
