import 'package:equatable/equatable.dart';

import 'meal_plan_entry.dart';

class WeeklyMealPlan extends Equatable {
  final String id;
  final DateTime weekStartDate;
  final List<MealPlanEntry> entries;
  final DateTime createdAt;

  const WeeklyMealPlan({
    required this.id,
    required this.weekStartDate,
    required this.entries,
    required this.createdAt,
  });

  static const List<String> days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  static const List<String> dayNames = days;

  static const List<String> slots = [
    'Breakfast',
    'Lunch',
    'Dinner',
    'Snack',
  ];

  List<MealPlanEntry> entriesForDay(dynamic day) {
    if (day is int) {
      if (day >= 0 && day < days.length) {
        final dayName = days[day];
        return entries.where((e) => e.dayOfWeek.toLowerCase() == dayName.toLowerCase()).toList();
      }
      return [];
    }
    final dayStr = day.toString();
    return entries.where((e) => e.dayOfWeek.toLowerCase() == dayStr.toLowerCase()).toList();
  }

  MealPlanEntry? entryFor(String day, String slot) {
    return entries.where((e) => e.dayOfWeek.toLowerCase() == day.toLowerCase() && e.mealSlot.toLowerCase() == slot.toLowerCase()).firstOrNull;
  }

  WeeklyMealPlan copyWith({
    String? id,
    DateTime? weekStartDate,
    List<MealPlanEntry>? entries,
    DateTime? createdAt,
  }) {
    return WeeklyMealPlan(
      id: id ?? this.id,
      weekStartDate: weekStartDate ?? this.weekStartDate,
      entries: entries ?? this.entries,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, weekStartDate, entries, createdAt];
}
