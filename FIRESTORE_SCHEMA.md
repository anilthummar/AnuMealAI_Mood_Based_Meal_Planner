# AnuMealAI — Cloud Firestore Schema Specification

All user-generated documents in AnuMealAI are partitioned by authenticated Firebase UID (`request.auth.uid`) to guarantee multi-tenant security and immediate data deletion compliance.

---

## 1. Hierarchy Overview

```
users/{userId}
   ├── profile (Document)
   ├── preferences (Document)
   ├── ingredients (Subcollection)
   │     └── {ingredientId} (Document)
   ├── favorites (Subcollection)
   │     └── {recipeId} (Document)
   ├── shopping_items (Subcollection)
   │     └── {itemId} (Document)
   ├── meal_plans (Subcollection)
   │     └── {planId} (Document)
   └── meal_feedback (Subcollection)
         └── {feedbackId} (Document)
```

---

## 2. Document Schemas

### `users/{userId}` (Root User Document)
```json
{
  "uid": "string",
  "email": "string",
  "displayName": "string",
  "photoUrl": "string|null",
  "isAnonymous": false,
  "createdAt": "Timestamp",
  "updatedAt": "Timestamp",
  "lastLoginAt": "Timestamp"
}
```

### `users/{userId}/preferences`
```json
{
  "dietaryPreferences": ["vegetarian", "low-carb"],
  "allergies": ["peanuts", "shellfish"],
  "cuisinePreferences": ["Italian", "Mexican", "Asian"],
  "cookingSkillLevel": "intermediate",
  "typicalCookingTimeMinutes": 30,
  "notificationsEnabled": true,
  "updatedAt": "Timestamp"
}
```

### `users/{userId}/ingredients/{ingredientId}`
```json
{
  "id": "string",
  "name": "Olive Oil",
  "category": "Oils & Vinegars",
  "quantity": 1.0,
  "unit": "bottle",
  "addedAt": "Timestamp",
  "expiresAt": "Timestamp|null"
}
```

### `users/{userId}/favorites/{recipeId}`
```json
{
  "id": "string",
  "title": "Creamy Tuscan Garlic Chicken",
  "moodId": "comfort",
  "prepTimeMinutes": 15,
  "cookTimeMinutes": 25,
  "calories": 480,
  "proteinGrams": 42,
  "carbGrams": 12,
  "fatGrams": 28,
  "ingredients": ["chicken breast", "heavy cream", "garlic", "spinach", "sun-dried tomatoes"],
  "instructions": ["Sear chicken", "Saute garlic and spinach", "Simmer cream sauce", "Combine and serve"],
  "favoritedAt": "Timestamp",
  "customNotes": "Pairs amazingly with whole wheat pasta."
}
```

### `users/{userId}/shopping_items/{itemId}`
```json
{
  "id": "string",
  "name": "Fresh Rosemary",
  "category": "Produce",
  "quantity": 1,
  "unit": "bunch",
  "isChecked": false,
  "recipeSourceId": "recipe_123",
  "createdAt": "Timestamp"
}
```

### `users/{userId}/meal_plans/{planId}`
```json
{
  "id": "string",
  "dayOfWeek": "Monday",
  "mealType": "dinner",
  "recipeId": "recipe_123",
  "recipeTitle": "Creamy Tuscan Garlic Chicken",
  "scheduledDate": "2026-08-27",
  "createdAt": "Timestamp"
}
```

---

## 3. Cascading Account Deletion
When a user initiates **Delete Account** (§44), the client and Cloud Functions recursively delete all subcollections (`ingredients`, `favorites`, `shopping_items`, `meal_plans`, `meal_feedback`) before deleting `users/{userId}` and the Firebase Auth account.

