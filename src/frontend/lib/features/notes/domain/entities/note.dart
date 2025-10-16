import 'package:equatable/equatable.dart';

/// Note attachment information
///
/// Represents what entity the note is attached to (e.g., habit, session, goal).
class NoteAttachment extends Equatable {
  /// Type of entity the note is attached to
  final String type;

  /// ID of the entity the note is attached to
  final String id;

  const NoteAttachment({
    required this.type,
    required this.id,
  });

  @override
  List<Object?> get props => [
        type,
        id,
      ];

  /// Copies the attachment with the ability to change individual fields
  NoteAttachment copyWith({
    String? type,
    String? id,
  }) {
    return NoteAttachment(
      type: type ?? this.type,
      id: id ?? this.id,
    );
  }
}

/// Note entity (domain layer)
///
/// Represents a user note in the system.
/// Independent of data sources and used in business logic.
class Note extends Equatable {
  /// Unique note identifier
  final String id;

  /// User ID who created the note
  final String userId;

  /// Note title
  final String title;

  /// Note content
  final String content;

  /// Note creation date
  final DateTime createdAt;

  /// Note last update date
  final DateTime updatedAt;

  /// Optional attachment information (what entity this note is attached to)
  final NoteAttachment? attachedTo;

  const Note({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.attachedTo,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        title,
        content,
        createdAt,
        updatedAt,
        attachedTo,
      ];

  /// Copies the entity with the ability to change individual fields
  Note copyWith({
    String? id,
    String? userId,
    String? title,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    NoteAttachment? attachedTo,
  }) {
    return Note(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      attachedTo: attachedTo ?? this.attachedTo,
    );
  }
}
