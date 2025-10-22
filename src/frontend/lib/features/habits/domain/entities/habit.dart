import 'package:equatable/equatable.dart';

/// Habit field template
///
/// Defines a trackable field for a habit (e.g., water intake, mood rating).
/// Each habit can have multiple fields with different types.
class HabitField extends Equatable {
  const HabitField({required this.type, required this.label, this.unit});

  /// Type of the field
  ///
  /// Supported types:
  /// - 'number': Numeric input (e.g., water glasses, exercise minutes)
  /// - 'rating': Rating scale (e.g., mood 1-5, energy 1-10)
  /// - 'text': Free text input (e.g., notes, reflections)
  final String type;

  /// Display label for the field
  ///
  /// Examples: 'Water glasses', 'Mood', 'Notes', 'Exercise minutes'
  final String label;

  /// Optional unit for numeric fields
  ///
  /// Examples: 'glasses', 'minutes', 'steps', 'km'
  /// null for rating and text fields
  final String? unit;

  @override
  List<Object?> get props => [type, label, unit];

  /// Copies the field with the ability to change individual properties
  HabitField copyWith({String? type, String? label, String? unit}) =>
      HabitField(
        type: type ?? this.type,
        label: label ?? this.label,
        unit: unit ?? this.unit,
      );
}

/// Habit entry (daily tracking record)
///
/// Represents a single day's tracking data for a habit.
/// Contains values for all fields defined in the habit template.
class HabitEntry extends Equatable {
  const HabitEntry({required this.date, required this.values});

  /// Date of the entry in YYYY-MM-DD format
  ///
  /// Example: '2024-10-16'
  final String date;

  /// Field values for this entry
  ///
  /// Map keys correspond to field labels from the habit template.
  /// Map values contain the actual tracked data:
  /// - number fields: int or double
  /// - rating fields: int
  /// - text fields: String
  ///
  /// Example: {'Water glasses': 8, 'Mood': 4, 'Notes': 'Felt great today'}
  final Map<String, dynamic> values;

  @override
  List<Object?> get props => [date, values];

  /// Copies the entry with the ability to change individual properties
  HabitEntry copyWith({String? date, Map<String, dynamic>? values}) =>
      HabitEntry(date: date ?? this.date, values: values ?? this.values);
}

/// Habit entity (domain layer)
///
/// Represents a user's trackable habit in the system.
/// Independent of data sources and used in business logic.
///
/// A habit defines a template with multiple fields that can be tracked daily.
/// Example: "Health Routine" habit with fields for water intake, exercise, and mood.
class Habit extends Equatable {
  const Habit({
    required this.id,
    required this.userId,
    required this.name,
    required this.fields,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Unique habit identifier
  final String id;

  /// User ID who created the habit
  final String userId;

  /// Habit name
  ///
  /// Examples: 'Morning Routine', 'Health Tracker', 'Fitness Goals'
  final String name;

  /// Template fields for this habit
  ///
  /// Defines what data can be tracked for this habit.
  /// Each field has a type (number, rating, text), label, and optional unit.
  ///
  /// Example: [
  ///   HabitField(type: 'number', label: 'Water glasses', unit: 'glasses'),
  ///   HabitField(type: 'rating', label: 'Mood', unit: null),
  ///   HabitField(type: 'text', label: 'Notes', unit: null),
  /// ]
  final List<HabitField> fields;

  /// Habit creation date
  final DateTime createdAt;

  /// Habit last update date
  final DateTime updatedAt;

  @override
  List<Object?> get props => [id, userId, name, fields, createdAt, updatedAt];

  /// Copies the entity with the ability to change individual fields
  Habit copyWith({
    String? id,
    String? userId,
    String? name,
    List<HabitField>? fields,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Habit(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    name: name ?? this.name,
    fields: fields ?? this.fields,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}
