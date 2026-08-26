import 'package:flutter/foundation.dart' show debugPrint;

/// Analytics abstraction (§32). Business logic never depends on a specific
/// analytics vendor — call typed helpers or [AnalyticsService.logEvent] and swap the
/// registered implementation in the DI container without touching feature code.
abstract class AnalyticsService {
  Future<void> logEvent(String name, [Map<String, Object?> parameters]);
  Future<void> setUserProperty(String name, String? value);

  // Strongly-typed event helpers
  Future<void> logAppOpened();
  Future<void> logOnboardingCompleted();
  Future<void> logMoodSelected(String moodId);
  Future<void> logIngredientAdded(String ingredientName);
  Future<void> logRecipeGenerated(String moodId, int ingredientCount);
  Future<void> logRecipeViewed(String recipeId, String recipeTitle);
  Future<void> logRecipeFavorited(String recipeId, String recipeTitle);
  Future<void> logRecipeCooked(String recipeId);
  Future<void> logMealPlanGenerated(String moodId);
  Future<void> logShoppingItemAdded(String itemName);
  Future<void> logPaywallViewed();
  Future<void> logPurchaseStarted(String productId);
  Future<void> logPurchaseCompleted(String productId);
  Future<void> logPurchaseFailed(String error);
  Future<void> logRestorePurchase();
  Future<void> logSubscriptionActive();
}

class AnalyticsEvents {
  AnalyticsEvents._();

  static const appOpened = 'app_opened';
  static const onboardingCompleted = 'onboarding_completed';
  static const moodSelected = 'mood_selected';
  static const ingredientAdded = 'ingredient_added';
  static const recipeGenerated = 'recipe_generated';
  static const recipeViewed = 'recipe_viewed';
  static const recipeFavorited = 'recipe_favorited';
  static const recipeCooked = 'recipe_cooked';
  static const mealPlanGenerated = 'meal_plan_generated';
  static const shoppingItemAdded = 'shopping_item_added';
  static const paywallViewed = 'paywall_viewed';
  static const purchaseStarted = 'purchase_started';
  static const purchaseCompleted = 'purchase_completed';
  static const purchaseFailed = 'purchase_failed';
  static const restorePurchase = 'restore_purchase';
  static const subscriptionActive = 'subscription_active';
}

class ConsoleAnalyticsService implements AnalyticsService {
  const ConsoleAnalyticsService();

  @override
  Future<void> logEvent(String name, [Map<String, Object?> parameters = const {}]) async {
    debugPrint('[analytics] $name $parameters');
  }

  @override
  Future<void> setUserProperty(String name, String? value) async {
    debugPrint('[analytics] set $name=$value');
  }

  @override
  Future<void> logAppOpened() => logEvent(AnalyticsEvents.appOpened);

  @override
  Future<void> logOnboardingCompleted() => logEvent(AnalyticsEvents.onboardingCompleted);

  @override
  Future<void> logMoodSelected(String moodId) => logEvent(AnalyticsEvents.moodSelected, {'mood': moodId});

  @override
  Future<void> logIngredientAdded(String ingredientName) =>
      logEvent(AnalyticsEvents.ingredientAdded, {'name': ingredientName});

  @override
  Future<void> logRecipeGenerated(String moodId, int ingredientCount) => logEvent(
        AnalyticsEvents.recipeGenerated,
        {'mood': moodId, 'ingredient_count': ingredientCount},
      );

  @override
  Future<void> logRecipeViewed(String recipeId, String recipeTitle) => logEvent(
        AnalyticsEvents.recipeViewed,
        {'id': recipeId, 'title': recipeTitle},
      );

  @override
  Future<void> logRecipeFavorited(String recipeId, String recipeTitle) => logEvent(
        AnalyticsEvents.recipeFavorited,
        {'id': recipeId, 'title': recipeTitle},
      );

  @override
  Future<void> logRecipeCooked(String recipeId) => logEvent(AnalyticsEvents.recipeCooked, {'id': recipeId});

  @override
  Future<void> logMealPlanGenerated(String moodId) =>
      logEvent(AnalyticsEvents.mealPlanGenerated, {'mood': moodId});

  @override
  Future<void> logShoppingItemAdded(String itemName) =>
      logEvent(AnalyticsEvents.shoppingItemAdded, {'name': itemName});

  @override
  Future<void> logPaywallViewed() => logEvent(AnalyticsEvents.paywallViewed);

  @override
  Future<void> logPurchaseStarted(String productId) =>
      logEvent(AnalyticsEvents.purchaseStarted, {'product': productId});

  @override
  Future<void> logPurchaseCompleted(String productId) =>
      logEvent(AnalyticsEvents.purchaseCompleted, {'product': productId});

  @override
  Future<void> logPurchaseFailed(String error) =>
      logEvent(AnalyticsEvents.purchaseFailed, {'error': error});

  @override
  Future<void> logRestorePurchase() => logEvent(AnalyticsEvents.restorePurchase);

  @override
  Future<void> logSubscriptionActive() => logEvent(AnalyticsEvents.subscriptionActive);
}
