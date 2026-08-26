import '../../constants/app_config.dart';
import '../../network/network_info.dart';
import 'ai_recipe_models.dart';
import 'ai_recipe_service.dart';
import 'local_recipe_generator.dart';
import 'remote_ai_recipe_service.dart';

/// The [AIRecipeService] registered in DI. Tries the remote, LLM-backed
/// service when it's configured and the device is online; falls back to the
/// local generator on any failure, on timeout, or when offline/unconfigured.
/// This is what makes §11's "never crash the app because AI failed" and
/// §30's offline behavior true without duplicating that logic in every
/// feature that calls the AI.
class ResilientAIRecipeService implements AIRecipeService {
  final RemoteAIRecipeService remote;
  final LocalRecipeGenerator local;
  final NetworkInfo networkInfo;

  ResilientAIRecipeService({
    required this.remote,
    required this.local,
    required this.networkInfo,
  });

  @override
  Future<List<AiRecipeSuggestion>> generateRecipes(AiRecipeRequest request) async {
    final remoteConfigured = AppConfig.aiApiKey.isNotEmpty;
    if (remoteConfigured && await networkInfo.isConnected) {
      try {
        final results = await remote.generateRecipes(request);
        if (results.isNotEmpty) return results;
      } catch (_) {
        // Fall through to the local generator — the caller never sees this.
      }
    }
    return local.generateRecipes(request);
  }
}
