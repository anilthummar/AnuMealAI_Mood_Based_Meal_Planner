/// Ingredient categories (§9) — shared between the ingredients feature and
/// the shopping list feature (which groups items using the same set).
enum IngredientCategory {
  vegetables,
  fruits,
  grains,
  dairy,
  eggs,
  meat,
  seafood,
  spices,
  sauces,
  pantry,
  frozen,
  snacks,
  other,
}

extension IngredientCategoryX on IngredientCategory {
  String get label => switch (this) {
        IngredientCategory.vegetables => 'Vegetables',
        IngredientCategory.fruits => 'Fruits',
        IngredientCategory.grains => 'Grains',
        IngredientCategory.dairy => 'Dairy',
        IngredientCategory.eggs => 'Eggs',
        IngredientCategory.meat => 'Meat',
        IngredientCategory.seafood => 'Seafood',
        IngredientCategory.spices => 'Spices',
        IngredientCategory.sauces => 'Sauces',
        IngredientCategory.pantry => 'Pantry',
        IngredientCategory.frozen => 'Frozen',
        IngredientCategory.snacks => 'Snacks',
        IngredientCategory.other => 'Other',
      };

  String get emoji => switch (this) {
        IngredientCategory.vegetables => '🥦',
        IngredientCategory.fruits => '🍎',
        IngredientCategory.grains => '🌾',
        IngredientCategory.dairy => '🧀',
        IngredientCategory.eggs => '🥚',
        IngredientCategory.meat => '🥩',
        IngredientCategory.seafood => '🐟',
        IngredientCategory.spices => '🧂',
        IngredientCategory.sauces => '🍯',
        IngredientCategory.pantry => '🥫',
        IngredientCategory.frozen => '🧊',
        IngredientCategory.snacks => '🍿',
        IngredientCategory.other => '📦',
      };

  static IngredientCategory fromName(String name) => IngredientCategory.values.firstWhere(
        (c) => c.name == name,
        orElse: () => IngredientCategory.other,
      );
}

/// Shopping-list grouping (§16) — coarser than ingredient categories.
enum ShoppingCategory { produce, dairy, meat, pantry, other }

extension ShoppingCategoryX on ShoppingCategory {
  String get label => switch (this) {
        ShoppingCategory.produce => 'Produce',
        ShoppingCategory.dairy => 'Dairy',
        ShoppingCategory.meat => 'Meat & Seafood',
        ShoppingCategory.pantry => 'Pantry',
        ShoppingCategory.other => 'Other',
      };

  static ShoppingCategory fromName(String name) => ShoppingCategory.values.firstWhere(
        (c) => c.name == name,
        orElse: () => ShoppingCategory.other,
      );

  static ShoppingCategory fromIngredientCategory(IngredientCategory category) => switch (category) {
        IngredientCategory.vegetables ||
        IngredientCategory.fruits =>
          ShoppingCategory.produce,
        IngredientCategory.dairy || IngredientCategory.eggs => ShoppingCategory.dairy,
        IngredientCategory.meat || IngredientCategory.seafood => ShoppingCategory.meat,
        IngredientCategory.grains ||
        IngredientCategory.spices ||
        IngredientCategory.sauces ||
        IngredientCategory.pantry ||
        IngredientCategory.frozen ||
        IngredientCategory.snacks =>
          ShoppingCategory.pantry,
        IngredientCategory.other => ShoppingCategory.other,
      };
}
