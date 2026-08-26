/// Single source of truth for subscription product/entitlement identifiers
/// and free-tier limits for AnuMealAI.
class SubscriptionConfig {
  SubscriptionConfig._();

  /// Primary RevenueCat entitlement identifier configured in the RevenueCat dashboard.
  static const String premiumEntitlementId = 'anumealai_pro';

  /// Fallback entitlement identifiers supported for backward/forward compatibility.
  static const List<String> entitlementIds = [
    'anumealai_pro',
    'premium',
    'pro',
    'premium_access',
  ];

  /// RevenueCat product / package identifiers
  static const String monthlyProductId = 'monthly';
  static const String yearlyProductId = 'yearly';

  static const List<String> monthlyProductIds = ['monthly', 'anu_meal_ai_monthly'];
  static const List<String> yearlyProductIds = ['yearly', 'anu_meal_ai_yearly'];

  /// Free-tier limits. Premium bypasses all of these (see FeatureAccessService).
  static const int freeRecipeGenerationsPerDay = 3;
  static const int freeWeeklyPlanGenerationsPerWeek = 1;
  static const int freeSavedRecipesLimit = 10;
}
