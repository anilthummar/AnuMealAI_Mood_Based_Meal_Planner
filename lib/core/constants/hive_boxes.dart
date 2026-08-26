/// Names of every Hive box the app opens. Centralized so `main.dart` can open
/// them all up front and every data source refers to the same string.
class HiveBoxes {
  HiveBoxes._();

  static const String ingredients = 'box_ingredients';
  static const String favorites = 'box_favorites';
  static const String recipesCache = 'box_recipes_cache';
  static const String mealPlans = 'box_meal_plans';
  static const String shoppingList = 'box_shopping_list';
  static const String mealHistory = 'box_meal_history';
  static const String moodHistory = 'box_mood_history';
  static const String mealFeedback = 'box_meal_feedback';

  static const List<String> all = [
    ingredients,
    favorites,
    recipesCache,
    mealPlans,
    shoppingList,
    mealHistory,
    moodHistory,
    mealFeedback,
  ];
}
