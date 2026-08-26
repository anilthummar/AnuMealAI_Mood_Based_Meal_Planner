import 'package:equatable/equatable.dart';

/// A selectable mood. Mood is used purely to personalize meal suggestions —
/// it makes no medical, psychological, or diagnostic claim.
class Mood extends Equatable {
  final String id;
  final String name;
  final String emoji;
  final String description;

  /// Free-text characteristics used by the recipe matcher and the AI prompt
  /// builder, e.g. ["comfort food", "simple recipes", "low complexity"].
  final List<String> traits;

  const Mood({
    required this.id,
    required this.name,
    required this.emoji,
    required this.description,
    required this.traits,
  });

  @override
  List<Object?> get props => [id, name, emoji, description, traits];
}
