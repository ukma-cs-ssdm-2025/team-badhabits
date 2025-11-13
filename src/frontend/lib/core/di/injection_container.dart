// ignore_for_file: cascade_invocations
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;

// Auth
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../../features/auth/domain/usecases/sign_in_usecase.dart';
import '../../features/auth/domain/usecases/sign_out_usecase.dart';
import '../../features/auth/domain/usecases/sign_up_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
// Habits
import '../../features/habits/data/datasources/habits_firestore_datasource.dart';
import '../../features/habits/data/datasources/habits_local_datasource.dart';
import '../../features/habits/data/models/habit_entry_hive_model.dart';
import '../../features/habits/data/models/habit_hive_model.dart';
import '../../features/habits/data/repositories/habits_repository_impl.dart';
import '../../features/habits/data/services/habit_sync_service.dart';
import '../../features/habits/domain/repositories/habits_repository.dart';
import '../../features/habits/domain/usecases/add_habit_entry.dart';
import '../../features/habits/domain/usecases/create_habit.dart';
import '../../features/habits/domain/usecases/delete_habit.dart';
import '../../features/habits/domain/usecases/get_entry_for_date.dart';
import '../../features/habits/domain/usecases/get_habit_entries.dart';
import '../../features/habits/domain/usecases/get_habit_statistics.dart';
import '../../features/habits/domain/usecases/get_habits.dart';
import '../../features/habits/domain/usecases/update_habit.dart';
import '../../features/habits/presentation/bloc/habits_bloc.dart';
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
// Workouts
import '../../features/workouts/data/datasources/workouts_api_datasource.dart';
import '../../features/workouts/data/datasources/workouts_firestore_datasource.dart';
import '../../features/workouts/data/repositories/workouts_repository_impl.dart';
import '../../features/workouts/domain/repositories/workouts_repository.dart';
import '../../features/workouts/domain/usecases/cancel_workout_session.dart';
import '../../features/workouts/domain/usecases/complete_workout_session.dart';
import '../../features/workouts/domain/usecases/get_active_workout_session.dart';
import '../../features/workouts/domain/usecases/get_filtered_workouts.dart';
import '../../features/workouts/domain/usecases/get_recommended_workout.dart';
import '../../features/workouts/domain/usecases/get_workout_by_id.dart';
import '../../features/workouts/domain/usecases/get_workout_history.dart';
import '../../features/workouts/domain/usecases/get_workouts.dart';
import '../../features/workouts/domain/usecases/start_workout_session.dart';
import '../../features/workouts/presentation/bloc/workouts_bloc.dart';
// Core
import '../network/network_info.dart';
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
  // Features - Habits
  // ============================================================================

  // Bloc
  sl.registerFactory(
    () => HabitsBloc(
      getHabits: sl(),
      createHabit: sl(),
      updateHabit: sl(),
      deleteHabit: sl(),
      addHabitEntry: sl(),
      getHabitEntries: sl(),
      getEntryForDate: sl(),
      getHabitStatistics: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetHabits(sl()));
  sl.registerLazySingleton(() => CreateHabit(sl()));
  sl.registerLazySingleton(() => UpdateHabit(sl()));
  sl.registerLazySingleton(() => DeleteHabit(sl()));
  sl.registerLazySingleton(() => AddHabitEntry(sl()));
  sl.registerLazySingleton(() => GetHabitEntries(sl()));
  sl.registerLazySingleton(() => GetEntryForDate(sl()));
  sl.registerLazySingleton(() => GetHabitStatistics(sl()));

  // Repository
  sl.registerLazySingleton<HabitsRepository>(
    () => HabitsRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<HabitsFirestoreDataSource>(
    () => HabitsFirestoreDataSourceImpl(firestore: sl()),
  );

  sl.registerLazySingleton<HabitsLocalDataSource>(
    () => HabitsLocalDataSourceImpl(
      habitsBox: Hive.box<HabitHiveModel>('habits'),
      entriesBox: Hive.box<HabitEntryHiveModel>('habit_entries'),
    ),
  );

  // Sync Service
  sl.registerLazySingleton(
    () => HabitSyncService(
      localDataSource: sl(),
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // ============================================================================
  // Features - Workouts
  // ============================================================================

  // Bloc
  sl.registerFactory(
    () => WorkoutsBloc(
      getWorkouts: sl(),
      getWorkoutById: sl(),
      getFilteredWorkouts: sl(),
      startWorkoutSession: sl(),
      getActiveWorkoutSession: sl(),
      completeWorkoutSession: sl(),
      cancelWorkoutSession: sl(),
      getRecommendedWorkout: sl(),
      getWorkoutHistory: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetWorkouts(sl()));
  sl.registerLazySingleton(() => GetWorkoutById(sl()));
  sl.registerLazySingleton(() => GetFilteredWorkouts(sl()));
  sl.registerLazySingleton(() => StartWorkoutSession(sl()));
  sl.registerLazySingleton(() => GetActiveWorkoutSession(sl()));
  sl.registerLazySingleton(() => CompleteWorkoutSession(sl()));
  sl.registerLazySingleton(() => CancelWorkoutSession(sl()));
  sl.registerLazySingleton(() => GetRecommendedWorkout(sl()));
  sl.registerLazySingleton(() => GetWorkoutHistory(sl()));

  // Repository
  sl.registerLazySingleton<WorkoutsRepository>(
    () => WorkoutsRepositoryImpl(
      firestoreDataSource: sl(),
      apiDataSource: sl(),
      auth: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<WorkoutsFirestoreDataSource>(
    () => WorkoutsFirestoreDataSource(
      firestoreDb: sl(),
      realtimeDatabase: sl(),
      auth: sl(),
    ),
  );

  sl.registerLazySingleton<WorkoutsApiDataSource>(
    () => WorkoutsApiDataSource(
      client: sl(),
      baseUrl: 'https://wellity-backend-production.up.railway.app',
    ),
  );

  // ============================================================================
  // Core - Network
  // ============================================================================
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
  sl.registerLazySingleton(Connectivity.new);

  // ============================================================================
  // External dependencies
  // ============================================================================
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => FirebaseStorage.instance);
  sl.registerLazySingleton(() => FirebaseDatabase.instance);
  sl.registerLazySingleton(http.Client.new);
}
