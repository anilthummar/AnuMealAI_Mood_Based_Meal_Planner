import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/mood.dart';
import '../../domain/repositories/mood_repository.dart';
import 'mood_state.dart';

class MoodCubit extends Cubit<MoodState> {
  final MoodRepository moodRepository;

  MoodCubit({required this.moodRepository})
      : super(
          MoodState(
            allMoods: moodRepository.getAllMoods(),
            selectedMood: moodRepository.getSelectedMood() ?? moodRepository.getAllMoods().first,
            recentMoodIds: moodRepository.getRecentMoodIds(),
          ),
        );

  Future<void> selectMood(Mood mood) async {
    emit(state.copyWith(selectedMood: mood));
    await moodRepository.setSelectedMood(mood);
    emit(state.copyWith(recentMoodIds: moodRepository.getRecentMoodIds()));
  }

  void selectMoodById(String id) {
    final mood = moodRepository.getMoodById(id);
    selectMood(mood);
  }
}
