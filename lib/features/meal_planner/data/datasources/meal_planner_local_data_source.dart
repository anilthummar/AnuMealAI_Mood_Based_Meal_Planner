import 'dart:async';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/meal_plan_model.dart';

class MealPlannerLocalDataSource {
  final Box<Map> box;
  final _controller = StreamController<WeeklyMealPlanModel?>.broadcast();

  MealPlannerLocalDataSource({required this.box}) {
    _emit();
  }

  Stream<WeeklyMealPlanModel?> get stream => _controller.stream;

  void _emit() {
    if (!_controller.isClosed) {
      _controller.add(getCurrent());
    }
  }

  WeeklyMealPlanModel? getCurrent() {
    if (box.isEmpty) return null;
    final lastKey = box.keys.last;
    final val = box.get(lastKey);
    if (val != null) {
      try {
        final map = Map<String, dynamic>.from(val);
        return WeeklyMealPlanModel.fromMap(map);
      } catch (_) {}
    }
    return null;
  }

  Future<void> save(WeeklyMealPlanModel plan) async {
    await box.put(plan.id, plan.toMap());
    _emit();
  }
}
