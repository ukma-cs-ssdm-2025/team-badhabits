import 'package:dartz/dartz.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../../../core/utils/failure.dart';
import '../../domain/entities/note.dart';
import '../../domain/repositories/notes_repository.dart';
import '../datasources/notes_firestore_datasource.dart';
import '../models/note_model.dart';

/// Implementation of [NotesRepository]
///
/// Handles the business logic and error handling for notes operations
class NotesRepositoryImpl implements NotesRepository {
  final NotesFirestoreDataSource datasource;

  NotesRepositoryImpl({
    required this.datasource,
  });

  @override
  Future<Either<Failure, List<Note>>> getNotes(String userId) async {
    try {
      final notes = await datasource.getNotes(userId);
      return Right(notes);
    } on FirebaseException catch (e) {
      return Left(ServerFailure('Firebase error: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Failed to get notes: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Note>> createNote(Note note) async {
    try {
      // Convert Note entity to NoteModel
      final noteModel = NoteModel.fromEntity(note);
      final createdNote = await datasource.createNote(noteModel);
      return Right(createdNote);
    } on FirebaseException catch (e) {
      return Left(ServerFailure('Firebase error: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Failed to create note: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Note>> updateNote(Note note) async {
    try {
      // Convert Note entity to NoteModel
      final noteModel = NoteModel.fromEntity(note);
      final updatedNote = await datasource.updateNote(noteModel);
      return Right(updatedNote);
    } on FirebaseException catch (e) {
      return Left(ServerFailure('Firebase error: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Failed to update note: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteNote(String noteId) async {
    try {
      await datasource.deleteNote(noteId);
      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(ServerFailure('Firebase error: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('Failed to delete note: ${e.toString()}'));
    }
  }
}
