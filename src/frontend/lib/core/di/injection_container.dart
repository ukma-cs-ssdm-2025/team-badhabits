// ignore_for_file: cascade_invocations
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';

// Auth
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../../features/auth/domain/usecases/sign_in_usecase.dart';
import '../../features/auth/domain/usecases/sign_out_usecase.dart';
import '../../features/auth/domain/usecases/sign_up_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
// Notes
import '../../features/notes/data/datasources/notes_firestore_datasource.dart';
import '../../features/notes/data/repositories/notes_repository_impl.dart';
import '../../features/notes/domain/repositories/notes_repository.dart';
import '../../features/notes/domain/usecases/create_note.dart';
import '../../features/notes/domain/usecases/delete_note.dart';
import '../../features/notes/domain/usecases/get_notes.dart';
import '../../features/notes/domain/usecases/update_note.dart';
import '../../features/notes/presentation/bloc/notes_bloc.dart';
// Profile
import '../../features/profile/data/datasources/profile_remote_data_source.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/domain/usecases/get_user_profile_usecase.dart';
import '../../features/profile/domain/usecases/update_user_profile_usecase.dart';
import '../../features/profile/domain/usecases/upload_avatar_usecase.dart';
import '../../features/profile/presentation/bloc/profile_bloc.dart';
// Core
import '../theme/theme_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // ============================================================================
  // Core
  // ============================================================================

  // Theme
  sl.registerFactory(ThemeCubit.new);

  // ============================================================================
  // Features - Auth
  // ============================================================================

  // Bloc
  sl.registerFactory(
    () => AuthBloc(
      signInUseCase: sl(),
      signUpUseCase: sl(),
      signOutUseCase: sl(),
      getCurrentUserUseCase: sl(),
      authRepository: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => SignInUseCase(sl()));
  sl.registerLazySingleton(() => SignUpUseCase(sl()));
  sl.registerLazySingleton(() => SignOutUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(firebaseAuth: sl(), firestore: sl()),
  );

  // ============================================================================
  // Features - Profile
  // ============================================================================

  // Bloc
  sl.registerFactory(
    () => ProfileBloc(
      getUserProfileUseCase: sl(),
      updateUserProfileUseCase: sl(),
      uploadAvatarUseCase: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetUserProfileUseCase(sl()));
  sl.registerLazySingleton(() => UpdateUserProfileUseCase(sl()));
  sl.registerLazySingleton(() => UploadAvatarUseCase(sl()));

  // Repository
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(firestore: sl(), storage: sl()),
  );

  // ============================================================================
  // Features - Notes
  // ============================================================================

  // Bloc
  sl.registerFactory(
    () => NotesBloc(
      getNotes: sl(),
      createNote: sl(),
      updateNote: sl(),
      deleteNote: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetNotes(sl()));
  sl.registerLazySingleton(() => CreateNote(sl()));
  sl.registerLazySingleton(() => UpdateNote(sl()));
  sl.registerLazySingleton(() => DeleteNote(sl()));

  // Repository
  sl.registerLazySingleton<NotesRepository>(
    () => NotesRepositoryImpl(datasource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<NotesFirestoreDataSource>(
    () => NotesFirestoreDataSourceImpl(firestore: sl()),
  );

  // ============================================================================
  // External dependencies
  // ============================================================================
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => FirebaseStorage.instance);
}
