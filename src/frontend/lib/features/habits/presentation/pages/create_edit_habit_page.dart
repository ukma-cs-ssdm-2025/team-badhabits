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
  late TextEditingController _descriptionController;
  bool _isLoading = false;

  // Fields list
  List<_FieldData> _fields = [];

  // New fields for UX improvement
  String? _selectedCategory;
  String _selectedIcon = 'track_changes';

  // Categories
  final _categories = [
    'Fitness',
    'Health',
    'Productivity',
    'Learning',
    'Mindfulness',
    'Social',
    'Finance',
    'Hobbies',
    'Other',
  ];

  // Icons
  final _habitIcons = {
    'track_changes': Icons.track_changes,
    'fitness': Icons.fitness_center,
    'water': Icons.water_drop,
    'book': Icons.book,
    'meditation': Icons.self_improvement,
    'sleep': Icons.bedtime,
    'food': Icons.restaurant,
    'work': Icons.work,
    'study': Icons.school,
    'run': Icons.directions_run,
    'bike': Icons.directions_bike,
    'heart': Icons.favorite,
  };

  /// Check if in edit mode
  bool get isEditMode => widget.habit != null;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing habit data if in edit mode
    _nameController = TextEditingController(text: widget.habit?.name ?? '');
    _descriptionController = TextEditingController(text: '');

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
    _descriptionController.dispose();
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

  /// Show templates bottom sheet
  Future<void> _showTemplatesBottomSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Habit Templates',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView(
                controller: scrollController,
                children: [
                  _buildTemplateCard(
                    title: 'Drink Water',
                    description: 'Track daily water intake',
                    icon: Icons.water_drop,
                    iconKey: 'water',
                    category: 'Health',
                    fields: [
                      _FieldData(label: 'Glasses', unit: 'glasses'),
                    ],
                  ),
                  _buildTemplateCard(
                    title: 'Morning Exercise',
                    description: 'Track workout duration',
                    icon: Icons.fitness_center,
                    iconKey: 'fitness',
                    category: 'Fitness',
                    fields: [
                      _FieldData(label: 'Duration', unit: 'minutes'),
                      _FieldData(type: 'rating', label: 'Intensity'),
                    ],
                  ),
                  _buildTemplateCard(
                    title: 'Reading',
                    description: 'Track daily reading',
                    icon: Icons.book,
                    iconKey: 'book',
                    category: 'Learning',
                    fields: [
                      _FieldData(label: 'Pages', unit: 'pages'),
                      _FieldData(label: 'Minutes', unit: 'min'),
                    ],
                  ),
                  _buildTemplateCard(
                    title: 'Meditation',
                    description: 'Daily mindfulness practice',
                    icon: Icons.self_improvement,
                    iconKey: 'meditation',
                    category: 'Mindfulness',
                    fields: [
                      _FieldData(label: 'Duration', unit: 'minutes'),
                      _FieldData(type: 'rating', label: 'Focus Level'),
                    ],
                  ),
                  _buildTemplateCard(
                    title: 'Sleep Tracking',
                    description: 'Monitor sleep quality',
                    icon: Icons.bedtime,
                    iconKey: 'sleep',
                    category: 'Health',
                    fields: [
                      _FieldData(label: 'Hours', unit: 'hours'),
                      _FieldData(type: 'rating', label: 'Quality'),
                    ],
                  ),
                  _buildTemplateCard(
                    title: 'Study Time',
                    description: 'Track learning sessions',
                    icon: Icons.school,
                    iconKey: 'study',
                    category: 'Learning',
                    fields: [
                      _FieldData(label: 'Minutes', unit: 'min'),
                      _FieldData(type: 'text', label: 'Topic'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build template card widget
  Widget _buildTemplateCard({
    required String title,
    required String description,
    required IconData icon,
    required String iconKey,
    required String category,
    required List<_FieldData> fields,
  }) =>
      Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.blue.shade100,
            child: Icon(icon, color: Colors.blue),
          ),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(description),
          trailing: Chip(
            label: Text(category, style: const TextStyle(fontSize: 11)),
            backgroundColor: Colors.grey.shade200,
          ),
          onTap: () {
            Navigator.pop(context);
            _applyTemplate(title, description, category, iconKey, fields);
          },
        ),
      );

  /// Apply template to form
  void _applyTemplate(
    String name,
    String description,
    String category,
    String iconKey,
    List<_FieldData> fields,
  ) {
    setState(() {
      _nameController.text = name;
      _descriptionController.text = description;
      _selectedCategory = category;
      _selectedIcon = iconKey;

      // Clear existing fields and add template fields
      for (final field in _fields) {
        field.dispose();
      }
      _fields = fields
          .map(
            (f) => _FieldData(
              type: f.type,
              label: f.labelController.text,
              unit: f.unitController.text,
            ),
          )
          .toList();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Template applied! You can customize it.'),
        backgroundColor: Colors.green,
      ),
    );
  }

  /// Validate habit fields for duplicates and empty labels
  String? _validateHabitFields() {
    if (_fields.isEmpty) {
      return 'Please add at least one tracking field';
    }

    if (_fields.length > 10) {
      return 'Maximum 10 fields allowed per habit';
    }

    final seenLabels = <String>{};

    for (var i = 0; i < _fields.length; i++) {
      final field = _fields[i];
      final label = field.labelController.text.trim();

      if (label.isEmpty) {
        return 'Field #${i + 1}: label cannot be empty';
      }

      if (label.length > 50) {
        return 'Field #${i + 1}: label too long (max 50 characters)';
      }

      final lowerLabel = label.toLowerCase();
      if (seenLabels.contains(lowerLabel)) {
        return 'Duplicate field label: "$label"';
      }
      seenLabels.add(lowerLabel);
    }

    return null;
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

    // Validate habit fields
    final fieldsError = _validateHabitFields();
    if (fieldsError != null) {
      print('ERROR: Habit fields validation failed: $fieldsError');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(fieldsError),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
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
        actions: [
          if (!isEditMode)
            TextButton.icon(
              onPressed: _isLoading ? null : _showTemplatesBottomSheet,
              icon: const Icon(Icons.lightbulb_outline),
              label: const Text('Templates'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
              ),
            ),
        ],
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

              // Description field
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  hintText: 'What is this habit about?',
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                maxLength: 200,
                textInputAction: TextInputAction.next,
                enabled: !_isLoading,
              ),
              const SizedBox(height: 24),

              // Category selector
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(Icons.category),
                  border: OutlineInputBorder(),
                ),
                items: _categories
                    .map(
                      (cat) => DropdownMenuItem(
                        value: cat,
                        child: Text(cat),
                      ),
                    )
                    .toList(),
                onChanged: _isLoading
                    ? null
                    : (value) {
                        setState(() {
                          _selectedCategory = value;
                        });
                      },
              ),
              const SizedBox(height: 24),

              // Icon picker section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Choose Icon',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: _habitIcons.entries.map((entry) {
                      final isSelected = _selectedIcon == entry.key;
                      return InkWell(
                        onTap: _isLoading
                            ? null
                            : () {
                                setState(() {
                                  _selectedIcon = entry.key;
                                });
                              },
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Theme.of(context).primaryColor
                                : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12),
                            border: isSelected
                                ? Border.all(
                                    color: Theme.of(context).primaryColor,
                                    width: 2,
                                  )
                                : null,
                          ),
                          child: Icon(
                            entry.value,
                            color: isSelected
                                ? Colors.white
                                : Colors.grey.shade700,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Info card about tracking fields
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue.shade700),
                          const SizedBox(width: 8),
                          Text(
                            'About Tracking Fields',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.blue.shade900,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tracking fields define what you want to measure each day.\n\n'
                        'Examples:\n'
                        '• Number: glasses of water, minutes exercised\n'
                        '• Rating: mood (1-5 stars), energy level\n'
                        '• Text: journal entry, notes',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue.shade900,
                        ),
                      ),
                    ],
                  ),
                ),
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
