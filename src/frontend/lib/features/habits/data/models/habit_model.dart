// ignore_for_file: cascade_invocations
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:frontend/features/habits/domain/entities/habit.dart';

/// Habit field model (data layer)
///
/// Extends [HabitField] and adds methods for serialization/deserialization
/// of data for working with Firestore.
class HabitFieldModel extends HabitField {
  const HabitFieldModel({
    required super.type,
    required super.label,
    super.unit,
  });

  /// Creates [HabitFieldModel] from [HabitField]
  factory HabitFieldModel.fromEntity(HabitField entity) => HabitFieldModel(
    type: entity.type,
    label: entity.label,
    unit: entity.unit,
  );

  /// Creates [HabitFieldModel] from JSON (Map)
  ///
  /// Used for deserializing data from Firestore
  factory HabitFieldModel.fromJson(Map<String, dynamic> json) =>
      HabitFieldModel(
        type: json['type'] as String,
        label: json['label'] as String,
        unit: json['unit'] as String?,
      );

  /// Converts [HabitFieldModel] to JSON (Map)
  ///
  /// Used for serializing data before saving to Firestore
  Map<String, dynamic> toJson() => {
    'type': type,
    'label': label,
    if (unit != null) 'unit': unit,
  };

  /// Copies the model with the ability to change individual fields
  @override
  HabitFieldModel copyWith({String? type, String? label, String? unit}) =>
      HabitFieldModel(
        type: type ?? this.type,
        label: label ?? this.label,
        unit: unit ?? this.unit,
      );
}

/// Habit entry model (data layer)
///
/// Extends [HabitEntry] and adds methods for serialization/deserialization
/// of data for working with Firestore.
class HabitEntryModel extends HabitEntry {
  const HabitEntryModel({required super.date, required super.values});

  /// Creates [HabitEntryModel] from [HabitEntry]
  factory HabitEntryModel.fromEntity(HabitEntry entity) => HabitEntryModel(
    date: entity.date,
    values: Map<String, dynamic>.from(entity.values),
  );

  /// Creates [HabitEntryModel] from JSON (Map)
  ///
  /// Used for deserializing data from Firestore
  factory HabitEntryModel.fromJson(Map<String, dynamic> json) =>
      HabitEntryModel(
        date: json['date'] as String,
        values: Map<String, dynamic>.from(json['values'] as Map),
      );

  /// Converts [HabitEntryModel] to JSON (Map)
  ///
  /// Used for serializing data before saving to Firestore
  Map<String, dynamic> toJson() => {'date': date, 'values': values};

  /// Copies the model with the ability to change individual fields
  @override
  HabitEntryModel copyWith({String? date, Map<String, dynamic>? values}) =>
      HabitEntryModel(date: date ?? this.date, values: values ?? this.values);
}

/// Habit model (data layer)
///
/// Extends [Habit] and adds methods for serialization/deserialization
/// of data for working with Firestore.
class HabitModel extends Habit {
  const HabitModel({
    required super.id,
    required super.userId,
    required super.name,
    required super.fields,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Creates [HabitModel] from [Habit]
  factory HabitModel.fromEntity(Habit entity) => HabitModel(
    id: entity.id,
    userId: entity.userId,
    name: entity.name,
    fields: entity.fields.map(HabitFieldModel.fromEntity).toList(),
    createdAt: entity.createdAt,
    updatedAt: entity.updatedAt,
  );

  /// Creates [HabitModel] from JSON (Map)
  ///
  /// Used for deserializing data from Firestore
  factory HabitModel.fromJson(Map<String, dynamic> json) => HabitModel(
    id: json['id'] as String,
    userId: json['userId'] as String,
    name: json['name'] as String,
    fields: (json['fields'] as List<dynamic>)
        .map((field) => HabitFieldModel.fromJson(field as Map<String, dynamic>))
        .toList(),
    createdAt: (json['createdAt'] as Timestamp).toDate(),
    updatedAt: (json['updatedAt'] as Timestamp).toDate(),
  );

  /// Creates [HabitModel] from Firestore DocumentSnapshot
  factory HabitModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    return HabitModel.fromJson({'id': doc.id, ...data});
  }

  /// Converts [HabitModel] to JSON (Map)
  ///
  /// Used for serializing data before saving to Firestore
  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'name': name,
    'fields': fields.map((field) {
      // If field is already a HabitFieldModel, use it directly
      // Otherwise, convert from HabitField entity
      if (field is HabitFieldModel) {
        return field.toJson();
      } else {
        return HabitFieldModel.fromEntity(field).toJson();
      }
    }).toList(),
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': Timestamp.fromDate(updatedAt),
  };

  /// Converts [HabitModel] to Map for Firestore (without id)
  ///
  /// ID is usually stored as the document key, so it's not included in the data
  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id');
    return json;
  }

  /// Copies the model with the ability to change individual fields
  @override
  HabitModel copyWith({
    String? id,
    String? userId,
    String? name,
    List<HabitField>? fields,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => HabitModel(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    name: name ?? this.name,
    fields: fields ?? this.fields,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}
