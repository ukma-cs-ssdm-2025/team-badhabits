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
  final UserEntity user;

  const ProfileLoaded(this.user);

  @override
  List<Object?> get props => [user];
}

/// State when profile update is in progress
class ProfileUpdating extends ProfileState {
  final UserEntity currentUser;

  const ProfileUpdating(this.currentUser);

  @override
  List<Object?> get props => [currentUser];
}

/// State when profile update is successful
class ProfileUpdateSuccess extends ProfileState {
  final UserEntity user;

  const ProfileUpdateSuccess(this.user);

  @override
  List<Object?> get props => [user];
}

/// State when avatar upload is in progress
class AvatarUploading extends ProfileState {
  final UserEntity currentUser;

  const AvatarUploading(this.currentUser);

  @override
  List<Object?> get props => [currentUser];
}

/// State when avatar upload is successful
class AvatarUploadSuccess extends ProfileState {
  final UserEntity user;

  const AvatarUploadSuccess(this.user);

  @override
  List<Object?> get props => [user];
}

/// State when profile operation fails
class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}
