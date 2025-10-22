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
  const LoadProfile(this.userId);
  final String userId;

  @override
  List<Object?> get props => [userId];
}

/// Event to update user profile
class UpdateProfile extends ProfileEvent {
  const UpdateProfile({required this.userId, this.name, this.bio});
  final String userId;
  final String? name;
  final String? bio;

  @override
  List<Object?> get props => [userId, name, bio];
}

/// Event to upload avatar
class UploadAvatar extends ProfileEvent {
  const UploadAvatar({required this.userId, required this.imageFile});
  final String userId;
  final File imageFile;

  @override
  List<Object?> get props => [userId, imageFile];
}
