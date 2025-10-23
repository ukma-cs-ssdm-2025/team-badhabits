import 'package:equatable/equatable.dart';
import '../../../auth/domain/entities/user_entity.dart';

/// Base class for profile states
abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

/// State when profile is loading
class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

/// State when profile is loaded successfully
class ProfileLoaded extends ProfileState {
  const ProfileLoaded(this.user);
  final UserEntity user;

  @override
  List<Object?> get props => [user];
}

/// State when profile update is in progress
class ProfileUpdating extends ProfileState {
  const ProfileUpdating(this.currentUser);
  final UserEntity currentUser;

  @override
  List<Object?> get props => [currentUser];
}

/// State when profile update is successful
class ProfileUpdateSuccess extends ProfileState {
  const ProfileUpdateSuccess(this.user);
  final UserEntity user;

  @override
  List<Object?> get props => [user];
}

/// State when avatar upload is in progress
class AvatarUploading extends ProfileState {
  const AvatarUploading(this.currentUser);
  final UserEntity currentUser;

  @override
  List<Object?> get props => [currentUser];
}

/// State when avatar upload is successful
class AvatarUploadSuccess extends ProfileState {
  const AvatarUploadSuccess(this.user);
  final UserEntity user;

  @override
  List<Object?> get props => [user];
}

/// State when profile operation fails
class ProfileError extends ProfileState {
  const ProfileError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
