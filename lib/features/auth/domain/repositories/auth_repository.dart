import '../../../../core/utils/result.dart';
import '../entities/user_entity.dart';

/// Clean Architecture Authentication Repository Interface (§2, §7).
abstract class AuthRepository {
  Stream<UserEntity?> get authStateChanges;

  Future<UserEntity?> getCurrentUser();

  Future<Result<UserEntity>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  });

  Future<Result<UserEntity>> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<Result<UserEntity>> signInAnonymously();

  Future<Result<void>> sendPasswordResetEmail(String email);

  Future<Result<void>> signOut();

  Future<Result<void>> deleteAccount({String? password});
}
