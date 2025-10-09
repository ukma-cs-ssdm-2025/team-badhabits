import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/utils/failure.dart';
import '../repositories/profile_repository.dart';

/// Use case for uploading user avatar
class UploadAvatarUseCase {
  final ProfileRepository repository;

  UploadAvatarUseCase(this.repository);

  /// Execute the upload avatar operation
  ///
  /// [userId] - ID of the user
  /// [imageFile] - Image file to upload
  ///
  /// Returns avatar URL on success or [Failure] on error
  Future<Either<Failure, String>> call({
    required String userId,
    required File imageFile,
  }) async {
    return await repository.uploadAvatar(
      userId: userId,
      imageFile: imageFile,
    );
  }
}
