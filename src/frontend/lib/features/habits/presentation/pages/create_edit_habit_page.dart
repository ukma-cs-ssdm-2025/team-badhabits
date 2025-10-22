// ignore_for_file: deprecated_member_use, avoid_print
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/habits/domain/entities/habit.dart';
import 'package:frontend/features/habits/presentation/bloc/habits_bloc.dart';
import 'package:frontend/features/habits/presentation/bloc/habits_event.dart';
import 'package:frontend/features/habits/presentation/bloc/habits_state.dart';

/// Page for creating and editing habits
class CreateEditHabitPage extends StatefulWidget {
  const CreateEditHabitPage({super.key, this.habit});

  /// Habit to edit (null for create mode)
  final Habit? habit;

  @override
  State<CreateEditHabitPage> createState() => _CreateEditHabitPageState();
}

class _CreateEditHabitPageState extends State<CreateEditHabitPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  bool _isLoading = false;

  // Fields list
  List<_FieldData> _fields = [];

  /// Check if in edit mode
  bool get isEditMode => widget.habit != null;

  @override
  void initState() {
    super.initState();
    // Initialize controller with existing habit data if in edit mode
    _nameController = TextEditingController(text: widget.habit?.name ?? '');

    // Initialize fields from existing habit or with one empty field
    if (widget.habit != null) {
      _fields = widget.habit!.fields
          .map(
            (field) => _FieldData(
              type: field.type,
              label: field.label,
              unit: field.unit,
            ),
          )
          .toList();
    } else {
      _fields = [_FieldData()];
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    for (final field in _fields) {
      field.dispose();
    }
    super.dispose();
  }

  /// Add new field
  void _addField() {
    setState(() {
      _fields.add(_FieldData());
    });
  }

  /// Remove field at index
  void _removeField(int index) {
    setState(() {
      _fields[index].dispose();
      _fields.removeAt(index);
    });
  }

  /// Save habit (create or update)
  Future<void> _saveHabit() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate at least one field
    if (_fields.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one tracking field'),
          backgroundColor: Colors.orange,
        ),
      );
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
      // Convert fields to HabitField entities
      final habitFields = _fields
          .map(
            (field) => HabitField(
              type: field.type,
              label: field.labelController.text.trim(),
              unit: field.unitController.text.trim().isEmpty
                  ? null
                  : field.unitController.text.trim(),
            ),
          )
          .toList();

      // Create habit entity
      final habit = Habit(
        id: widget.habit?.id ?? '', // Empty for create, Firestore will generate
        userId: currentUser.uid,
        name: _nameController.text.trim(),
        fields: habitFields,
        createdAt: widget.habit?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Add appropriate event to bloc
      if (isEditMode) {
        context.read<HabitsBloc>().add(UpdateHabitEvent(habit));
      } else {
        context.read<HabitsBloc>().add(CreateHabitEvent(habit));
      }
    } catch (e) {
      // Handle error
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => BlocListener<HabitsBloc, HabitsState>(
    listener: (context, state) {
      print('🔵 CreateEditHabitPage state changed: ${state.runtimeType}');
      if (state is HabitsLoaded) {
        print('✅ Habit saved successfully, closing page with result=true');
        // Habit saved successfully
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEditMode
                  ? 'Habit updated successfully'
                  : 'Habit created successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
        // Return true to indicate successful save
        Navigator.of(context).pop(true);
      } else if (state is HabitsError) {
        // Error occurred
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.message), backgroundColor: Colors.red),
        );
      }
    },
    child: Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Habit' : 'Create Habit'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Habit name field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Habit Name',
                  hintText: 'e.g., Morning Routine, Health Tracker',
                  prefixIcon: Icon(Icons.label),
                  border: OutlineInputBorder(),
                  counterText: '',
                ),
                maxLength: 50,
                textInputAction: TextInputAction.next,
                enabled: !_isLoading,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a habit name';
                  }
                  if (value.trim().length < 2) {
                    return 'Name must be at least 2 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Tracking fields section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Tracking Fields',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton.icon(
                    onPressed: _isLoading ? null : _addField,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Field'),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Fields list
              if (_fields.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange),
                  ),
                  child: const Text(
                    'Add at least one tracking field',
                    style: TextStyle(color: Colors.orange),
                    textAlign: TextAlign.center,
                  ),
                )
              else
                ..._fields.asMap().entries.map((entry) {
                  final index = entry.key;
                  final field = entry.value;
                  return _buildFieldCard(index, field);
                }),

              const SizedBox(height: 24),

              // Save button
              ElevatedButton(
                onPressed: _isLoading ? null : _saveHabit,
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
                        'Save Habit',
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

  /// Build field card widget
  Widget _buildFieldCard(int index, _FieldData field) => Card(
    margin: const EdgeInsets.only(bottom: 12),
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with field number and remove button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Field ${index + 1}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete, size: 20),
                onPressed: _isLoading ? null : () => _removeField(index),
                color: Colors.red,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Field type dropdown
          DropdownButtonFormField<String>(
            initialValue: field.type,
            decoration: const InputDecoration(
              labelText: 'Field Type',
              prefixIcon: Icon(Icons.category),
              border: OutlineInputBorder(),
              isDense: true,
            ),
            items: const [
              DropdownMenuItem(
                value: 'number',
                child: Row(
                  children: [
                    Icon(Icons.numbers, size: 16, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('Number'),
                  ],
                ),
              ),
              DropdownMenuItem(
                value: 'rating',
                child: Row(
                  children: [
                    Icon(Icons.star, size: 16, color: Colors.amber),
                    SizedBox(width: 8),
                    Text('Rating (1-5)'),
                  ],
                ),
              ),
              DropdownMenuItem(
                value: 'text',
                child: Row(
                  children: [
                    Icon(Icons.text_fields, size: 16, color: Colors.green),
                    SizedBox(width: 8),
                    Text('Text'),
                  ],
                ),
              ),
            ],
            onChanged: _isLoading
                ? null
                : (value) {
                    setState(() {
                      field.type = value!;
                    });
                  },
          ),
          const SizedBox(height: 12),

          // Field label
          TextFormField(
            controller: field.labelController,
            decoration: const InputDecoration(
              labelText: 'Label',
              hintText: 'e.g., Water intake, Mood, Exercise',
              prefixIcon: Icon(Icons.text_fields),
              border: OutlineInputBorder(),
              isDense: true,
            ),
            enabled: !_isLoading,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a label';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),

          // Unit field (only for number type)
          if (field.type == 'number')
            TextFormField(
              controller: field.unitController,
              decoration: const InputDecoration(
                labelText: 'Unit (optional)',
                hintText: 'e.g., glasses, minutes, steps',
                prefixIcon: Icon(Icons.straighten),
                border: OutlineInputBorder(),
                isDense: true,
              ),
              enabled: !_isLoading,
            ),

          // Helper text for field type
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.info_outline, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  _getFieldTypeHelp(field.type),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );

  /// Get helper text for field type
  String _getFieldTypeHelp(String type) {
    switch (type) {
      case 'number':
        return 'Track numeric values (e.g., 8 glasses of water)';
      case 'rating':
        return 'Rate on a scale of 1-5 stars';
      case 'text':
        return 'Add short text notes or reflections';
      default:
        return '';
    }
  }
}

/// Field data holder
class _FieldData {
  _FieldData({this.type = 'number', String? label, String? unit})
    : labelController = TextEditingController(text: label ?? ''),
      unitController = TextEditingController(text: unit ?? '');
  String type;
  final TextEditingController labelController;
  final TextEditingController unitController;

  void dispose() {
    labelController.dispose();
    unitController.dispose();
  }
}
