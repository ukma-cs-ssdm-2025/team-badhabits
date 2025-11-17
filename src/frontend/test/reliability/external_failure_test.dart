import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/utils/failure.dart';
import 'package:frontend/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:frontend/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'external_failure_test.mocks.dart';

@GenerateMocks([AuthRemoteDataSource])
void main() {
  group('External System Failure Tests', () {
    late AuthRepositoryImpl repository;
    late MockAuthRemoteDataSource mockDataSource;

    setUp(() {
      mockDataSource = MockAuthRemoteDataSource();
      repository = AuthRepositoryImpl(remoteDataSource: mockDataSource);
    });

    test('Firebase timeout on signIn returns user-friendly error', () async {
      const email = 'test@example.com';
      const password = 'password123';

      when(mockDataSource.signIn(email: email, password: password)).thenThrow(
        FirebaseAuthException(
          code: 'network-request-failed',
          message: 'A network error occurred',
        ),
      );

      final result = await repository.signIn(email: email, password: password);

      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect(
            (failure as ServerFailure).message,
            'Connection error. Please try again.',
          );
          expect(failure.message.contains('FirebaseAuthException'), false);
          expect(failure.message.contains('network-request-failed'), false);
        },
        (_) => fail('Should return Left with failure'),
      );
    });
  });
}
