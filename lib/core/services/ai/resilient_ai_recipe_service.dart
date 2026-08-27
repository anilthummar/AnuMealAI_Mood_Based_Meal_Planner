import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

import '../../constants/app_config.dart';
import '../../constants/remote_config_keys.dart';
import '../../network/network_info.dart';
import 'ai_recipe_models.dart';
import 'ai_recipe_service.dart';
import 'gemini_ai_recipe_service.dart';
import 'local_recipe_generator.dart';

/// The [AIRecipeService] registered in DI.
/// Automatically pulls Gemini API keys and configurations dynamically from
/// Firebase Remote Config, with built-in local offline fallback.
class ResilientAIRecipeService implements AIRecipeService {
  final GeminiAiRecipeService gemini;
  final LocalRecipeGenerator local;
  final NetworkInfo networkInfo;
  final FirebaseRemoteConfig? remoteConfig;

  // In-flight deduplication map: prevents duplicate concurrent requests
  final Map<String, Future<List<AiRecipeSuggestion>>> _inFlightRequests = {};

  // Short-lived memory cache (5-minute TTL) for identical requests
  final Map<String, _CachedAiResponse> _cache = {};

  ResilientAIRecipeService({
    required this.gemini,
    required this.local,
    required this.networkInfo,
    this.remoteConfig,
  });

  /// Resolves the active Gemini API key from Firebase Remote Config or AppConfig
  String? get resolvedGeminiApiKey {
    // 1. Firebase Remote Config key (dynamic cloud management)
    if (remoteConfig != null) {
      try {
        final remoteKey = remoteConfig!
            .getString(RemoteConfigKeys.geminiApiKey)
            .trim();
        if (remoteKey.isNotEmpty) {
          return remoteKey;
        }
      } catch (_) {}
    }

    // 2. AppConfig default / compile-time define
    if (AppConfig.geminiApiKey.trim().isNotEmpty) {
      return AppConfig.geminiApiKey.trim();
    }

    return null;
  }

  /// Resolves the active Gemini model from Firebase Remote Config or AppConfig
  String get resolvedGeminiModel {
    if (remoteConfig != null) {
      try {
        final remoteModel = remoteConfig!
            .getString(RemoteConfigKeys.geminiModel)
            .trim();
        if (remoteModel.isNotEmpty) {
          return remoteModel;
        }
      } catch (_) {}
    }
    return AppConfig.geminiModel;
  }

  String _generateRequestKey(AiRecipeRequest request) {
    final sortedIngredients = List<String>.from(request.availableIngredients)..sort();
    final sortedTraits = List<String>.from(request.moodTraits)..sort();
    return '${request.moodId}_${request.mealType}_${request.maxCookingTimeMinutes}_${sortedTraits.join(",")}_${sortedIngredients.join(",")}';
  }

  @override
  Future<List<AiRecipeSuggestion>> generateRecipes(
    AiRecipeRequest request,
  ) async {
    final cacheKey = _generateRequestKey(request);

    // 1. Return from memory cache if fresh (< 5 mins)
    final cached = _cache[cacheKey];
    if (cached != null && !cached.isExpired) {
      debugPrint('[ResilientAIRecipeService] Serving cached recipe suggestions.');
      return cached.recipes;
    }

    // 2. If an identical request is currently in flight, await that existing Future
    if (_inFlightRequests.containsKey(cacheKey)) {
      debugPrint('[ResilientAIRecipeService] Awaiting existing in-flight AI request.');
      return _inFlightRequests[cacheKey]!;
    }

    final future = _executeGeneration(request);
    _inFlightRequests[cacheKey] = future;

    try {
      final results = await future;
      if (results.isNotEmpty) {
        _cache[cacheKey] = _CachedAiResponse(
          recipes: results,
          expiry: DateTime.now().add(const Duration(minutes: 5)),
        );
      }
      return results;
    } finally {
      _inFlightRequests.remove(cacheKey);
    }
  }

  Future<List<AiRecipeSuggestion>> _executeGeneration(AiRecipeRequest request) async {
    final isOnline = await networkInfo.isConnected;

    // 1. Attempt Direct Google Gemini Live AI via Remote Config Key
    if (isOnline) {
      final geminiKey = resolvedGeminiApiKey;
      final geminiModel = resolvedGeminiModel;
      if (geminiKey != null && geminiKey.isNotEmpty) {
        try {
          debugPrint(
            '[ResilientAIRecipeService] Generating recipes via Google Gemini AI ($geminiModel)...',
          );
          final results = await gemini.generateRecipes(
            request,
            overrideApiKey: geminiKey,
            overrideModel: geminiModel,
          );
          if (results.isNotEmpty) {
            debugPrint(
              '[ResilientAIRecipeService] Successfully received ${results.length} recipes from Gemini.',
            );
            return results;
          }
        } catch (e) {
          debugPrint(
            '[ResilientAIRecipeService] Gemini AI attempt note: $e. Falling back to local engine.',
          );
        }
      }
    }

    // 2. Resilient Fallback to Built-in Local AI Engine (100% offline, 0 downtime)
    debugPrint('[ResilientAIRecipeService] Using built-in local AI generator.');
    return local.generateRecipes(request);
  }
}

class _CachedAiResponse {
  final List<AiRecipeSuggestion> recipes;
  final DateTime expiry;

  _CachedAiResponse({required this.recipes, required this.expiry});

  bool get isExpired => DateTime.now().isAfter(expiry);
}
