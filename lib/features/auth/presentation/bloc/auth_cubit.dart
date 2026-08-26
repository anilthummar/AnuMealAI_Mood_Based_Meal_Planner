import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_state.dart';

/// Production AuthCubit (§9).
/// Reacts to Firebase Authentication state changes as the single source of truth.
class AuthCubit extends Cubit<AuthState> {
  final AuthRepository authRepository;
  StreamSubscription<UserEntity?>? _authSubscription;

  AuthCubit({required this.authRepository}) : super(const AuthInitial()) {
    _init();
  }

  void _init() {
    _authSubscription = authRepository.authStateChanges.listen((user) {
      if (user != null) {
        emit(Authenticated(user));
      } else {
        emit(const Unauthenticated());
      }
    });

    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    try {
      final user = await authRepository.getCurrentUser();
      if (user != null) {
        emit(Authenticated(user));
      } else {
        emit(const Unauthenticated());
      }
    } catch (_) {
      emit(const Unauthenticated());
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    emit(const AuthLoading(message: 'Creating your account...'));
    final result = await authRepository.signUpWithEmailAndPassword(
      email: email,
      password: password,
      displayName: displayName,
    );

    if (result.isSuccess && result.dataOrNull != null) {
      emit(Authenticated(result.dataOrNull!));
    } else {
      emit(
        AuthError(
          result.failureOrNull?.message ?? 'Sign up failed. Please try again.',
        ),
      );
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    emit(const AuthLoading(message: 'Signing you in...'));
    final result = await authRepository.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (result.isSuccess && result.dataOrNull != null) {
      emit(Authenticated(result.dataOrNull!));
    } else {
      emit(
        AuthError(
          result.failureOrNull?.message ?? 'Sign in failed. Please try again.',
        ),
      );
    }
  }

  Future<void> signInAsGuest() async {
    emit(const AuthLoading(message: 'Entering as Guest...'));
    final result = await authRepository.signInAnonymously();

    if (result.isSuccess && result.dataOrNull != null) {
      emit(Authenticated(result.dataOrNull!));
    } else {
      emit(
        AuthError(
          result.failureOrNull?.message ?? 'Could not start guest session.',
        ),
      );
    }
  }

  Future<void> sendPasswordReset(String email) async {
    emit(const AuthLoading(message: 'Sending recovery link...'));
    final result = await authRepository.sendPasswordResetEmail(email);

    if (result.isSuccess) {
      emit(PasswordResetSent(email));
    } else {
      emit(
        AuthError(
          result.failureOrNull?.message ?? 'Failed to send reset email.',
        ),
      );
    }
  }

  Future<void> signOut() async {
    emit(const AuthLoading(message: 'Signing out...'));
    await authRepository.signOut();
    emit(const Unauthenticated());
  }

  Future<bool> deleteAccount({String? password}) async {
    emit(const AuthLoading(message: 'Deleting your account...'));
    final result = await authRepository.deleteAccount(password: password);

    if (result.isSuccess) {
      emit(const Unauthenticated());
      return true;
    } else {
      emit(
        AuthError(result.failureOrNull?.message ?? 'Could not delete account.'),
      );
      return false;
    }
  }

  void resetState() {
    emit(const Unauthenticated());
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
