import 'package:dartz/dartz.dart';
import '../../../../core/utils/failure.dart';
import '../repositories/notes_repository.dart';

/// Use case for deleting a note
class DeleteNote {
  DeleteNote(this.repository);
  final NotesRepository repository;

  /// Execute the delete note operation
  ///
  /// [noteId] - ID of the note to delete
  ///
  /// Returns [void] on success or [Failure] on error
  Future<Either<Failure, void>> call(String noteId) async =>
      repository.deleteNote(noteId);
}
