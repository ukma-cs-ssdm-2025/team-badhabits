import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/note_model.dart';

/// Remote data source for notes operations
///
/// Handles direct communication with Firestore
abstract class NotesFirestoreDataSource {
  /// Get all notes for a specific user
  Future<List<NoteModel>> getNotes(String userId);

  /// Create a new note
  Future<NoteModel> createNote(NoteModel note);

  /// Update an existing note
  Future<NoteModel> updateNote(NoteModel note);

  /// Delete a note by ID
  Future<void> deleteNote(String noteId);
}

/// Implementation of [NotesFirestoreDataSource]
class NotesFirestoreDataSourceImpl implements NotesFirestoreDataSource {
  final FirebaseFirestore firestore;

  NotesFirestoreDataSourceImpl({
    required this.firestore,
  });

  @override
  Future<List<NoteModel>> getNotes(String userId) async {
    try {
      final querySnapshot = await firestore
          .collection('notes')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => NoteModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get notes: $e');
    }
  }

  @override
  Future<NoteModel> createNote(NoteModel note) async {
    try {
      // Generate new document ID
      final docRef = firestore.collection('notes').doc();
      final now = DateTime.now();

      // Create note with generated ID and current timestamp
      final newNote = NoteModel(
        id: docRef.id,
        userId: note.userId,
        title: note.title,
        content: note.content,
        createdAt: now,
        updatedAt: now,
        attachedTo: note.attachedTo,
      );

      // Save to Firestore
      await docRef.set(newNote.toFirestore());

      return newNote;
    } catch (e) {
      throw Exception('Failed to create note: $e');
    }
  }

  @override
  Future<NoteModel> updateNote(NoteModel note) async {
    try {
      final now = DateTime.now();

      // Create updated note with new timestamp
      final updatedNote = NoteModel(
        id: note.id,
        userId: note.userId,
        title: note.title,
        content: note.content,
        createdAt: note.createdAt,
        updatedAt: now,
        attachedTo: note.attachedTo,
      );

      // Update in Firestore
      await firestore
          .collection('notes')
          .doc(note.id)
          .update(updatedNote.toFirestore());

      return updatedNote;
    } catch (e) {
      throw Exception('Failed to update note: $e');
    }
  }

  @override
  Future<void> deleteNote(String noteId) async {
    try {
      await firestore.collection('notes').doc(noteId).delete();
    } catch (e) {
      throw Exception('Failed to delete note: $e');
    }
  }
}
