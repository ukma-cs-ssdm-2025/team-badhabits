import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/utils/failure.dart';
import 'package:frontend/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:frontend/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'error_handling_test.mocks.dart';

@GenerateMocks([AuthRemoteDataSource])
void main() {
  late AuthRepositoryImpl repository;
  late MockAuthRemoteDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockAuthRemoteDataSource();
    repository = AuthRepositoryImpl(remoteDataSource: mockDataSource);
  });

  group('Error Handling Tests', () {
    test('FirebaseAuthException user-not-found returns user-friendly message',
        () async {
      const email = 'test@example.com';
      const password = 'password123';
      when(mockDataSource.signIn(email: email, password: password)).thenThrow(
        FirebaseAuthException(code: 'user-not-found'),
      );

      // Act
      final result = await repository.signIn(email: email, password: password);

      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect(
            (failure as ServerFailure).message,
            'No account found with this email',
          );
          expect(
            failure.message.contains('FirebaseAuthException'),
            false,
          );
        },
        (_) => fail('Should return Left with failure'),
      );
    });

    test('Empty email returns validation error', () async {
      const email = '';
      const password = 'password123';

      final result = await repository.signIn(email: email, password: password);

      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect(
            (failure as ServerFailure).message,
            'Please enter both email and password',
          );
        },
        (_) => fail('Should return Left with failure'),
      );

      verifyNever(mockDataSource.signIn(email: email, password: password));
    });
  });
}
