import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:anu_meal_ai/core/constants/subscription_config.dart';
import 'package:anu_meal_ai/core/services/feature_access_service.dart';
import 'package:anu_meal_ai/core/services/premium_status_provider.dart';

class MockPremiumProvider implements PremiumStatusProvider {
  bool premiumValue;
  MockPremiumProvider(this.premiumValue);

  @override
  bool get isPremium => premiumValue;

  @override
  Stream<bool> get premiumChanges => Stream.value(premiumValue);
}

void main() {
  group('FeatureAccessService', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    test('free user can generate up to daily limit, then blocked', () async {
      final provider = MockPremiumProvider(false);
      final service = FeatureAccessService(premiumStatus: provider, prefs: prefs);

      expect(service.canGenerateRecipe(), isTrue);
      expect(service.remainingRecipeGenerationsToday(), equals(SubscriptionConfig.freeRecipeGenerationsPerDay));

      for (int i = 0; i < SubscriptionConfig.freeRecipeGenerationsPerDay; i++) {
        await service.recordRecipeGeneration();
      }

      expect(service.remainingRecipeGenerationsToday(), equals(0));
      expect(service.canGenerateRecipe(), isFalse);
    });

    test('premium user has unlimited recipe generations', () async {
      final provider = MockPremiumProvider(true);
      final service = FeatureAccessService(premiumStatus: provider, prefs: prefs);

      expect(service.canGenerateRecipe(), isTrue);
      expect(service.remainingRecipeGenerationsToday(), equals(-1)); // unlimited marker

      for (int i = 0; i < 10; i++) {
        await service.recordRecipeGeneration();
      }

      expect(service.canGenerateRecipe(), isTrue);
    });

    test('free user has weekly plan generation limit', () async {
      final provider = MockPremiumProvider(false);
      final service = FeatureAccessService(premiumStatus: provider, prefs: prefs);

      expect(service.canGenerateWeeklyPlan(), isTrue);
      await service.recordWeeklyPlanGeneration();
      expect(service.canGenerateWeeklyPlan(), isFalse);
    });
  });
}
