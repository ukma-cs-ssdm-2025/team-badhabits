import 'package:equatable/equatable.dart';
import '../../domain/entities/note.dart';

/// Base class for notes states
abstract class NotesState extends Equatable {
  const NotesState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any notes are loaded
class NotesInitial extends NotesState {
  const NotesInitial();
}

/// Loading state while fetching/creating/updating/deleting notes
class NotesLoading extends NotesState {
  const NotesLoading();
}

/// Successfully loaded notes state
class NotesLoaded extends NotesState {
  final List<Note> notes;

  const NotesLoaded(this.notes);

  @override
  List<Object?> get props => [notes];
}

/// Error state with error message
class NotesError extends NotesState {
  final String message;

  const NotesError(this.message);

  @override
  List<Object?> get props => [message];
}
