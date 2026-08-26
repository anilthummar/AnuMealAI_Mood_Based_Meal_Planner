import 'dart:async';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/ingredient_model.dart';

class IngredientLocalDataSource {
  final Box<Map> box;
  final _controller = StreamController<List<IngredientModel>>.broadcast();

  IngredientLocalDataSource({required this.box}) {
    _emit();
  }

  Stream<List<IngredientModel>> get stream => _controller.stream;

  void _emit() {
    if (!_controller.isClosed) {
      _controller.add(getAll());
    }
  }

  List<IngredientModel> getAll() {
    final list = <IngredientModel>[];
    for (final key in box.keys) {
      final val = box.get(key);
      if (val != null) {
        try {
          final map = Map<String, dynamic>.from(val);
          list.add(IngredientModel.fromMap(map));
        } catch (_) {}
      }
    }
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  Future<void> put(IngredientModel model) async {
    await box.put(model.id, model.toMap());
    _emit();
  }

  Future<void> putAll(List<IngredientModel> models) async {
    final map = {for (final m in models) m.id: m.toMap()};
    await box.putAll(map);
    _emit();
  }

  Future<void> delete(String id) async {
    await box.delete(id);
    _emit();
  }

  Future<void> toggleAvailability(String id) async {
    final raw = box.get(id);
    if (raw != null) {
      final map = Map<String, dynamic>.from(raw);
      final current = map['isAvailable'] as bool? ?? true;
      map['isAvailable'] = !current;
      await box.put(id, map);
      _emit();
    }
  }
}
