import '../entities/mood.dart';

abstract class MoodRepository {
  List<Mood> getAllMoods();
  Mood getMoodById(String id);
  Mood? getSelectedMood();
  Future<void> setSelectedMood(Mood mood);
  List<String> getRecentMoodIds();
  Future<void> recordMoodSelection(String moodId);
}
