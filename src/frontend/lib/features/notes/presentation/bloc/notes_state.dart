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
  const NotesLoaded(this.notes);
  final List<Note> notes;

  @override
  List<Object?> get props => [notes];
}

/// Error state with error message
class NotesError extends NotesState {
  const NotesError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
