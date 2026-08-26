import 'dart:convert';

import 'package:dio/dio.dart';

import '../../errors/exceptions.dart';
import 'ai_recipe_models.dart';
import 'ai_recipe_service.dart';

/// Calls a configurable HTTP endpoint (a server-side proxy in front of
/// whichever LLM provider you choose — OpenAI, Anthropic, etc.) and parses
/// the structured JSON schema documented in `AI_INTEGRATION.md`:
///
/// ```json
/// { "recipes": [ { "title": "...", "ingredients": [...], ... } ] }
/// ```
///
/// This class is the *only* place that knows an HTTP AI backend exists.
/// Everything above it — repositories, use cases, cubits, widgets — talks to
/// the [AIRecipeService] interface only.
class RemoteAIRecipeService implements AIRecipeService {
  final Dio dio;

  RemoteAIRecipeService(this.dio);

  @override
  Future<List<AiRecipeSuggestion>> generateRecipes(AiRecipeRequest request) async {
    try {
      final response = await dio.post('/v1/recipes/generate', data: request.toJson());
      final body = response.data;
      final Map<String, dynamic> json = body is String
          ? Map<String, dynamic>.from(_decodeOrThrow(body))
          : Map<String, dynamic>.from(body as Map);

      final recipes = json['recipes'];
      if (recipes is! List || recipes.isEmpty) {
        throw const AiParsingException('AI response contained no recipes.');
      }
      return recipes
          .map((e) => AiRecipeSuggestion.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } on FormatException catch (e) {
      throw AiParsingException(e.message);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw const AiTimeoutException();
      }
      if (e.response?.statusCode == 429) {
        throw const AiRateLimitException();
      }
      throw ServerException(e.message ?? 'AI request failed.', e.response?.statusCode);
    }
  }

  Map<String, dynamic> _decodeOrThrow(String raw) {
    if (raw.isEmpty) return const {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
      throw const AiParsingException('AI response body was not a JSON object.');
    } on FormatException {
      throw const AiParsingException('Could not parse AI response body.');
    }
  }
}
