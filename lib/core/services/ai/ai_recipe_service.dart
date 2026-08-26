import 'ai_recipe_models.dart';

/// Abstraction over "something that turns a mood + ingredients + constraints
/// into recipe content" (§11). The app must never be tightly coupled to one
/// AI vendor — swap the implementation registered in the DI container
/// without touching any feature code.
///
/// Implementations must throw the typed exceptions from `core/errors` on
/// failure (never let a provider-specific exception escape) so the calling
/// repository can map them to a [Failure] and the UI can show a fallback
/// state instead of crashing.
abstract class AIRecipeService {
  Future<List<AiRecipeSuggestion>> generateRecipes(AiRecipeRequest request);
}
