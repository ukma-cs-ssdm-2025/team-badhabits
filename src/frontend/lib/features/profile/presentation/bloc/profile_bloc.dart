// ignore_for_file: avoid_print
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/achievements/data/services/achievement_tracker_service.dart';
import 'package:frontend/features/auth/domain/entities/user_entity.dart';
import '../../domain/usecases/get_user_profile_usecase.dart';
import '../../domain/usecases/update_user_profile_usecase.dart';
import '../../domain/usecases/upload_avatar_usecase.dart';
import 'profile_event.dart';
import 'profile_state.dart';

/// BLoC for managing profile state
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc({
    required this.getUserProfileUseCase,
    required this.updateUserProfileUseCase,
    required this.uploadAvatarUseCase,
    this.achievementTracker,
  }) : super(const ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
    on<UpdateProfile>(_onUpdateProfile);
    on<UploadAvatar>(_onUploadAvatar);
  }
  final GetUserProfileUseCase getUserProfileUseCase;
  final UpdateUserProfileUseCase updateUserProfileUseCase;
  final UploadAvatarUseCase uploadAvatarUseCase;
  final AchievementTrackerService? achievementTracker;

  /// Handle load profile event
  Future<void> _onLoadProfile(
    LoadProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());

    final result = await getUserProfileUseCase(event.userId);

    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (user) => emit(ProfileLoaded(user)),
    );
  }

  /// Handle update profile event
  Future<void> _onUpdateProfile(
    UpdateProfile event,
    Emitter<ProfileState> emit,
  ) async {
    // Get current user from state
    if (state is ProfileLoaded ||
        state is ProfileUpdateSuccess ||
        state is AvatarUploadSuccess) {
      final currentUser = state is ProfileLoaded
          ? (state as ProfileLoaded).user
          : state is ProfileUpdateSuccess
          ? (state as ProfileUpdateSuccess).user
          : (state as AvatarUploadSuccess).user;

      emit(ProfileUpdating(currentUser));

      final result = await updateUserProfileUseCase(
        userId: event.userId,
        name: event.name,
        bio: event.bio,
      );

      await result.fold(
        (failure) async => emit(ProfileError(failure.message)),
        (user) async {
          // Check if profile is now complete (has name and avatar)
          await _checkProfileCompleted(user.id, user);

          emit(ProfileUpdateSuccess(user));
          // Return to loaded state after showing success
          emit(ProfileLoaded(user));
        },
      );
    } else {
      emit(const ProfileError('Cannot update profile: profile not loaded'));
    }
  }

  /// Handle upload avatar event
  Future<void> _onUploadAvatar(
    UploadAvatar event,
    Emitter<ProfileState> emit,
  ) async {
    // Get current user from state
    if (state is ProfileLoaded ||
        state is ProfileUpdateSuccess ||
        state is AvatarUploadSuccess) {
      final currentUser = state is ProfileLoaded
          ? (state as ProfileLoaded).user
          : state is ProfileUpdateSuccess
          ? (state as ProfileUpdateSuccess).user
          : (state as AvatarUploadSuccess).user;

      emit(AvatarUploading(currentUser));

      // First, upload the avatar
      final uploadResult = await uploadAvatarUseCase(
        userId: event.userId,
        imageFile: event.imageFile,
      );

      await uploadResult.fold(
        (failure) async {
          emit(ProfileError(failure.message));
        },
        (avatarUrl) async {
          // Then, update the profile with the new avatar URL
          final updateResult = await updateUserProfileUseCase(
            userId: event.userId,
            avatarUrl: avatarUrl,
          );

          await updateResult.fold(
            (failure) async => emit(ProfileError(failure.message)),
            (user) async {
              // Check if profile is now complete (has avatar)
              await _checkProfileCompleted(user.id, user);

              emit(AvatarUploadSuccess(user));
              // Return to loaded state after showing success
              emit(ProfileLoaded(user));
            },
          );
        },
      );
    } else {
      emit(const ProfileError('Cannot upload avatar: profile not loaded'));
    }
  }

  /// Check if profile is complete and unlock achievement
  /// Profile is considered complete when user has uploaded an avatar
  Future<void> _checkProfileCompleted(String userId, UserEntity user) async {
    if (achievementTracker == null) {
      return;
    }

    // Profile is complete when user has an avatar
    final hasAvatar = user.avatarUrl != null && user.avatarUrl!.isNotEmpty;

    if (hasAvatar) {
      final unlocked = await achievementTracker!.onProfileCompleted(
        userId: userId,
      );
      if (unlocked.isNotEmpty) {
        print('🏆 Achievement unlocked: ${unlocked.join(", ")}');
      }
    }
  }
}
