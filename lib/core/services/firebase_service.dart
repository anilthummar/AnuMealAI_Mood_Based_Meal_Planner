import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

/// Centralized Enterprise Firebase integration service (§4, §5).
/// Provides safe initialization and access to Firebase Core, Auth,
/// Cloud Firestore, Remote Config, Analytics, and Crashlytics.
/// Gracefully falls back when running offline, in test suites, or without active credentials.
class FirebaseService {
  bool _isInitialized = false;
  FirebaseAuth? _auth;
  FirebaseFirestore? _firestore;
  FirebaseRemoteConfig? _remoteConfig;
  FirebaseAnalytics? _analytics;
  FirebaseCrashlytics? _crashlytics;

  bool get isInitialized => _isInitialized;
  FirebaseAuth? get auth => _auth;
  FirebaseFirestore? get firestore => _firestore;
  FirebaseRemoteConfig? get remoteConfig => _remoteConfig;
  FirebaseAnalytics? get analytics => _analytics;
  FirebaseCrashlytics? get crashlytics => _crashlytics;

  Future<void> initialize() async {
    try {
      await Firebase.initializeApp();
      _isInitialized = true;

      try {
        _auth = FirebaseAuth.instance;
      } catch (e) {
        debugPrint('[FirebaseService] FirebaseAuth initialization fallback: $e');
      }

      try {
        _firestore = FirebaseFirestore.instance;
      } catch (e) {
        debugPrint('[FirebaseService] FirebaseFirestore initialization fallback: $e');
      }

      try {
        _remoteConfig = FirebaseRemoteConfig.instance;
      } catch (e) {
        debugPrint('[FirebaseService] FirebaseRemoteConfig initialization fallback: $e');
      }

      try {
        _analytics = FirebaseAnalytics.instance;
      } catch (e) {
        debugPrint('[FirebaseService] FirebaseAnalytics initialization fallback: $e');
      }

      try {
        _crashlytics = FirebaseCrashlytics.instance;
        if (!kIsWeb) {
          FlutterError.onError = _crashlytics!.recordFlutterFatalError;
          PlatformDispatcher.instance.onError = (error, stack) {
            _crashlytics!.recordError(error, stack, fatal: true);
            return true;
          };
        }
      } catch (e) {
        debugPrint('[FirebaseService] FirebaseCrashlytics initialization fallback: $e');
      }

      debugPrint('[FirebaseService] Firebase suite initialized successfully.');
    } catch (e) {
      _isInitialized = false;
      debugPrint('[FirebaseService] Firebase core initialization skipped or running offline: $e');
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

  /// Syncs shopping list item to Cloud Firestore under `users/{userId}/shopping_items/{itemId}`
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
          .collection('shopping_items')
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
