import 'package:dartz/dartz.dart';
import '../../../../core/utils/failure.dart';
import '../entities/note.dart';
import '../repositories/notes_repository.dart';

/// Use case for creating a new note
class CreateNote {
  CreateNote(this.repository);
  final NotesRepository repository;

  /// Execute the create note operation
  ///
  /// [note] - The note to create
  ///
  /// Returns [Note] on success or [Failure] on error
  Future<Either<Failure, Note>> call(Note note) async =>
      repository.createNote(note);
}
