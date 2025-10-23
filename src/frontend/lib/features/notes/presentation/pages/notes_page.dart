// ignore_for_file: discarded_futures, inference_failure_on_instance_creation, inference_failure_on_function_invocation, avoid_print, dead_code, unawaited_futures, cascade_invocations
import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart' as di;
import '../../domain/entities/note.dart';
import '../bloc/notes_bloc.dart';
import '../bloc/notes_event.dart';
import '../bloc/notes_state.dart';
import 'create_edit_note_page.dart';

/// Notes page showing list of user's notes
class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  late final String userId;

  // For UNDO DELETE functionality
  final List<Note> _deletedNotes = [];

  // For MULTIPLE SELECTION DELETE functionality
  bool _isSelectionMode = false;
  final Set<String> _selectedNoteIds = {};

  @override
  void initState() {
    super.initState();
    // Get current user ID from FirebaseAuth
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      // Handle case where user is not authenticated
      userId = '';
    } else {
      userId = currentUser.uid;
    }
  }

  /// Enter selection mode
  void _enterSelectionMode(String noteId) {
    setState(() {
      _isSelectionMode = true;
      _selectedNoteIds.add(noteId);
    });
  }

  /// Exit selection mode
  void _exitSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectedNoteIds.clear();
    });
  }

  /// Toggle note selection
  void _toggleNoteSelection(String noteId) {
    setState(() {
      if (_selectedNoteIds.contains(noteId)) {
        _selectedNoteIds.remove(noteId);
        // Exit selection mode if no notes selected
        if (_selectedNoteIds.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedNoteIds.add(noteId);
      }
    });
  }

  /// Delete selected notes
  Future<void> _deleteSelectedNotes(BuildContext context) async {
    print(
      '🗑️ Delete selected notes called, count: ${_selectedNoteIds.length}',
    );

    if (_selectedNoteIds.isEmpty) {
      print('⚠️ No notes selected, returning');
      return;
    }

    // Get references before async gap
    final notesBloc = context.read<NotesBloc>();
    final messenger = ScaffoldMessenger.of(context);
    final count = _selectedNoteIds.length;

    print('📋 Showing confirmation dialog for $count notes');

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Delete $count note${count > 1 ? 's' : ''}?'),
        content: Text(
          count > 1
              ? 'You can undo this action from the notification.'
              : 'You can undo this action from the notification.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              print('❌ Delete cancelled');
              Navigator.of(dialogContext).pop(false);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              print('✅ Delete confirmed');
              Navigator.of(dialogContext).pop(true);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    print('Dialog result: $confirmed, mounted: $mounted');

    if (confirmed ?? false && mounted) {
      print('🔄 Deleting $count notes...');

      // Get current notes from state to store deleted ones
      final currentState = notesBloc.state;
      if (currentState is NotesLoaded) {
        // Store all notes that will be deleted for UNDO functionality
        setState(() {
          _deletedNotes.clear();
          _deletedNotes.addAll(
            currentState.notes.where(
              (note) => _selectedNoteIds.contains(note.id),
            ),
          );
        });
      }

      // Store note IDs before clearing
      final noteIdsToDelete = List<String>.from(_selectedNoteIds);

      // Delete all selected notes
      for (final noteId in noteIdsToDelete) {
        print('  - Deleting note: $noteId');
        notesBloc.add(DeleteNoteEvent(noteId));
      }

      // Show confirmation message with UNDO option
      messenger
          .showSnackBar(
            SnackBar(
              content: Text('$count note${count > 1 ? 's' : ''} deleted'),
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.only(bottom: 80, left: 16, right: 16),
              action: SnackBarAction(
                label: count > 1 ? 'UNDO ALL' : 'UNDO',
                onPressed: () {
                  // Restore all deleted notes
                  if (_deletedNotes.isNotEmpty) {
                    print('🔄 Restoring ${_deletedNotes.length} notes...');

                    // Create all notes in Firestore
                    for (final note in _deletedNotes) {
                      notesBloc.add(CreateNoteEvent(note));
                    }

                    // Immediately reload to show restored notes (faster UI refresh)
                    Future.delayed(const Duration(milliseconds: 100), () {
                      if (mounted) {
                        notesBloc.add(LoadNotesEvent(userId));
                      }
                    });

                    // Clear stored notes
                    setState(_deletedNotes.clear);

                    // Hide current snackbar and show restoration confirmation
                    messenger.hideCurrentSnackBar();
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(
                          '$count note${count > 1 ? 's' : ''} restored',
                        ),
                        duration: const Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                        margin: const EdgeInsets.only(
                          bottom: 80,
                          left: 16,
                          right: 16,
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
          )
          .closed
          .then((_) {
            // Clear stored notes after SnackBar is dismissed
            if (mounted) {
              setState(_deletedNotes.clear);
            }
          });

      print('✅ Notes deleted, exiting selection mode');

      // Exit selection mode
      _exitSelectionMode();
    } else {
      print('⏭️ Delete not confirmed or widget unmounted');
    }
  }

  /// Format date as relative time
  /// Examples: "Just now", "5 minutes ago", "Yesterday at 2:30 PM", "Oct 16, 2025"
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    // Less than 1 minute
    if (difference.inSeconds < 60) {
      return 'Just now';
    }

    // Less than 1 hour
    if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return '$minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
    }

    // Less than 24 hours
    if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
    }

    // Yesterday
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final dateOnly = DateTime(date.year, date.month, date.day);
    if (dateOnly.isAtSameMomentAs(yesterday)) {
      final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
      final minute = date.minute.toString().padLeft(2, '0');
      final period = date.hour >= 12 ? 'PM' : 'AM';
      return 'Yesterday at $hour:$minute $period';
    }

    // Less than 7 days
    if (difference.inDays < 7) {
      final days = difference.inDays;
      return '$days ${days == 1 ? 'day' : 'days'} ago';
    }

    // More than 7 days - show full date
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  /// Show confirmation dialog before deleting note
  Future<bool?> _showDeleteConfirmation(BuildContext context) async =>
      showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Delete note?'),
          content: const Text(
            'You can undo this action from the notification.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        ),
      );

  /// Build empty state widget
  Widget _buildEmptyState() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.note_alt_outlined, size: 64, color: Colors.grey[400]),
        const SizedBox(height: 16),
        Text(
          'No notes yet',
          style: TextStyle(fontSize: 18, color: Colors.grey[600]),
        ),
        const SizedBox(height: 8),
        Text(
          'Tap + to create a note',
          style: TextStyle(fontSize: 14, color: Colors.grey[500]),
        ),
      ],
    ),
  );

  /// Build error state widget
  Widget _buildErrorState(BuildContext context, String message) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
        const SizedBox(height: 16),
        Text(
          'Loading error',
          style: TextStyle(fontSize: 18, color: Colors.grey[700]),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            message,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () {
            context.read<NotesBloc>().add(LoadNotesEvent(userId));
          },
          icon: const Icon(Icons.refresh),
          label: const Text('Try again'),
        ),
      ],
    ),
  );

  /// Build note list item
  Widget _buildNoteItem(BuildContext context, Note note) {
    final contentPreview = note.content.length > 50
        ? '${note.content.substring(0, 50)}...'
        : note.content;
    final formattedDate = _formatDate(note.createdAt);
    final isSelected = _selectedNoteIds.contains(note.id);

    return Dismissible(
      key: Key(note.id),
      // Disable swipe delete in selection mode
      direction: _isSelectionMode
          ? DismissDirection.none
          : DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) => _showDeleteConfirmation(context),
      onDismissed: (direction) {
        // Store deleted note for UNDO functionality
        setState(() {
          _deletedNotes.clear();
          _deletedNotes.add(note);
        });

        // Delete the note
        context.read<NotesBloc>().add(DeleteNoteEvent(note.id));

        // Show SnackBar with UNDO option
        final messenger = ScaffoldMessenger.of(context);
        final bloc = context.read<NotesBloc>();

        // Fire-and-forget: show SnackBar and clear state when dismissed
        unawaited(
          messenger
              .showSnackBar(
                SnackBar(
                  content: const Text('Note deleted'),
                  duration: const Duration(seconds: 3),
                  behavior: SnackBarBehavior.floating,
                  margin: const EdgeInsets.only(bottom: 80, left: 16, right: 16),
                  action: SnackBarAction(
                    label: 'UNDO',
                    onPressed: () {
                      // Restore the deleted note
                      if (_deletedNotes.isNotEmpty) {
                        final deletedNote = _deletedNotes.first;
                        print('🔄 Restoring note: ${deletedNote.title}');

                        // Create the note in Firestore
                        bloc.add(CreateNoteEvent(deletedNote));

                        // Immediately reload to show restored note (faster UI refresh)
                        Future.delayed(const Duration(milliseconds: 100), () {
                          if (mounted) {
                            bloc.add(LoadNotesEvent(userId));
                          }
                        });

                        // Clear stored note
                        setState(_deletedNotes.clear);

                        // Hide current snackbar and show restoration confirmation
                        messenger.hideCurrentSnackBar();
                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text('Note restored'),
                            duration: Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                            margin: EdgeInsets.only(
                              bottom: 80,
                              left: 16,
                              right: 16,
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),
              )
              .closed
              .then((_) {
                // Clear stored note after SnackBar is dismissed (timeout or action)
                if (mounted) {
                  setState(_deletedNotes.clear);
                }
              }),
        );
      },
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.only(bottom: 12),
        // Highlight selected cards
        color: isSelected ? Colors.blue.withValues(alpha: 0.1) : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          // Add border for selected cards
          side: isSelected
              ? const BorderSide(color: Colors.blue, width: 2)
              : BorderSide.none,
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          // Show checkbox in selection mode
          leading: _isSelectionMode
              ? Checkbox(
                  value: isSelected,
                  onChanged: (value) {
                    _toggleNoteSelection(note.id);
                  },
                )
              : null,
          title: Text(
            note.title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              contentPreview,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formattedDate,
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
              if (note.attachedTo != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Icon(
                    Icons.attach_file,
                    size: 16,
                    color: Colors.grey[500],
                  ),
                ),
            ],
          ),
          onLongPress: () {
            // Enter selection mode on long press
            if (!_isSelectionMode) {
              _enterSelectionMode(note.id);
            }
          },
          onTap: () async {
            // In selection mode, toggle selection
            if (_isSelectionMode) {
              _toggleNoteSelection(note.id);
              return;
            }
            // Get BLoC reference before navigation
            final notesBloc = context.read<NotesBloc>();

            // Navigate to CreateEditNotePage in edit mode
            final result = await Navigator.of(context).push<bool>(
              MaterialPageRoute(
                builder: (_) => BlocProvider(
                  create: (_) => di.sl<NotesBloc>(),
                  child: CreateEditNotePage(note: note),
                ),
              ),
            );
            // Reload if note was saved
            if (result ?? false && mounted) {
              notesBloc.add(LoadNotesEvent(userId));
            }
          },
        ),
      ),
    );
  }

  /// Build notes list widget
  Widget _buildNotesList(BuildContext context, List<Note> notes) =>
      RefreshIndicator(
        onRefresh: () async {
          context.read<NotesBloc>().add(LoadNotesEvent(userId));
          // Wait a bit for the bloc to process
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: notes.length,
          itemBuilder: (context, index) =>
              _buildNoteItem(context, notes[index]),
        ),
      );

  @override
  Widget build(BuildContext context) {
    // Handle unauthenticated user
    if (userId.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Notes')),
        body: const Center(child: Text('Please sign in')),
      );
    }

    return BlocProvider(
      create: (context) => di.sl<NotesBloc>()..add(LoadNotesEvent(userId)),
      child: Builder(
        builder: (context) => Scaffold(
          // Show custom AppBar in selection mode
          appBar: _isSelectionMode
              ? AppBar(
                  leading: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _exitSelectionMode,
                  ),
                  title: Text('Selected: ${_selectedNoteIds.length}'),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _deleteSelectedNotes(context),
                    ),
                  ],
                )
              : null,
          body: BlocBuilder<NotesBloc, NotesState>(
            builder: (context, state) {
              // NotesInitial and NotesLoading states
              if (state is NotesInitial || state is NotesLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              // NotesLoaded state
              if (state is NotesLoaded) {
                if (state.notes.isEmpty) {
                  return _buildEmptyState();
                }
                return _buildNotesList(context, state.notes);
              }

              // NotesError state
              if (state is NotesError) {
                return _buildErrorState(context, state.message);
              }

              // Unknown state
              return const Center(child: Text('Unknown state'));
            },
          ),
          floatingActionButton: _isSelectionMode
              ? null // Hide FAB in selection mode
              : Builder(
                  builder: (fabContext) => FloatingActionButton(
                    heroTag: 'notes_fab',
                    onPressed: () async {
                      // Get BLoC reference before navigation
                      final notesBloc = fabContext.read<NotesBloc>();

                      // Navigate to CreateEditNotePage in create mode
                      final result = await Navigator.of(fabContext).push<bool>(
                        MaterialPageRoute(
                          builder: (_) => BlocProvider(
                            create: (_) => di.sl<NotesBloc>(),
                            child: const CreateEditNotePage(),
                          ),
                        ),
                      );

                      // Reload if note was saved
                      if (result ?? false && mounted) {
                        notesBloc.add(LoadNotesEvent(userId));
                      }
                    },
                    child: const Icon(Icons.add),
                  ),
                ),
        ),
      ),
    );
  }
}
