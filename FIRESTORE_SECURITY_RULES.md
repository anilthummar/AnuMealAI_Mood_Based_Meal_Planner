# AnuMealAI — Production Firestore Security Rules

Deploy these security rules to ensure complete user data isolation and satisfy Google Play & Apple App Store privacy compliance requirements.

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Helper functions
    function isAuthenticated() {
      return request.auth != null;
    }

    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }

    // Disallow root collection wide reads/writes
    match /{document=**} {
      allow read, write: if false;
    }

    // User Profile, Preferences & Subcollections
    match /users/{userId} {
      // User can read and write only their own root profile
      allow read, write: if isOwner(userId);

      // User Preferences
      match /preferences/{docId} {
        allow read, write: if isOwner(userId);
      }

      // Pantry Ingredients
      match /ingredients/{ingredientId} {
        allow read, write: if isOwner(userId);
      }

      // Favorite Recipes
      match /favorites/{recipeId} {
        allow read, write: if isOwner(userId);
      }

      // Shopping List Items
      match /shopping_items/{itemId} {
        allow read, write: if isOwner(userId);
      }

      // Weekly Meal Plans
      match /meal_plans/{planId} {
        allow read, write: if isOwner(userId);
      }

      // Meal Feedback / Cooking History
      match /meal_feedback/{feedbackId} {
        allow read, write: if isOwner(userId);
      }
    }

    // Public / Shared Recipes (Read-only catalog for community/trending recipes)
    match /public_recipes/{recipeId} {
      allow read: if isAuthenticated();
      allow write: if false; // Managed exclusively via Cloud Functions or Admin SDK
    }
  }
}
```

## How to Deploy via Firebase CLI:
```bash
firebase deploy --only firestore:rules
```

