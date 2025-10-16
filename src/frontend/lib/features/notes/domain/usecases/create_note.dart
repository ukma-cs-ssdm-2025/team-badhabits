import 'package:dartz/dartz.dart';
import '../../../../core/utils/failure.dart';
import '../entities/note.dart';
import '../repositories/notes_repository.dart';

/// Use case for creating a new note
class CreateNote {
  final NotesRepository repository;

  CreateNote(this.repository);

  /// Execute the create note operation
  ///
  /// [note] - The note to create
  ///
  /// Returns [Note] on success or [Failure] on error
  Future<Either<Failure, Note>> call(Note note) async {
    return await repository.createNote(note);
  }
}
