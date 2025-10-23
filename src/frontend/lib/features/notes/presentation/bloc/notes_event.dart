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
  const LoadNotesEvent(this.userId);
  final String userId;

  @override
  List<Object?> get props => [userId];
}

/// Event to create a new note
class CreateNoteEvent extends NotesEvent {
  const CreateNoteEvent(this.note);
  final Note note;

  @override
  List<Object?> get props => [note];
}

/// Event to update an existing note
class UpdateNoteEvent extends NotesEvent {
  const UpdateNoteEvent(this.note);
  final Note note;

  @override
  List<Object?> get props => [note];
}

/// Event to delete a note
class DeleteNoteEvent extends NotesEvent {
  const DeleteNoteEvent(this.noteId);
  final String noteId;

  @override
  List<Object?> get props => [noteId];
}
