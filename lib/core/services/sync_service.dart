import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../constants/hive_boxes.dart';
import 'firebase_service.dart';

/// Orchestrates Two-Way Firestore Data Synchronization (§62, §63, §65).
/// Guarantees offline resilience, data persistence, and strict user data isolation.
class SyncService {
  final FirebaseService firebaseService;

  SyncService({required this.firebaseService});

  /// Syncs all cloud data down to local cache upon user login
  Future<void> syncDown(String userId) async {
    if (!firebaseService.isInitialized || firebaseService.firestore == null) {
      debugPrint('[SyncService] Firebase offline, skipping cloud pull.');
      return;
    }

    try {
      final firestore = firebaseService.firestore!;

      // 1. Sync Favorites
      final favsSnap = await firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .get();

      if (favsSnap.docs.isNotEmpty) {
        final favsBox = Hive.box<Map>(HiveBoxes.favorites);
        for (final doc in favsSnap.docs) {
          await favsBox.put(doc.id, doc.data());
        }
      }

      // 2. Sync Shopping List Items
      final shopSnap = await firestore
          .collection('users')
          .doc(userId)
          .collection('shopping_items')
          .get();

      if (shopSnap.docs.isNotEmpty) {
        final shopBox = Hive.box<Map>(HiveBoxes.shoppingList);
        for (final doc in shopSnap.docs) {
          await shopBox.put(doc.id, doc.data());
        }
      }

      // 3. Sync Ingredients / Pantry
      final ingSnap = await firestore
          .collection('users')
          .doc(userId)
          .collection('ingredients')
          .get();

      if (ingSnap.docs.isNotEmpty) {
        final ingBox = Hive.box<Map>(HiveBoxes.ingredients);
        for (final doc in ingSnap.docs) {
          await ingBox.put(doc.id, doc.data());
        }
      }

      // 4. Sync Meal Plans
      final planSnap = await firestore
          .collection('users')
          .doc(userId)
          .collection('meal_plans')
          .get();

      if (planSnap.docs.isNotEmpty) {
        final planBox = Hive.box<Map>(HiveBoxes.mealPlans);
        for (final doc in planSnap.docs) {
          await planBox.put(doc.id, doc.data());
        }
      }

      debugPrint(
        '[SyncService] Successfully synchronized cloud data for $userId.',
      );
    } catch (e) {
      debugPrint('[SyncService] Sync pull error: $e');
    }
  }

  /// Pushes local pantry/ingredient data to Firestore
  Future<void> syncUpIngredient({
    required String userId,
    required String ingredientId,
    required Map<String, dynamic> data,
  }) async {
    if (!firebaseService.isInitialized || firebaseService.firestore == null) {
      return;
    }
    try {
      await firebaseService.firestore!
          .collection('users')
          .doc(userId)
          .collection('ingredients')
          .doc(ingredientId)
          .set(data, SetOptions(merge: true));
    } catch (e) {
      debugPrint('[SyncService] Failed to sync ingredient: $e');
    }
  }

  /// Deletes an ingredient from Firestore
  Future<void> deleteIngredient({
    required String userId,
    required String ingredientId,
  }) async {
    if (!firebaseService.isInitialized || firebaseService.firestore == null) {
      return;
    }
    try {
      await firebaseService.firestore!
          .collection('users')
          .doc(userId)
          .collection('ingredients')
          .doc(ingredientId)
          .delete();
    } catch (e) {
      debugPrint('[SyncService] Failed to delete ingredient from cloud: $e');
    }
  }

  /// Clears all local user data on logout to ensure user data isolation (§65)
  Future<void> clearLocalUserData() async {
    try {
      for (final boxName in HiveBoxes.all) {
        if (Hive.isBoxOpen(boxName)) {
          await Hive.box<Map>(boxName).clear();
        }
      }
      debugPrint('[SyncService] Local private data cleared successfully.');
    } catch (e) {
      debugPrint('[SyncService] Error clearing local private data: $e');
    }
  }
}
