import 'package:dartz/dartz.dart';
import '../../../../core/utils/failure.dart';
import '../entities/note.dart';
import '../repositories/notes_repository.dart';

/// Use case for retrieving all notes for a user
class GetNotes {
  final NotesRepository repository;

  GetNotes(this.repository);

  /// Execute the get notes operation
  ///
  /// [userId] - ID of the user whose notes to retrieve
  ///
  /// Returns [List<Note>] on success or [Failure] on error
  Future<Either<Failure, List<Note>>> call(String userId) async {
    return await repository.getNotes(userId);
  }
}
