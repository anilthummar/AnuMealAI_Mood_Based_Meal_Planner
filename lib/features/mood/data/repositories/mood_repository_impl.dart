import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/preference_keys.dart';
import '../../domain/entities/mood.dart';
import '../../domain/repositories/mood_repository.dart';
import '../datasources/mood_catalog.dart';

class MoodRepositoryImpl implements MoodRepository {
  final SharedPreferences prefs;

  MoodRepositoryImpl({required this.prefs});

  @override
  List<Mood> getAllMoods() => MoodCatalog.all;

  @override
  Mood getMoodById(String id) => MoodCatalog.byId(id);

  @override
  Mood? getSelectedMood() {
    final id = prefs.getString(PreferenceKeys.lastSelectedMoodId);
    if (id == null) return null;
    return MoodCatalog.byId(id);
  }

  @override
  Future<void> setSelectedMood(Mood mood) async {
    await prefs.setString(PreferenceKeys.lastSelectedMoodId, mood.id);
    await recordMoodSelection(mood.id);
  }

  @override
  List<String> getRecentMoodIds() {
    return prefs.getStringList(PreferenceKeys.moodHistoryList) ?? [];
  }

  @override
  Future<void> recordMoodSelection(String moodId) async {
    final history = getRecentMoodIds();
    final updated = [moodId, ...history.where((id) => id != moodId)].take(10).toList();
    await prefs.setStringList(PreferenceKeys.moodHistoryList, updated);
  }
}
