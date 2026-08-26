import '../../domain/entities/ingredient.dart';

class IngredientModel extends Ingredient {
  const IngredientModel({
    required super.id,
    required super.name,
    required super.category,
    super.quantity,
    super.unit,
    super.expiryDate,
    super.isAvailable,
    required super.createdAt,
  });

  factory IngredientModel.fromEntity(Ingredient entity) {
    return IngredientModel(
      id: entity.id,
      name: entity.name,
      category: entity.category,
      quantity: entity.quantity,
      unit: entity.unit,
      expiryDate: entity.expiryDate,
      isAvailable: entity.isAvailable,
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
      'expiryDate': expiryDate?.toIso8601String(),
      'isAvailable': isAvailable,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory IngredientModel.fromMap(Map<String, dynamic> map) {
    return IngredientModel(
      id: map['id'] as String,
      name: map['name'] as String,
      category: map['category'] as String? ?? 'Pantry',
      quantity: map['quantity'] as String? ?? '1',
      unit: map['unit'] as String? ?? 'pcs',
      expiryDate: map['expiryDate'] != null ? DateTime.tryParse(map['expiryDate'] as String) : null,
      isAvailable: map['isAvailable'] as bool? ?? true,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
    );
  }
}
