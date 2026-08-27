import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:anu_meal_ai/core/services/analytics_service.dart';
import 'package:anu_meal_ai/core/services/feature_access_service.dart';
import 'package:anu_meal_ai/core/services/premium_status_provider.dart';
import 'package:anu_meal_ai/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:anu_meal_ai/features/meal_planner/domain/entities/meal_plan_entry.dart';
import 'package:anu_meal_ai/features/meal_planner/domain/entities/weekly_meal_plan.dart';
import 'package:anu_meal_ai/features/meal_planner/domain/repositories/meal_planner_repository.dart';
import 'package:anu_meal_ai/features/meal_planner/presentation/bloc/meal_planner_cubit.dart';
import 'package:anu_meal_ai/features/meal_planner/presentation/bloc/meal_planner_state.dart';
import 'package:anu_meal_ai/features/recipes/domain/entities/recipe.dart';
import 'package:anu_meal_ai/features/recipes/domain/repositories/recipe_repository.dart';
import 'package:anu_meal_ai/features/recipes/presentation/bloc/recipe_cubit.dart';
import 'package:anu_meal_ai/features/recipes/presentation/bloc/recipe_state.dart';
import 'package:anu_meal_ai/features/remote_config/domain/entities/remote_config_entity.dart';
import 'package:anu_meal_ai/features/remote_config/domain/repositories/remote_config_repository.dart';
import 'package:anu_meal_ai/features/shopping_list/domain/repositories/shopping_list_repository.dart';
import 'package:anu_meal_ai/features/shopping_list/presentation/bloc/shopping_list_cubit.dart';
import 'package:anu_meal_ai/features/shopping_list/domain/entities/shopping_item.dart';
import 'package:anu_meal_ai/features/subscription/domain/repositories/subscription_repository.dart';

class MockAnalyticsService extends Mock implements AnalyticsService {}

class MockRecipeRepository extends Mock implements RecipeRepository {}

class MockMealPlannerRepository extends Mock implements MealPlannerRepository {}

class MockFavoritesRepository extends Mock implements FavoritesRepository {}

class MockShoppingListRepository extends Mock
    implements ShoppingListRepository {}

class MockRemoteConfigRepository extends Mock
    implements RemoteConfigRepository {}

class MockSubscriptionRepository extends Mock
    implements SubscriptionRepository {}

class FakePremiumStatusProvider implements PremiumStatusProvider {
  bool premium = false;
  @override
  bool get isPremium => premium;
  @override
  Stream<bool> get premiumChanges => Stream.value(premium);
}

