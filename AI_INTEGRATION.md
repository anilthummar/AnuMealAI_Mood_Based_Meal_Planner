# AI Integration Guide — AnuMealAI

AnuMealAI uses a resilient, dual-engine AI architecture to generate personalized, mood-based recipes.

---

## 1. Remote AI Backend Contract

The app communicates with an LLM backend (or server-side proxy) via standard JSON POST requests.

### Endpoint
`POST /api/v1/generate-recipes`

### Request Payload
```json
{
  "mood": "happy",
  "moodTraits": ["upbeat", "bright", "energizing"],
  "availableIngredients": ["Eggs", "Spinach", "Tomatoes", "Feta Cheese", "Olive Oil"],
  "mealType": "breakfast",
  "maxCookingTimeMinutes": 25,
  "dietaryRestrictions": ["vegetarian"],
  "favoriteCuisines": ["Mediterranean"],
  "count": 3
}
```

### Response Schema
```json
{
  "recipes": [
    {
      "id": "recipe-uuid-1",
      "title": "Mediterranean Spinach & Feta Scramble",
      "description": "Bright, fluffy eggs folded with tender baby spinach and tangy feta cheese.",
      "mood": "happy",
      "mealType": "breakfast",
      "prepTimeMinutes": 5,
      "cookTimeMinutes": 10,
      "difficulty": "Easy",
      "cuisine": "Mediterranean",
      "ingredients": [
        "3 large Eggs",
        "1 cup Baby Spinach",
        "2 tbsp Crumbled Feta Cheese",
        "1 tbsp Olive Oil",
        "Pinch of Black Pepper"
      ],
      "instructions": [
        "Whisk eggs with black pepper in a small bowl.",
        "Heat olive oil in a non-stick skillet over medium heat.",
        "Add spinach and cook for 1 minute until wilted.",
        "Pour in eggs and gently scramble with a spatula for 2-3 minutes.",
        "Remove from heat, top with crumbled feta, and serve immediately."
      ],
      "tips": [
        "Don't overcook the eggs; pull them off the heat while still slightly soft."
      ],
      "nutrition": {
        "calories": 320,
        "proteinGrams": 22,
        "carbsGrams": 4,
        "fatGrams": 24
      }
    }
  ]
}
```

---

## 2. Local Fallback Generator

If `AI_API_KEY` is not set or network connectivity is unavailable:
- The app uses `LocalRecipeGenerator` backed by `assets/data/recipe_templates.json`.
- Recipes are filtered and scored deterministically using `RecipeMatchCalculator`.
- Zero latency and 100% offline capability guaranteed.
