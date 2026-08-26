import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Resilient Firebase integration service providing Cloud Firestore sync
/// for user preferences, meal plans, shopping list, and saved recipes.
/// Gracefully falls back when offline or without active credentials.
class FirebaseService {
  bool _isInitialized = false;
  FirebaseFirestore? _firestore;

  bool get isInitialized => _isInitialized;
  FirebaseFirestore? get firestore => _firestore;

  Future<void> initialize() async {
    try {
      await Firebase.initializeApp();
      _firestore = FirebaseFirestore.instance;
      _isInitialized = true;
      debugPrint('[FirebaseService] Firebase initialized successfully.');
    } catch (e) {
      _isInitialized = false;
      debugPrint('[FirebaseService] Firebase initialization skipped or running offline: $e');
    }
  }

  /// Syncs user preferences to Cloud Firestore under `users/{userId}/preferences`
  Future<void> syncPreferences({
    required String userId,
    required Map<String, dynamic> data,
  }) async {
    if (!_isInitialized || _firestore == null) return;
    try {
      await _firestore!
          .collection('users')
          .doc(userId)
          .collection('preferences')
          .doc('user_profile')
          .set(data, SetOptions(merge: true));
    } catch (e) {
      debugPrint('[FirebaseService] Failed to sync preferences: $e');
    }
  }

  /// Syncs favorite recipe to Cloud Firestore under `users/{userId}/favorites/{recipeId}`
  Future<void> syncFavoriteRecipe({
    required String userId,
    required String recipeId,
    required Map<String, dynamic> recipeData,
  }) async {
    if (!_isInitialized || _firestore == null) return;
    try {
      await _firestore!
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .doc(recipeId)
          .set(recipeData, SetOptions(merge: true));
    } catch (e) {
      debugPrint('[FirebaseService] Failed to sync favorite: $e');
    }
  }

  /// Syncs shopping list item to Cloud Firestore under `users/{userId}/shopping_list/{itemId}`
  Future<void> syncShoppingItem({
    required String userId,
    required String itemId,
    required Map<String, dynamic> itemData,
  }) async {
    if (!_isInitialized || _firestore == null) return;
    try {
      await _firestore!
          .collection('users')
          .doc(userId)
          .collection('shopping_list')
          .doc(itemId)
          .set(itemData, SetOptions(merge: true));
    } catch (e) {
      debugPrint('[FirebaseService] Failed to sync shopping item: $e');
    }
  }

  /// Syncs weekly meal plan to Cloud Firestore under `users/{userId}/meal_plans/{planId}`
  Future<void> syncMealPlan({
    required String userId,
    required String planId,
    required Map<String, dynamic> planData,
  }) async {
    if (!_isInitialized || _firestore == null) return;
    try {
      await _firestore!
          .collection('users')
          .doc(userId)
          .collection('meal_plans')
          .doc(planId)
          .set(planData, SetOptions(merge: true));
    } catch (e) {
      debugPrint('[FirebaseService] Failed to sync meal plan: $e');
    }
  }
}