class FakeShoppingItem extends Fake implements ShoppingItem {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(FakeShoppingItem());
  });

  late SharedPreferences prefs;
  late MockAnalyticsService mockAnalytics;
  late FakePremiumStatusProvider fakePremiumProvider;
  late MockRemoteConfigRepository mockRemoteConfig;
  late FeatureAccessService featureAccess;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    mockAnalytics = MockAnalyticsService();
    fakePremiumProvider = FakePremiumStatusProvider();
    mockRemoteConfig = MockRemoteConfigRepository();

    when(
      () => mockRemoteConfig.getCachedConfig(),
    ).thenReturn(RemoteConfigEntity.fallback());
    when(
      () => mockAnalytics.logRecipeGenerated(any(), any()),
    ).thenAnswer((_) async {});
    when(
      () => mockAnalytics.logMealPlanGenerated(any()),
    ).thenAnswer((_) async {});
    when(
      () => mockAnalytics.logRecipeFavorited(any(), any()),
    ).thenAnswer((_) async {});
    when(
      () => mockAnalytics.logShoppingItemAdded(any()),
    ).thenAnswer((_) async {});

    featureAccess = FeatureAccessService(
      premiumStatus: fakePremiumProvider,
      prefs: prefs,
      remoteConfigRepository: mockRemoteConfig,
    );
  });

  group('Production Business Logic & Subscription Gating Tests', () {
    test(
      'Free tier respects daily recipe limit (3) and gates correctly',
      () async {
        expect(featureAccess.canGenerateRecipe(), isTrue);
        expect(featureAccess.remainingRecipeGenerationsToday(), 3);

        await featureAccess.recordRecipeGeneration();
        expect(featureAccess.remainingRecipeGenerationsToday(), 2);

        await featureAccess.recordRecipeGeneration();
        expect(featureAccess.remainingRecipeGenerationsToday(), 1);

        await featureAccess.recordRecipeGeneration();
        expect(featureAccess.remainingRecipeGenerationsToday(), 0);
        expect(featureAccess.canGenerateRecipe(), isFalse);
      },
    );

    test(
      'Free tier respects weekly plan limit (1) and gates correctly',
      () async {
        expect(featureAccess.canGenerateWeeklyPlan(), isTrue);

        await featureAccess.recordWeeklyPlanGeneration();
        expect(featureAccess.canGenerateWeeklyPlan(), isFalse);
      },
    );

    test(
      'In-App Purchase / Promo unlock unlocks unlimited access across all modules',
      () async {
        // Free state: limits exhausted
        await featureAccess.recordRecipeGeneration();
        await featureAccess.recordRecipeGeneration();
        await featureAccess.recordRecipeGeneration();
        await featureAccess.recordWeeklyPlanGeneration();

        expect(featureAccess.canGenerateRecipe(), isFalse);
        expect(featureAccess.canGenerateWeeklyPlan(), isFalse);
        expect(featureAccess.canSaveRecipe(25), isFalse);

        // User purchases / unlocks Premium!
        fakePremiumProvider.premium = true;

        // Premium state: all limits completely bypassed
        expect(featureAccess.isPremium, isTrue);
        expect(featureAccess.canGenerateRecipe(), isTrue);
        expect(
          featureAccess.remainingRecipeGenerationsToday(),
          -1,
        ); // Unlimited
        expect(featureAccess.canGenerateWeeklyPlan(), isTrue);
        expect(featureAccess.canSaveRecipe(100), isTrue);
      },
    );
  });

  group('Recipe & Meal Planner State Flow Under Free & Pro Tiers', () {
    late MockRecipeRepository mockRecipeRepo;
    late MockMealPlannerRepository mockMealPlanRepo;

    const dummyRecipe = Recipe(
      id: 'rec_1',
      title: 'Avocado Toast & Poached Egg',
      description: 'Healthy energy breakfast',
      mood: 'energetic',
      mealType: 'breakfast',
      prepTimeMinutes: 10,
      cookTimeMinutes: 10,
      difficulty: 'Easy',
      matchPercentage: 95,
      ingredients: ['Eggs', 'Avocado', 'Sourdough Bread'],
      missingIngredients: [],
      instructions: ['Toast bread', 'Poach eggs', 'Mash avocado and assemble'],
      nutrition: {'calories': 320, 'protein': 15, 'carbs': 28, 'fat': 16},
    );

    final dummyPlan = WeeklyMealPlan(
      id: 'plan_1',
      weekStartDate: DateTime.now(),
      createdAt: DateTime.now(),
      entries: const [
        MealPlanEntry(
          id: 'm1',
          dayOfWeek: 'Monday',
          mealSlot: 'Breakfast',
          recipe: dummyRecipe,
        ),
      ],
    );

    setUp(() {
      mockRecipeRepo = MockRecipeRepository();
      mockMealPlanRepo = MockMealPlannerRepository();

      when(
        () => mockMealPlanRepo.currentPlanStream,
      ).thenAnswer((_) => Stream.value(dummyPlan));
      when(
        () => mockMealPlanRepo.getCurrentWeekPlan(),
      ).thenAnswer((_) async => dummyPlan);
      when(
        () => mockMealPlanRepo.generateWeeklyPlan(
          moodId: any(named: 'moodId'),
          moodTraits: any(named: 'moodTraits'),
          availableIngredients: any(named: 'availableIngredients'),
          dietaryRestrictions: any(named: 'dietaryRestrictions'),
          favoriteCuisines: any(named: 'favoriteCuisines'),
        ),
      ).thenAnswer((_) async => dummyPlan);
      when(
        () => mockRecipeRepo.generateRecipes(
          moodId: any(named: 'moodId'),
          moodTraits: any(named: 'moodTraits'),
          availableIngredients: any(named: 'availableIngredients'),
          mealType: any(named: 'mealType'),
          maxCookingTimeMinutes: any(named: 'maxCookingTimeMinutes'),
          dietaryPreferences: any(named: 'dietaryPreferences'),
          cuisinePreferences: any(named: 'cuisinePreferences'),
        ),
      ).thenAnswer((_) async => [dummyRecipe]);
    });

    test(
      'RecipeCubit generates recipes on Free tier up to limit, then emits DAILY_LIMIT_REACHED',
      () async {
        final cubit = RecipeCubit(
          recipeRepository: mockRecipeRepo,
          featureAccess: featureAccess,
          analytics: mockAnalytics,
        );

        // 1st generation
        var ok = await cubit.generateRecipes(
          moodId: 'energetic',
          moodTraits: ['fresh'],
          availableIngredients: ['Eggs', 'Avocado'],
        );
        expect(ok, isTrue);
        expect(cubit.state.status, RecipeStatus.loaded);
        expect(cubit.state.generatedRecipes, isNotEmpty);

        // 2nd generation
        ok = await cubit.generateRecipes(
          moodId: 'energetic',
          moodTraits: ['fresh'],
          availableIngredients: ['Eggs', 'Avocado'],
        );
        expect(ok, isTrue);

        // 3rd generation
        ok = await cubit.generateRecipes(
          moodId: 'energetic',
          moodTraits: ['fresh'],
          availableIngredients: ['Eggs', 'Avocado'],
        );
        expect(ok, isTrue);

        // 4th generation -> BLOCKED by quota
        ok = await cubit.generateRecipes(
          moodId: 'energetic',
          moodTraits: ['fresh'],
          availableIngredients: ['Eggs', 'Avocado'],
        );
        expect(ok, isFalse);
        expect(cubit.state.status, RecipeStatus.error);
        expect(cubit.state.errorMessage, 'DAILY_LIMIT_REACHED');

        // User upgrades to Pro!
        fakePremiumProvider.premium = true;

        // 5th generation -> UNBLOCKED and successful!
        ok = await cubit.generateRecipes(
          moodId: 'energetic',
          moodTraits: ['fresh'],
          availableIngredients: ['Eggs', 'Avocado'],
        );
        expect(ok, isTrue);
        expect(cubit.state.status, RecipeStatus.loaded);
      },
    );

    test(
      'MealPlannerCubit enforces weekly limit on Free tier and unblocks on Pro',
      () async {
        final cubit = MealPlannerCubit(
          mealPlannerRepository: mockMealPlanRepo,
          featureAccess: featureAccess,
          analytics: mockAnalytics,
        );

        // 1st weekly plan generation
        var ok = await cubit.generateWeekPlan(
          moodId: 'happy',
          moodTraits: ['sunny'],
          availableIngredients: ['Eggs', 'Bread'],
        );
        expect(ok, isTrue);
        expect(cubit.state.status, MealPlannerStatus.loaded);

        // 2nd weekly plan generation -> BLOCKED on Free tier
        ok = await cubit.generateWeekPlan(
          moodId: 'happy',
          moodTraits: ['sunny'],
          availableIngredients: ['Eggs', 'Bread'],
        );
        expect(ok, isFalse);
        expect(cubit.state.errorMessage, 'PLAN_LIMIT_REACHED');

        // User upgrades to Pro!
        fakePremiumProvider.premium = true;

        // Next generation -> UNBLOCKED!
        ok = await cubit.generateWeekPlan(
          moodId: 'happy',
          moodTraits: ['sunny'],
          availableIngredients: ['Eggs', 'Bread'],
        );
        expect(ok, isTrue);
        expect(cubit.state.status, MealPlannerStatus.loaded);
      },
    );
  });

  group('Smart Shopping List & Missing Ingredients Sync Tests', () {
    late MockShoppingListRepository mockShoppingRepo;

    setUp(() {
      mockShoppingRepo = MockShoppingListRepository();
      when(
        () => mockShoppingRepo.itemsStream,
      ).thenAnswer((_) => Stream.value([]));
      when(() => mockShoppingRepo.getItems()).thenAnswer((_) async => []);
      when(() => mockShoppingRepo.addItem(any())).thenAnswer((_) async {});
      when(
        () => mockShoppingRepo.addMissingIngredients(
          missingIngredients: any(named: 'missingIngredients'),
          recipeTitle: any(named: 'recipeTitle'),
        ),
      ).thenAnswer((_) async {});
    });

    test(
      'ShoppingListCubit seamlessly adds recipe ingredients to shopping list',
      () async {
        final cubit = ShoppingListCubit(
          shoppingListRepository: mockShoppingRepo,
          analytics: mockAnalytics,
        );

        await cubit.addMissingIngredientsFromRecipe(
          missingIngredients: ['Avocado', 'Sourdough Bread'],
          recipeTitle: 'Avocado Toast',
        );

        verify(
          () => mockShoppingRepo.addMissingIngredients(
            missingIngredients: ['Avocado', 'Sourdough Bread'],
            recipeTitle: 'Avocado Toast',
          ),
        ).called(1);
      },
    );
  });
}
