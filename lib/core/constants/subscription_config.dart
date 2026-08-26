/// Single source of truth for subscription product/entitlement identifiers
/// and free-tier limits. No other file in the app should hardcode a limit or
/// a RevenueCat identifier — read them from here so pricing/limit changes are
/// a one-file edit.
class SubscriptionConfig {
  SubscriptionConfig._();

  /// RevenueCat entitlement identifier configured in the RevenueCat dashboard.
  static const String premiumEntitlementId = 'premium';

  /// RevenueCat product identifiers — configure matching products in App
  /// Store Connect / Google Play Console and attach them to the entitlement
  /// above via a RevenueCat Offering.
  static const String monthlyProductId = 'anu_meal_ai_monthly';
  static const String yearlyProductId = 'anu_meal_ai_yearly';

  /// Free-tier limits. Premium bypasses all of these (see FeatureAccessService).
  static const int freeRecipeGenerationsPerDay = 3;
  static const int freeWeeklyPlanGenerationsPerWeek = 1;
  static const int freeSavedRecipesLimit = 10;
}
