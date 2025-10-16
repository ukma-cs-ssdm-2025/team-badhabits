import 'package:equatable/equatable.dart';
import '../../domain/entities/note.dart';

/// Base class for notes events
abstract class NotesEvent extends Equatable {
  const NotesEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load all notes for a user
class LoadNotesEvent extends NotesEvent {
  final String userId;

  const LoadNotesEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Event to create a new note
class CreateNoteEvent extends NotesEvent {
  final Note note;

  const CreateNoteEvent(this.note);

  @override
  List<Object?> get props => [note];
}

/// Event to update an existing note
class UpdateNoteEvent extends NotesEvent {
  final Note note;

  const UpdateNoteEvent(this.note);

  @override
  List<Object?> get props => [note];
}

/// Event to delete a note
class DeleteNoteEvent extends NotesEvent {
  final String noteId;

  const DeleteNoteEvent(this.noteId);

  @override
  List<Object?> get props => [noteId];
}
