import 'dart:io';
import 'package:equatable/equatable.dart';

/// Base class for profile events
abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load user profile
class LoadProfile extends ProfileEvent {
  final String userId;

  const LoadProfile(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Event to update user profile
class UpdateProfile extends ProfileEvent {
  final String userId;
  final String? name;
  final String? bio;

  const UpdateProfile({
    required this.userId,
    this.name,
    this.bio,
  });

  @override
  List<Object?> get props => [userId, name, bio];
}

/// Event to upload avatar
class UploadAvatar extends ProfileEvent {
  final String userId;
  final File imageFile;

  const UploadAvatar({
    required this.userId,
    required this.imageFile,
  });

  @override
  List<Object?> get props => [userId, imageFile];
}
