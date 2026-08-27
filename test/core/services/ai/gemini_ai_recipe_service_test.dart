import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:anu_meal_ai/core/network/network_info.dart';
import 'package:anu_meal_ai/core/services/ai/ai_recipe_models.dart';
import 'package:anu_meal_ai/core/services/ai/gemini_ai_recipe_service.dart';
import 'package:anu_meal_ai/core/services/ai/local_recipe_generator.dart';
import 'package:anu_meal_ai/core/services/ai/resilient_ai_recipe_service.dart';

class MockDio extends Mock implements Dio {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockDio mockDio;
  late MockNetworkInfo mockNetworkInfo;
  late LocalRecipeGenerator localGenerator;
  late GeminiAiRecipeService geminiService;

  const testRequest = AiRecipeRequest(
    moodId: 'energetic',
    moodTraits: ['vibrant', 'quick'],
    availableIngredients: ['Eggs', 'Avocado', 'Sourdough Bread'],
    mealType: 'breakfast',
    maxCookingTimeMinutes: 20,
    dietaryPreferences: ['vegetarian'],
    cuisinePreferences: ['California'],
    count: 1,
  );

  setUp(() {
    mockDio = MockDio();
    mockNetworkInfo = MockNetworkInfo();
    localGenerator = LocalRecipeGenerator();
    geminiService = GeminiAiRecipeService(
      dio: mockDio,
      defaultApiKey: 'test_key_123',
    );
  });

  group('GeminiAiRecipeService Tests', () {
    test(
      'successfully parses structured JSON from Google Gemini response',
      () async {
        final geminiResponsePayload = {
          'candidates': [
            {
              'content': {
                'parts': [
                  {
                    'text': '''
                  {
                    "recipes": [
                      {
                        "title": "Avocado & Sunny Egg Toast",
                        "description": "Crispy toasted sourdough topped with mashed seasoned avocado and a golden sunny egg.",
                        "mood": "energetic",
                        "mealType": "breakfast",
                        "prepTimeMinutes": 5,
                        "cookTimeMinutes": 10,
                        "difficulty": "Easy",
                        "cuisine": "California",
                        "ingredients": ["2 Eggs", "1 Avocado", "2 slices Sourdough Bread", "Salt & Pepper"],
                        "instructions": ["Toast bread.", "Mash avocado with seasoning.", "Fry eggs.", "Assemble and enjoy!"],
                        "tips": ["Add chili flakes for extra zest."],
                        "nutrition": {
                          "calories": 380,
                          "proteinGrams": 16,
                          "carbsGrams": 32,
                          "fatGrams": 20
                        }
                      }
                    ]
                  }
                  ''',
                  },
                ],
              },
            },
          ],
        };

        when(
          () => mockDio.post(
            any(),
            data: any(named: 'data'),
            options: any(named: 'options'),
          ),
        ).thenAnswer(
          (_) async => Response(
            data: geminiResponsePayload,
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        final result = await geminiService.generateRecipes(testRequest);

        expect(result.length, 1);
        expect(result.first.title, 'Avocado & Sunny Egg Toast');
        expect(result.first.mealType, 'breakfast');
        expect(result.first.ingredients.length, 4);
        expect(result.first.nutrition['calories'], 380);
      },
    );
  });

  group('ResilientAIRecipeService Multi-Engine Fallback Tests', () {
    test('falls back to local generator seamlessly when offline', () async {
      SharedPreferences.setMockInitialValues({});

      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);

      final resilientService = ResilientAIRecipeService(
        gemini: geminiService,
        local: localGenerator,
        networkInfo: mockNetworkInfo,
      );

      final result = await resilientService.generateRecipes(testRequest);

      expect(result, isNotEmpty);
      expect(result.first.title, isNotEmpty);
    });

    test(
      'falls back to local generator if Gemini network call fails',
      () async {
        SharedPreferences.setMockInitialValues({
          'custom_gemini_api_key': 'test_key',
        });

        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(
          () => mockDio.post(
            any(),
            data: any(named: 'data'),
            options: any(named: 'options'),
          ),
        ).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: ''),
            type: DioExceptionType.connectionTimeout,
          ),
        );

        final resilientService = ResilientAIRecipeService(
          gemini: geminiService,
          local: localGenerator,
          networkInfo: mockNetworkInfo,
        );

        final result = await resilientService.generateRecipes(testRequest);

        expect(result, isNotEmpty);
        expect(result.first.title, isNotEmpty);
      },
    );
  });
}
