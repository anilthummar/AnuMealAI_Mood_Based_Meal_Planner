import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:anu_meal_ai/features/mood/data/repositories/mood_repository_impl.dart';
import 'package:anu_meal_ai/features/mood/presentation/bloc/mood_cubit.dart';

void main() {
  group('MoodCubit', () {
    late SharedPreferences prefs;
    late MoodRepositoryImpl repository;
    late MoodCubit cubit;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      repository = MoodRepositoryImpl(prefs: prefs);
      cubit = MoodCubit(moodRepository: repository);
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state has default mood and all moods list', () {
      expect(cubit.state.allMoods, isNotEmpty);
      expect(cubit.state.selectedMood.name, isNotEmpty);
    });

    test('selectMood updates selected mood and persists to repository', () async {
      final targetMood = cubit.state.allMoods.last;
      await cubit.selectMood(targetMood);

      expect(cubit.state.selectedMood.id, equals(targetMood.id));
      expect(repository.getSelectedMood()?.id, equals(targetMood.id));
    });
  });
}
