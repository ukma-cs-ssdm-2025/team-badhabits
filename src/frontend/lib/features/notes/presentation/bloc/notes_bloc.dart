// ignore_for_file: avoid_print
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/create_note.dart';
import '../../domain/usecases/delete_note.dart';
import '../../domain/usecases/get_notes.dart';
import '../../domain/usecases/update_note.dart';
import 'notes_event.dart';
import 'notes_state.dart';

/// BLoC for managing notes state
class NotesBloc extends Bloc<NotesEvent, NotesState> {
  NotesBloc({
    required this.getNotes,
    required this.createNote,
    required this.updateNote,
    required this.deleteNote,
  }) : super(const NotesInitial()) {
    on<LoadNotesEvent>(_onLoadNotes);
    on<CreateNoteEvent>(_onCreateNote);
    on<UpdateNoteEvent>(_onUpdateNote);
    on<DeleteNoteEvent>(_onDeleteNote);
  }
  final GetNotes getNotes;
  final CreateNote createNote;
  final UpdateNote updateNote;
  final DeleteNote deleteNote;

  /// Handle load notes request
  Future<void> _onLoadNotes(
    LoadNotesEvent event,
    Emitter<NotesState> emit,
  ) async {
    print('🔵 NotesBloc: Loading notes for user ${event.userId}...');
    emit(const NotesLoading());

    final result = await getNotes(event.userId);

    result.fold(
      (failure) {
        print('🔴 NotesBloc: Load failed - ${failure.message}');
        emit(NotesError(failure.message));
      },
      (notes) {
        print('🟢 NotesBloc: Loaded ${notes.length} notes');
        emit(NotesLoaded(notes));
      },
    );
  }

  /// Handle create note request
  Future<void> _onCreateNote(
    CreateNoteEvent event,
    Emitter<NotesState> emit,
  ) async {
    print('🔵 NotesBloc: Creating note...');
    emit(const NotesLoading());

    final result = await createNote(event.note);

    result.fold(
      (failure) {
        print('🔴 NotesBloc: Create failed - ${failure.message}');
        emit(NotesError(failure.message));
      },
      (createdNote) {
        print(
          '🟢 NotesBloc: Note created successfully with ID: ${createdNote.id}',
        );
        // Emit success state - parent page will reload
        emit(const NotesLoaded([]));
      },
    );
  }

  /// Handle update note request
  Future<void> _onUpdateNote(
    UpdateNoteEvent event,
    Emitter<NotesState> emit,
  ) async {
    print('🔵 NotesBloc: Updating note...');
    emit(const NotesLoading());

    final result = await updateNote(event.note);

    result.fold(
      (failure) {
        print('🔴 NotesBloc: Update failed - ${failure.message}');
        emit(NotesError(failure.message));
      },
      (updatedNote) {
        print('🟢 NotesBloc: Note updated successfully');
        // Emit success state - parent page will reload
        emit(const NotesLoaded([]));
      },
    );
  }

  /// Handle delete note request
  Future<void> _onDeleteNote(
    DeleteNoteEvent event,
    Emitter<NotesState> emit,
  ) async {
    // Get current userId from state
    String? userId;
    if (state is NotesLoaded) {
      final currentState = state as NotesLoaded;
      if (currentState.notes.isNotEmpty) {
        userId = currentState.notes.first.userId;
      }
    }

    emit(const NotesLoading());

    final result = await deleteNote(event.noteId);

    await result.fold((failure) async => emit(NotesError(failure.message)), (
      _,
    ) async {
      // Reload notes after successful deletion
      if (userId != null) {
        final notesResult = await getNotes(userId);
        notesResult.fold(
          (failure) => emit(NotesError(failure.message)),
          (notes) => emit(NotesLoaded(notes)),
        );
      } else {
        emit(const NotesError('Unable to reload notes: user ID not found'));
      }
    });
  }
}
