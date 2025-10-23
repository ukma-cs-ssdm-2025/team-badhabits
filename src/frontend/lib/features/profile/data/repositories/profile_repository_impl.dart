import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/utils/failure.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';

/// Implementation of [ProfileRepository]
///
/// Handles the business logic and error handling for profile operations
class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl({required this.remoteDataSource});
  final ProfileRemoteDataSource remoteDataSource;

  @override
  Future<Either<Failure, UserEntity>> getUserProfile(String userId) async {
    try {
      final user = await remoteDataSource.getUserProfile(userId);
      return Right(user);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> updateUserProfile({
    required String userId,
    String? name,
    String? bio,
    String? avatarUrl,
  }) async {
    try {
      final user = await remoteDataSource.updateUserProfile(
        userId: userId,
        name: name,
        bio: bio,
        avatarUrl: avatarUrl,
      );
      return Right(user);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> uploadAvatar({
    required String userId,
    required File imageFile,
  }) async {
    try {
      final avatarUrl = await remoteDataSource.uploadAvatar(
        userId: userId,
        imageFile: imageFile,
      );
      return Right(avatarUrl);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
