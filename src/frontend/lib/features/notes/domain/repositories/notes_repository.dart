import 'package:dartz/dartz.dart';
import '../../../../core/utils/failure.dart';
import '../entities/note.dart';

/// Notes repository interface
///
/// Defines the contract for notes operations.
/// Implementation is in the data layer.
abstract class NotesRepository {
  /// Get all notes for a specific user
  ///
  /// Returns [List<Note>] on success or [Failure] on error
  Future<Either<Failure, List<Note>>> getNotes(String userId);

  /// Create a new note
  ///
  /// Returns [Note] on success or [Failure] on error
  Future<Either<Failure, Note>> createNote(Note note);

  /// Update an existing note
  ///
  /// Returns [Note] on success or [Failure] on error
  Future<Either<Failure, Note>> updateNote(Note note);

  /// Delete a note by ID
  ///
  /// Returns [void] on success or [Failure] on error
  Future<Either<Failure, void>> deleteNote(String noteId);
}
