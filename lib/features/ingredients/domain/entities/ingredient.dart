import 'package:equatable/equatable.dart';

class Ingredient extends Equatable {
  final String id;
  final String name;
  final String category;
  final String quantity;
  final String unit;
  final DateTime? expiryDate;
  final bool isAvailable;
  final DateTime createdAt;

  const Ingredient({
    required this.id,
    required this.name,
    required this.category,
    this.quantity = '1',
    this.unit = 'pcs',
    this.expiryDate,
    this.isAvailable = true,
    required this.createdAt,
  });

  Ingredient copyWith({
    String? id,
    String? name,
    String? category,
    String? quantity,
    String? unit,
    DateTime? expiryDate,
    bool? isAvailable,
    DateTime? createdAt,
  }) {
    return Ingredient(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      expiryDate: expiryDate ?? this.expiryDate,
      isAvailable: isAvailable ?? this.isAvailable,
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
        expiryDate,
        isAvailable,
        createdAt,
      ];
}
