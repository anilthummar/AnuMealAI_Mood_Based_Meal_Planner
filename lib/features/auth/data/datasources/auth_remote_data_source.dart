import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/user_entity.dart';

abstract class AuthRemoteDataSource {
  Stream<UserEntity?> get authStateChanges;
  Future<UserEntity?> getCurrentUser();
  Future<UserEntity> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  });
  Future<UserEntity> signInWithEmailAndPassword({
    required String email,
    required String password,
  });
  Future<UserEntity> signInAnonymously();
  Future<void> sendPasswordResetEmail(String email);
  Future<void> signOut();
  Future<void> deleteAccount({String? password});
}

class FirebaseAuthRemoteDataSource implements AuthRemoteDataSource {
  final FirebaseAuth? firebaseAuth;
  final SharedPreferences prefs;
  final StreamController<UserEntity?> _fallbackController =
      StreamController<UserEntity?>.broadcast();

  static const String _guestKey = 'auth_is_guest';
  static const String _localUserKey = 'auth_local_user_data';

  FirebaseAuthRemoteDataSource({this.firebaseAuth, required this.prefs});

  @override
  Stream<UserEntity?> get authStateChanges {
    if (firebaseAuth != null) {
      return firebaseAuth!.authStateChanges().map(_mapFirebaseUser);
    }
    return _fallbackController.stream;
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    if (firebaseAuth != null) {
      final user = firebaseAuth!.currentUser;
      return _mapFirebaseUser(user);
    }

    final isGuest = prefs.getBool(_guestKey) ?? false;
    if (isGuest) {
      return UserEntity.guest();
    }
    return null;
  }

  @override
  Future<UserEntity> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    if (firebaseAuth == null) {
      final user = UserEntity(
        id: 'local_${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        displayName: displayName ?? 'Chef',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await prefs.setBool(_guestKey, false);
      _fallbackController.add(user);
      return user;
    }

    try {
      final credential = await firebaseAuth!.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (displayName != null && displayName.trim().isNotEmpty) {
        await credential.user?.updateDisplayName(displayName.trim());
      }

      final user = _mapFirebaseUser(credential.user);
      if (user == null) {
        throw const ServerException('Failed to create user account.');
      }
      return user;
    } on FirebaseAuthException catch (e) {
      throw ServerException(_mapFirebaseAuthError(e));
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserEntity> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    if (firebaseAuth == null) {
      final user = UserEntity(
        id: 'local_${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        displayName: 'Chef',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await prefs.setBool(_guestKey, false);
      _fallbackController.add(user);
      return user;
    }

    try {
      final credential = await firebaseAuth!.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = _mapFirebaseUser(credential.user);
      if (user == null) {
        throw const ServerException('Failed to authenticate user.');
      }
      return user;
    } on FirebaseAuthException catch (e) {
      throw ServerException(_mapFirebaseAuthError(e));
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserEntity> signInAnonymously() async {
    if (firebaseAuth == null) {
      final guest = UserEntity.guest();
      await prefs.setBool(_guestKey, true);
      _fallbackController.add(guest);
      return guest;
    }

    try {
      final credential = await firebaseAuth!.signInAnonymously();
      final user = _mapFirebaseUser(credential.user);
      if (user == null) {
        throw const ServerException('Failed to create guest session.');
      }
      return user;
    } on FirebaseAuthException catch (e) {
      debugPrint('[Auth] signInAnonymously fallback: $e');
      final guest = UserEntity.guest();
      _fallbackController.add(guest);
      return guest;
    } catch (e) {
      final guest = UserEntity.guest();
      _fallbackController.add(guest);
      return guest;
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    if (firebaseAuth == null) return;
    try {
      await firebaseAuth!.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw ServerException(_mapFirebaseAuthError(e));
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    try {
      if (firebaseAuth != null) {
        await firebaseAuth!.signOut();
      }
      await prefs.remove(_guestKey);
      await prefs.remove(_localUserKey);
      _fallbackController.add(null);
    } catch (e) {
      debugPrint('[Auth] SignOut error: $e');
    }
  }

  @override
  Future<void> deleteAccount({String? password}) async {
    if (firebaseAuth != null && firebaseAuth!.currentUser != null) {
      try {
        final user = firebaseAuth!.currentUser!;
        if (password != null && user.email != null) {
          final cred = EmailAuthProvider.credential(
            email: user.email!,
            password: password,
          );
          await user.reauthenticateWithCredential(cred);
        }
        await user.delete();
      } on FirebaseAuthException catch (e) {
        throw ServerException(_mapFirebaseAuthError(e));
      }
    }
    await signOut();
  }

  UserEntity? _mapFirebaseUser(User? user) {
    if (user == null) return null;
    return UserEntity(
      id: user.uid,
      email: user.email ?? 'anonymous@anumealai.app',
      displayName:
          user.displayName ?? (user.isAnonymous ? 'Guest Chef' : 'Chef'),
      photoUrl: user.photoURL,
      createdAt: user.metadata.creationTime ?? DateTime.now(),
      updatedAt: user.metadata.lastSignInTime ?? DateTime.now(),
      isAnonymous: user.isAnonymous,
    );
  }

  String _mapFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password must be at least 6 characters long.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a few moments and try again.';
      case 'requires-recent-login':
        return 'Please log in again before deleting your account.';
      default:
        return e.message ?? 'Authentication failed. Please try again.';
    }
  }
}
