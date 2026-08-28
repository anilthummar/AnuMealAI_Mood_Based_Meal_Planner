import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../constants/app_config.dart';
import '../../errors/exceptions.dart';
import 'ai_recipe_models.dart';
import 'ai_recipe_service.dart';

/// Direct Google Gemini API implementation of [AIRecipeService].
/// Uses Google's Gemini 1.5/2.0 Flash models with structured JSON generation.
class GeminiAiRecipeService implements AIRecipeService {
  final Dio dio;
  final String? defaultApiKey;
  final String? defaultModel;

  GeminiAiRecipeService({
    required this.dio,
    this.defaultApiKey,
    this.defaultModel,
  });

  @override
  Future<List<AiRecipeSuggestion>> generateRecipes(
    AiRecipeRequest request, {
    String? overrideApiKey,
    String? overrideModel,
  }) async {
    final apiKey =
        overrideApiKey ??
        (defaultApiKey != null && defaultApiKey!.isNotEmpty
            ? defaultApiKey
            : AppConfig.geminiApiKey);

    if (apiKey == null || apiKey.trim().isEmpty) {
      throw const ServerException('Gemini API key is not configured.', 401);
    }

    final model =
        overrideModel ??
        (defaultModel != null && defaultModel!.isNotEmpty
            ? defaultModel
            : AppConfig.geminiModel);

    final url =
        'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=${apiKey.trim()}';

    final prompt = _buildPrompt(request);

    final payload = {
      'contents': [
        {
          'role': 'user',
          'parts': [
            {'text': prompt},
          ],
        },
      ],
      'generationConfig': {
        'responseMimeType': 'application/json',
        'temperature': 0.75,
        'topP': 0.95,
      },
    };

    try {
      final response = await dio.post(
        url,
        data: payload,
        options: Options(
          headers: {'Content-Type': 'application/json'},
          sendTimeout: const Duration(seconds: 4),
          receiveTimeout: const Duration(seconds: 6),
        ),
      );

      final data = response.data;
      if (data is! Map) {
        throw const AiParsingException(
          'Unexpected response format from Gemini.',
        );
      }

      final candidates = data['candidates'];
      if (candidates is! List || candidates.isEmpty) {
        throw const AiParsingException('Gemini returned no candidates.');
      }

      final content = candidates[0]['content'];
      if (content is! Map) {
        throw const AiParsingException('Missing candidate content.');
      }

      final parts = content['parts'];
      if (parts is! List || parts.isEmpty) {
        throw const AiParsingException('Missing candidate parts.');
      }

      final text = parts[0]['text'];
      if (text is! String || text.trim().isEmpty) {
        throw const AiParsingException('Empty response text from Gemini.');
      }

      final Map<String, dynamic> parsedJson = _decodeJson(text);
      final recipesList = parsedJson['recipes'];
      if (recipesList is! List || recipesList.isEmpty) {
        throw const AiParsingException(
          'Gemini JSON did not contain a valid recipes array.',
        );
      }

      return recipesList
          .map(
            (e) => AiRecipeSuggestion.fromJson(
              Map<String, dynamic>.from(e as Map),
            ),
          )
          .toList();
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw const AiTimeoutException();
      }
      if (e.response?.statusCode == 429) {
        throw const AiRateLimitException();
      }
      debugPrint(
        '[GeminiAiRecipeService] DioException: ${e.response?.statusCode} - ${e.response?.data}',
      );
      throw ServerException(
        e.message ?? 'Gemini API call failed.',
        e.response?.statusCode,
      );
    } catch (e) {
      if (e is ServerException ||
          e is AiTimeoutException ||
          e is AiRateLimitException ||
          e is AiParsingException) {
        rethrow;
      }
      debugPrint('[GeminiAiRecipeService] Error: $e');
      throw AiParsingException(e.toString());
    }
  }

  String _buildPrompt(AiRecipeRequest request) {
    final ingredientsList = request.availableIngredients.isNotEmpty
        ? request.availableIngredients.join(', ')
        : 'Any standard pantry ingredients';

    final dietary = request.dietaryPreferences.isNotEmpty
        ? request.dietaryPreferences.join(', ')
        : 'None';

    final cuisines = request.cuisinePreferences.isNotEmpty
        ? request.cuisinePreferences.join(', ')
        : 'Any';

    final traits = request.moodTraits.isNotEmpty
        ? request.moodTraits.join(', ')
        : 'uplifting and delicious';

    return '''
You are the Master AI Executive Chef for the AnuMealAI app.
Generate exactly ${request.count} creative, delicious, and realistic recipes tailored to the user's current mood and available ingredients.

### User Constraints:
- Current Mood: "${request.moodId}" (Emotional traits: $traits)
- Meal Type: ${request.mealType}
- Maximum Total Cooking Time: ${request.maxCookingTimeMinutes} minutes
- Available Pantry Ingredients (prioritize using these): $ingredientsList
- Dietary Restrictions: $dietary
- Preferred Cuisines: $cuisines

### Output Instructions:
You MUST respond with a JSON object strictly matching this schema:
{
  "recipes": [
    {
      "title": "Creative and appetizing recipe name",
      "description": "2-3 sentences describing the dish, flavor notes, and why it matches the mood.",
      "mood": "${request.moodId}",
      "mealType": "${request.mealType}",
      "prepTimeMinutes": 5,
      "cookTimeMinutes": 15,
      "difficulty": "Easy",
      "cuisine": "Cuisine style (e.g. Italian, Mexican, Asian, American, Mediterranean)",
      "ingredients": [
        "Quantity and ingredient 1",
        "Quantity and ingredient 2"
      ],
      "instructions": [
        "Step 1 action",
        "Step 2 action"
      ],
      "tips": [
        "Chef's pro-tip for optimal flavor"
      ],
      "nutrition": {
        "calories": 420,
        "proteinGrams": 24,
        "carbsGrams": 40,
        "fatGrams": 14
      }
    }
  ]
}
''';
  }

  Map<String, dynamic> _decodeJson(String raw) {
    final clean = raw.trim();
    // Strip markdown code fences if model enclosed JSON in ```json ... ```
    String jsonStr = clean;
    if (clean.startsWith('```')) {
      final lines = clean.split('\n');
      if (lines.length > 2) {
        jsonStr = lines.sublist(1, lines.length - 1).join('\n').trim();
      }
    }
    final decoded = jsonDecode(jsonStr);
    if (decoded is Map) {
      return Map<String, dynamic>.from(decoded);
    }
    throw const FormatException('Expected JSON Object.');
  }
}
