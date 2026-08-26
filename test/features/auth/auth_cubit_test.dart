import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:anu_meal_ai/core/errors/failures.dart';
import 'package:anu_meal_ai/core/utils/result.dart';
import 'package:anu_meal_ai/features/auth/domain/entities/user_entity.dart';
import 'package:anu_meal_ai/features/auth/domain/repositories/auth_repository.dart';
import 'package:anu_meal_ai/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:anu_meal_ai/features/auth/presentation/bloc/auth_state.dart';

class MockAuthRepository implements AuthRepository {
  final StreamController<UserEntity?> _controller =
      StreamController<UserEntity?>.broadcast();
  UserEntity? _currentUser;

  @override
  Stream<UserEntity?> get authStateChanges => _controller.stream;

  @override
  Future<UserEntity?> getCurrentUser() async => _currentUser;

  @override
  Future<Result<UserEntity>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    if (password == 'wrong') {
      return const Result.failure(ServerFailure('Invalid credentials.'));
    }
    final user = UserEntity(
      id: 'test_uid_123',
      email: email,
      displayName: 'Master Chef',
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );
    _currentUser = user;
    _controller.add(user);
    return Result.success(user);
  }

  @override
  Future<Result<UserEntity>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final user = UserEntity(
      id: 'test_uid_456',
      email: email,
      displayName: displayName ?? 'New Chef',
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );
    _currentUser = user;
    _controller.add(user);
    return Result.success(user);
  }

  @override
  Future<Result<UserEntity>> signInAnonymously() async {
    final guest = UserEntity.guest();
    _currentUser = guest;
    _controller.add(guest);
    return Result.success(guest);
  }

  @override
  Future<Result<void>> sendPasswordResetEmail(String email) async {
    return const Result.success(null);
  }

  @override
  Future<Result<void>> signOut() async {
    _currentUser = null;
    _controller.add(null);
    return const Result.success(null);
  }

  @override
  Future<Result<void>> deleteAccount({String? password}) async {
    _currentUser = null;
    _controller.add(null);
    return const Result.success(null);
  }
}

void main() {
  late MockAuthRepository mockRepo;
  late AuthCubit authCubit;

  setUp(() {
    mockRepo = MockAuthRepository();
    authCubit = AuthCubit(authRepository: mockRepo);
  });

  tearDown(() {
    authCubit.close();
  });

  group('AuthCubit State Machine Tests (§9, §70)', () {
    test(
      'Initial state is Unauthenticated when repository has no current user',
      () async {
        await Future.delayed(const Duration(milliseconds: 10));
        expect(authCubit.state, equals(const Unauthenticated()));
      },
    );

    test(
      'signIn emits Authenticated when valid credentials are provided',
      () async {
        await authCubit.signIn(
          email: 'chef@anumealai.app',
          password: 'password123',
        );

        expect(authCubit.state, isA<Authenticated>());
        final user = (authCubit.state as Authenticated).user;
        expect(user.email, equals('chef@anumealai.app'));
        expect(user.displayName, equals('Master Chef'));
      },
    );

    test('signIn emits AuthError when credentials fail', () async {
      await authCubit.signIn(email: 'chef@anumealai.app', password: 'wrong');

      expect(authCubit.state, isA<AuthError>());
      final error = (authCubit.state as AuthError).message;
      expect(error, contains('Invalid credentials'));
    });

    test('signInAsGuest creates anonymous guest entity', () async {
      await authCubit.signInAsGuest();

      expect(authCubit.state, isA<Authenticated>());
      final user = (authCubit.state as Authenticated).user;
      expect(user.isAnonymous, isTrue);
      expect(user.displayName, equals('Guest Chef'));
    });

    test('signOut emits Unauthenticated', () async {
      await authCubit.signInAsGuest();
      expect(authCubit.state, isA<Authenticated>());

      await authCubit.signOut();
      expect(authCubit.state, equals(const Unauthenticated()));
    });
  });
}
