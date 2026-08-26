import 'package:anu_meal_ai/features/mood/domain/entities/mood.dart';

/// The 10 fixed moods (§8 of the spec). This is static reference data, not
/// something that changes per-user, so it lives as a plain catalog rather
/// than behind a remote data source.
class MoodCatalog {
  MoodCatalog._();

  static const List<Mood> all = [
    Mood(
      id: 'happy',
      name: 'Happy',
      emoji: '😊',
      description: 'Feeling good and open to trying something new.',
      traits: ['vibrant flavors', 'shareable dishes', 'moderate effort'],
    ),
    Mood(
      id: 'relaxed',
      name: 'Relaxed',
      emoji: '😌',
      description: 'No rush — happy to enjoy the process.',
      traits: ['balanced meals', 'medium prep time', 'comforting flavors'],
    ),
    Mood(
      id: 'energetic',
      name: 'Energetic',
      emoji: '⚡',
      description: 'Ready to move and try something fresh.',
      traits: ['colorful meals', 'higher protein', 'fresh ingredients', 'more variety'],
    ),
    Mood(
      id: 'tired',
      name: 'Tired',
      emoji: '😴',
      description: 'Running low on energy — keep it simple.',
      traits: ['quick recipes', 'minimal prep', 'fewer ingredients'],
    ),
    Mood(
      id: 'sad',
      name: 'Sad',
      emoji: '😔',
      description: 'Could use something warm and familiar.',
      traits: ['comfort food', 'warm meals', 'familiar flavors'],
    ),
    Mood(
      id: 'stressed',
      name: 'Stressed',
      emoji: '😰',
      description: 'A lot going on — keep cooking simple.',
      traits: ['comfort food', 'simple recipes', 'low complexity', 'warm meals'],
    ),
    Mood(
      id: 'excited',
      name: 'Excited',
      emoji: '🤩',
      description: 'In the mood to try something bold.',
      traits: ['bold flavors', 'new cuisines', 'shareable dishes'],
    ),
    Mood(
      id: 'lazy',
      name: 'Lazy',
      emoji: '🥱',
      description: "Cooking, but let's make it easy.",
      traits: ['one-pot meals', 'minimal cleanup', 'short cook time'],
    ),
    Mood(
      id: 'calm',
      name: 'Calm',
      emoji: '🧘',
      description: 'Centered and up for something wholesome.',
      traits: ['light meals', 'wholesome ingredients', 'balanced nutrition'],
    ),
    Mood(
      id: 'comfort',
      name: 'Comfort',
      emoji: '❤️',
      description: 'In the mood for something that feels like home.',
      traits: ['comfort food', 'rich flavors', 'nostalgic dishes'],
    ),
  ];

  static Mood byId(String id) => all.firstWhere(
        (m) => m.id == id,
        orElse: () => all.first,
      );
}
