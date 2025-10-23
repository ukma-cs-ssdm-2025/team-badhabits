import 'package:dartz/dartz.dart';
import '../../../../core/utils/failure.dart';
import '../entities/note.dart';
import '../repositories/notes_repository.dart';

/// Use case for updating an existing note
class UpdateNote {
  UpdateNote(this.repository);
  final NotesRepository repository;

  /// Execute the update note operation
  ///
  /// [note] - The note with updated information
  ///
  /// Returns [Note] on success or [Failure] on error
  Future<Either<Failure, Note>> call(Note note) async =>
      repository.updateNote(note);
}
