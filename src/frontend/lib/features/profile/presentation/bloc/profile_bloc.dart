import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_user_profile_usecase.dart';
import '../../domain/usecases/update_user_profile_usecase.dart';
import '../../domain/usecases/upload_avatar_usecase.dart';
import 'profile_event.dart';
import 'profile_state.dart';

/// BLoC for managing profile state
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetUserProfileUseCase getUserProfileUseCase;
  final UpdateUserProfileUseCase updateUserProfileUseCase;
  final UploadAvatarUseCase uploadAvatarUseCase;

  ProfileBloc({
    required this.getUserProfileUseCase,
    required this.updateUserProfileUseCase,
    required this.uploadAvatarUseCase,
  }) : super(const ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
    on<UpdateProfile>(_onUpdateProfile);
    on<UploadAvatar>(_onUploadAvatar);
  }

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
    if (state is ProfileLoaded) {
      final currentUser = (state as ProfileLoaded).user;
      emit(ProfileUpdating(currentUser));

      final result = await updateUserProfileUseCase(
        userId: event.userId,
        name: event.name,
        bio: event.bio,
      );

      result.fold(
        (failure) => emit(ProfileError(failure.message)),
        (user) => emit(ProfileUpdateSuccess(user)),
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
    if (state is ProfileLoaded || state is ProfileUpdateSuccess) {
      final currentUser = state is ProfileLoaded
          ? (state as ProfileLoaded).user
          : (state as ProfileUpdateSuccess).user;

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

          updateResult.fold(
            (failure) => emit(ProfileError(failure.message)),
            (user) => emit(AvatarUploadSuccess(user)),
          );
        },
      );
    } else {
      emit(const ProfileError('Cannot upload avatar: profile not loaded'));
    }
  }
}
