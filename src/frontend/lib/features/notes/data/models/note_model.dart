import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/note.dart';

/// Note attachment model (data layer)
///
/// Extends [NoteAttachment] and adds methods for serialization/deserialization
/// of data for working with Firestore.
class NoteAttachmentModel extends NoteAttachment {
  const NoteAttachmentModel({
    required super.type,
    required super.id,
  });

  /// Creates [NoteAttachmentModel] from [NoteAttachment]
  factory NoteAttachmentModel.fromEntity(NoteAttachment entity) {
    return NoteAttachmentModel(
      type: entity.type,
      id: entity.id,
    );
  }

  /// Creates [NoteAttachmentModel] from JSON (Map)
  ///
  /// Used for deserializing data from Firestore
  factory NoteAttachmentModel.fromJson(Map<String, dynamic> json) {
    return NoteAttachmentModel(
      type: json['type'] as String,
      id: json['id'] as String,
    );
  }

  /// Converts [NoteAttachmentModel] to JSON (Map)
  ///
  /// Used for serializing data before saving to Firestore
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'id': id,
    };
  }

  /// Copies the model with the ability to change individual fields
  @override
  NoteAttachmentModel copyWith({
    String? type,
    String? id,
  }) {
    return NoteAttachmentModel(
      type: type ?? this.type,
      id: id ?? this.id,
    );
  }
}

/// Note model (data layer)
///
/// Extends [Note] and adds methods for serialization/deserialization
/// of data for working with Firestore.
class NoteModel extends Note {
  const NoteModel({
    required super.id,
    required super.userId,
    required super.title,
    required super.content,
    required super.createdAt,
    required super.updatedAt,
    super.attachedTo,
  });

  /// Creates [NoteModel] from [Note]
  factory NoteModel.fromEntity(Note entity) {
    return NoteModel(
      id: entity.id,
      userId: entity.userId,
      title: entity.title,
      content: entity.content,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      attachedTo: entity.attachedTo != null
          ? NoteAttachmentModel.fromEntity(entity.attachedTo!)
          : null,
    );
  }

  /// Creates [NoteModel] from JSON (Map)
  ///
  /// Used for deserializing data from Firestore
  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
      attachedTo: json['attachedTo'] != null
          ? NoteAttachmentModel.fromJson(json['attachedTo'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Creates [NoteModel] from Firestore DocumentSnapshot
  factory NoteModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NoteModel.fromJson({
      'id': doc.id,
      ...data,
    });
  }

  /// Converts [NoteModel] to JSON (Map)
  ///
  /// Used for serializing data before saving to Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      if (attachedTo != null)
        'attachedTo': NoteAttachmentModel.fromEntity(attachedTo!).toJson(),
    };
  }

  /// Converts [NoteModel] to Map for Firestore (without id)
  ///
  /// ID is usually stored as the document key, so it's not included in the data
  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id');
    return json;
  }

  /// Copies the model with the ability to change individual fields
  @override
  NoteModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    NoteAttachment? attachedTo,
  }) {
    return NoteModel(
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
