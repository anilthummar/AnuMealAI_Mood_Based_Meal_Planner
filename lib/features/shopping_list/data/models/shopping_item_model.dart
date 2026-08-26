import '../../domain/entities/shopping_item.dart';

class ShoppingItemModel extends ShoppingItem {
  const ShoppingItemModel({
    required super.id,
    required super.name,
    required super.category,
    super.quantity,
    super.unit,
    super.isChecked,
    super.sourceRecipeTitle,
    required super.createdAt,
  });

  factory ShoppingItemModel.fromEntity(ShoppingItem entity) {
    return ShoppingItemModel(
      id: entity.id,
      name: entity.name,
      category: entity.category,
      quantity: entity.quantity,
      unit: entity.unit,
      isChecked: entity.isChecked,
      sourceRecipeTitle: entity.sourceRecipeTitle,
      createdAt: entity.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'quantity': quantity,
      'unit': unit,
      'isChecked': isChecked,
      'sourceRecipeTitle': sourceRecipeTitle,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ShoppingItemModel.fromMap(Map<String, dynamic> map) {
    return ShoppingItemModel(
      id: map['id'] as String,
      name: map['name'] as String,
      category: map['category'] as String? ?? 'Pantry',
      quantity: map['quantity'] as String? ?? '1',
      unit: map['unit'] as String? ?? 'pcs',
      isChecked: map['isChecked'] as bool? ?? false,
      sourceRecipeTitle: map['sourceRecipeTitle'] as String?,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
    );
  }
}
