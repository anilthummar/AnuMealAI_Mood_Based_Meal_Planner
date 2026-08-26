import 'package:equatable/equatable.dart';

class ShoppingItem extends Equatable {
  final String id;
  final String name;
  final String category;
  final String quantity;
  final String unit;
  final bool isChecked;
  final String? sourceRecipeTitle;
  final DateTime createdAt;

  const ShoppingItem({
    required this.id,
    required this.name,
    required this.category,
    this.quantity = '1',
    this.unit = 'pcs',
    this.isChecked = false,
    this.sourceRecipeTitle,
    required this.createdAt,
  });

  ShoppingItem copyWith({
    String? id,
    String? name,
    String? category,
    String? quantity,
    String? unit,
    bool? isChecked,
    String? sourceRecipeTitle,
    DateTime? createdAt,
  }) {
    return ShoppingItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      isChecked: isChecked ?? this.isChecked,
      sourceRecipeTitle: sourceRecipeTitle ?? this.sourceRecipeTitle,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        category,
        quantity,
        unit,
        isChecked,
        sourceRecipeTitle,
        createdAt,
      ];
}
