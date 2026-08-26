import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../../core/services/firebase_service.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

/// Production Authentication Repository Implementation (§2, §7, §8).
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final FirebaseService firebaseService;
  final AnalyticsService analytics;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.firebaseService,
    required this.analytics,
  });

  @override
  Stream<UserEntity?> get authStateChanges => remoteDataSource.authStateChanges;

  @override
  Future<UserEntity?> getCurrentUser() => remoteDataSource.getCurrentUser();

  @override
  Future<Result<UserEntity>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final user = await remoteDataSource.signUpWithEmailAndPassword(
        email: email,
        password: password,
        displayName: displayName,
      );

      // Create Firestore User Profile Document (§11, §12)
      await _syncUserProfile(user);
      await analytics.logSignUp('email_password');

      return Result.success(user);
    } on ServerException catch (e) {
      return Result.failure(ServerFailure(e.message));
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<UserEntity>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final user = await remoteDataSource.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _syncUserProfile(user);
      await analytics.logLogin('email_password');

      return Result.success(user);
    } on ServerException catch (e) {
      return Result.failure(ServerFailure(e.message));
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<UserEntity>> signInAnonymously() async {
    try {
      final user = await remoteDataSource.signInAnonymously();
      await analytics.logLogin('guest_anonymous');
      return Result.success(user);
    } on ServerException catch (e) {
      return Result.failure(ServerFailure(e.message));
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> sendPasswordResetEmail(String email) async {
    try {
      await remoteDataSource.sendPasswordResetEmail(email);
      return const Result.success(null);
    } on ServerException catch (e) {
      return Result.failure(ServerFailure(e.message));
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await remoteDataSource.signOut();
      await analytics.logLogout();
      return const Result.success(null);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteAccount({String? password}) async {
    try {
      await remoteDataSource.deleteAccount(password: password);
      await analytics.logEvent('account_deleted');
      return const Result.success(null);
    } on ServerException catch (e) {
      return Result.failure(ServerFailure(e.message));
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  Future<void> _syncUserProfile(UserEntity user) async {
    await firebaseService.syncPreferences(userId: user.id, data: user.toMap());
  }
}
