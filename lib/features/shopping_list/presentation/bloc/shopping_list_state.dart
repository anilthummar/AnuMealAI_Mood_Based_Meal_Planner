import 'package:equatable/equatable.dart';

import '../../domain/entities/shopping_item.dart';

enum ShoppingListStatus { initial, loading, loaded, error }

class ShoppingListState extends Equatable {
  final ShoppingListStatus status;
  final List<ShoppingItem> items;
  final String? errorMessage;

  const ShoppingListState({
    this.status = ShoppingListStatus.initial,
    this.items = const [],
    this.errorMessage,
  });

  int get totalCount => items.length;
  int get completedCount => items.where((i) => i.isChecked).length;
  int get remainingCount => items.where((i) => !i.isChecked).length;

  Map<String, List<ShoppingItem>> get groupedByCategory {
    final map = <String, List<ShoppingItem>>{};
    for (final item in items) {
      map.putIfAbsent(item.category, () => []).add(item);
    }
    return map;
  }

  ShoppingListState copyWith({
    ShoppingListStatus? status,
    List<ShoppingItem>? items,
    String? errorMessage,
  }) {
    return ShoppingListState(
      status: status ?? this.status,
      items: items ?? this.items,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, items, errorMessage];
}
