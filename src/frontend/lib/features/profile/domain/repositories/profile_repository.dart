import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/utils/failure.dart';
import '../../../auth/domain/entities/user_entity.dart';

/// Profile repository interface
///
/// Defines the contract for profile operations.
/// Implementation is in the data layer.
abstract class ProfileRepository {
  /// Get user profile by ID
  ///
  /// Returns [UserEntity] on success or [Failure] on error
  Future<Either<Failure, UserEntity>> getUserProfile(String userId);

  /// Update user profile
  ///
  /// Returns [UserEntity] on success or [Failure] on error
  Future<Either<Failure, UserEntity>> updateUserProfile({
    required String userId,
    String? name,
    String? bio,
    String? avatarUrl,
  });

  /// Upload avatar image to storage
  ///
  /// Returns avatar URL on success or [Failure] on error
  Future<Either<Failure, String>> uploadAvatar({
    required String userId,
    required File imageFile,
  });
}
