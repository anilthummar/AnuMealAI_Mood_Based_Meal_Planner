import 'dart:async';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/shopping_item_model.dart';

class ShoppingListLocalDataSource {
  final Box<Map> box;
  final _controller = StreamController<List<ShoppingItemModel>>.broadcast();

  ShoppingListLocalDataSource({required this.box}) {
    _emit();
  }

  Stream<List<ShoppingItemModel>> get stream => _controller.stream;

  void _emit() {
    if (!_controller.isClosed) {
      _controller.add(getAll());
    }
  }

  List<ShoppingItemModel> getAll() {
    final list = <ShoppingItemModel>[];
    for (final key in box.keys) {
      final val = box.get(key);
      if (val != null) {
        try {
          final map = Map<String, dynamic>.from(val);
          list.add(ShoppingItemModel.fromMap(map));
        } catch (_) {}
      }
    }
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  Future<void> put(ShoppingItemModel model) async {
    await box.put(model.id, model.toMap());
    _emit();
  }

  Future<void> putAll(List<ShoppingItemModel> models) async {
    final map = {for (final m in models) m.id: m.toMap()};
    await box.putAll(map);
    _emit();
  }

  Future<void> delete(String id) async {
    await box.delete(id);
    _emit();
  }

  Future<void> toggleCheck(String id) async {
    final raw = box.get(id);
    if (raw != null) {
      final map = Map<String, dynamic>.from(raw);
      final current = map['isChecked'] as bool? ?? false;
      map['isChecked'] = !current;
      await box.put(id, map);
      _emit();
    }
  }

  Future<void> clearCompleted() async {
    final all = getAll();
    final completedKeys = all.where((i) => i.isChecked).map((i) => i.id).toList();
    await box.deleteAll(completedKeys);
    _emit();
  }
}
