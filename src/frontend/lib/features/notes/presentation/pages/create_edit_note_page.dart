import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/note.dart';
import '../bloc/notes_bloc.dart';
import '../bloc/notes_event.dart';
import '../bloc/notes_state.dart';

/// Page for creating and editing notes
class CreateEditNotePage extends StatefulWidget {
  /// Note to edit (null for create mode)
  final Note? note;

  const CreateEditNotePage({
    super.key,
    this.note,
  });

  @override
  State<CreateEditNotePage> createState() => _CreateEditNotePageState();
}

class _CreateEditNotePageState extends State<CreateEditNotePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  bool _isLoading = false;

  /// Check if in edit mode
  bool get isEditMode => widget.note != null;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing note data if in edit mode
    _titleController = TextEditingController(
      text: widget.note?.title ?? '',
    );
    _contentController = TextEditingController(
      text: widget.note?.content ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  /// Save note (create or update)
  Future<void> _saveNote() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Get current user ID
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: user not authenticated'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Set loading state
    setState(() {
      _isLoading = true;
    });

    try {
      // Create note entity
      final note = Note(
        id: widget.note?.id ?? '', // Empty for create, Firestore will generate
        userId: currentUser.uid,
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        createdAt: widget.note?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        attachedTo: widget.note?.attachedTo, // Preserve attachment if exists
      );

      // Add appropriate event to bloc
      if (isEditMode) {
        context.read<NotesBloc>().add(UpdateNoteEvent(note));
      } else {
        context.read<NotesBloc>().add(CreateNoteEvent(note));
      }
    } catch (e) {
      // Handle error
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<NotesBloc, NotesState>(
      listener: (context, state) {
        print('📝 CreateEditNotePage state changed: ${state.runtimeType}');
        if (state is NotesLoaded) {
          print('✅ Note saved successfully, closing page with result=true');
          // Note saved successfully
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isEditMode
                    ? 'Note updated successfully'
                    : 'Note created successfully',
              ),
              backgroundColor: Colors.green,
            ),
          );
          // Return true to indicate successful save
          Navigator.of(context).pop(true);
        } else if (state is NotesError) {
          // Error occurred
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            isEditMode ? 'Edit Note' : 'Create Note',
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _isLoading
                ? null
                : () => Navigator.of(context).pop(),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Title field
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    hintText: 'Enter note title',
                    prefixIcon: Icon(Icons.title),
                    border: OutlineInputBorder(),
                    counterText: '',
                  ),
                  maxLength: 100,
                  textInputAction: TextInputAction.next,
                  enabled: !_isLoading,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a title';
                    }
                    if (value.trim().length < 2) {
                      return 'Title must be at least 2 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Content field
                TextFormField(
                  controller: _contentController,
                  decoration: const InputDecoration(
                    labelText: 'Content',
                    hintText: 'Enter note content',
                    prefixIcon: Icon(Icons.description),
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 10,
                  minLines: 5,
                  textInputAction: TextInputAction.newline,
                  enabled: !_isLoading,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter content';
                    }
                    if (value.trim().length < 5) {
                      return 'Content must be at least 5 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Save button
                ElevatedButton(
                  onPressed: _isLoading ? null : _saveNote,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Save',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
