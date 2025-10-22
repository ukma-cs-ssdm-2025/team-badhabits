// ignore_for_file: deprecated_member_use, inference_failure_on_instance_creation, inference_failure_on_function_invocation
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/habits/domain/entities/habit.dart';
import 'package:frontend/features/habits/presentation/bloc/habits_bloc.dart';
import 'package:frontend/features/habits/presentation/bloc/habits_event.dart';
import 'package:frontend/features/habits/presentation/bloc/habits_state.dart';
import 'package:intl/intl.dart';

/// Page for tracking habit entries
class HabitTrackingPage extends StatefulWidget {
  const HabitTrackingPage({required this.habit, super.key});

  /// Habit to track
  final Habit habit;

  @override
  State<HabitTrackingPage> createState() => _HabitTrackingPageState();
}

class _HabitTrackingPageState extends State<HabitTrackingPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isSaving = false;

  // Controllers for each field
  final Map<String, TextEditingController> _textControllers = {};
  final Map<String, int> _ratingValues = {};

  // History entries
  List<HabitEntry> _historyEntries = [];

  // Current date
  late String _currentDate;

  @override
  void initState() {
    super.initState();
    _currentDate = _formatDate(DateTime.now());

    // Initialize controllers and default values for each field
    for (final field in widget.habit.fields) {
      if (field.type == 'number' || field.type == 'text') {
        _textControllers[field.label] = TextEditingController();
      } else if (field.type == 'rating') {
        _ratingValues[field.label] = 0; // 0 means not rated yet
      }
    }

    // Load existing entry for today and history
    _loadData();
  }

  @override
  void dispose() {
    for (final controller in _textControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  /// Format DateTime to YYYY-MM-DD
  String _formatDate(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

  /// Format date for display
  String _formatDisplayDate(DateTime date) =>
      DateFormat('EEEE, MMMM d, yyyy').format(date);

  /// Load today's entry and history
  void _loadData() {
    setState(() {
      _isLoading = true;
    });

    // Load entry for today
    context.read<HabitsBloc>().add(
      LoadEntryForDateEvent(widget.habit.id, _currentDate),
    );

    // Load last 7 days entries
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));
    context.read<HabitsBloc>().add(
      LoadEntriesEvent(widget.habit.id, sevenDaysAgo, now),
    );
  }

  /// Save entry for today
  Future<void> _saveEntry() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Collect values from all fields
    final values = <String, dynamic>{};

    for (final field in widget.habit.fields) {
      if (field.type == 'number') {
        final text = _textControllers[field.label]!.text.trim();
        if (text.isNotEmpty) {
          values[field.label] = double.tryParse(text) ?? 0;
        }
      } else if (field.type == 'rating') {
        final rating = _ratingValues[field.label] ?? 0;
        if (rating > 0) {
          values[field.label] = rating;
        }
      } else if (field.type == 'text') {
        final text = _textControllers[field.label]!.text.trim();
        if (text.isNotEmpty) {
          values[field.label] = text;
        }
      }
    }

    // Check if at least one field has a value
    if (values.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in at least one field'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Set saving state
    setState(() {
      _isSaving = true;
    });

    // Create entry
    final entry = HabitEntry(date: _currentDate, values: values);

    // Add entry event
    context.read<HabitsBloc>().add(AddEntryEvent(widget.habit.id, entry));
  }

  @override
  Widget build(BuildContext context) => BlocListener<HabitsBloc, HabitsState>(
    listener: (context, state) {
      if (state is EntryForDateLoaded) {
        // Load existing entry data into form
        setState(() {
          _isLoading = false;
          if (state.entry != null) {
            _loadEntryIntoForm(state.entry!);
          }
        });
      } else if (state is EntriesLoaded) {
        // Load history entries
        setState(() {
          _historyEntries = state.entries;
        });
      } else if (state is HabitsLoaded) {
        // Entry saved successfully
        setState(() {
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Entry saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
        // Reload data
        _loadData();
      } else if (state is HabitsError) {
        // Error occurred
        setState(() {
          _isLoading = false;
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.message), backgroundColor: Colors.red),
        );
      }
    },
    child: Scaffold(
      appBar: AppBar(title: Text(widget.habit.name)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Date display
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _formatDisplayDate(DateTime.now()),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Tracking fields section
                    const Text(
                      'Track Today',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Build input widgets for each field
                    ...widget.habit.fields.map(_buildFieldInput),

                    const SizedBox(height: 24),

                    // Save button
                    ElevatedButton(
                      onPressed: _isSaving ? null : _saveEntry,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Save Entry',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),

                    const SizedBox(height: 32),

                    // History section
                    if (_historyEntries.isNotEmpty) ...[
                      const Text(
                        'Recent History',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ..._historyEntries.map(_buildHistoryCard),
                    ],
                  ],
                ),
              ),
            ),
    ),
  );

  /// Load entry data into form
  void _loadEntryIntoForm(HabitEntry entry) {
    for (final field in widget.habit.fields) {
      final value = entry.values[field.label];
      if (value != null) {
        if (field.type == 'number') {
          _textControllers[field.label]!.text = value.toString();
        } else if (field.type == 'rating') {
          _ratingValues[field.label] = value as int;
        } else if (field.type == 'text') {
          _textControllers[field.label]!.text = value.toString();
        }
      }
    }
  }

  /// Build input widget for a field
  Widget _buildFieldInput(HabitField field) => Card(
    margin: const EdgeInsets.only(bottom: 16),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Field label with icon
          Row(
            children: [
              Icon(
                _getFieldIcon(field.type),
                size: 20,
                color: _getFieldColor(field.type),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  field.label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (field.unit != null)
                Chip(
                  label: Text(field.unit!),
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Input widget based on type
          if (field.type == 'number')
            _buildNumberInput(field)
          else if (field.type == 'rating')
            _buildRatingInput(field)
          else if (field.type == 'text')
            _buildTextInput(field),
        ],
      ),
    ),
  );

  /// Build number input
  Widget _buildNumberInput(HabitField field) => TextFormField(
    controller: _textControllers[field.label],
    decoration: InputDecoration(
      hintText: 'Enter value',
      suffixText: field.unit,
      border: const OutlineInputBorder(),
      isDense: true,
    ),
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    enabled: !_isSaving,
  );

  /// Build rating input (1-5 stars)
  Widget _buildRatingInput(HabitField field) {
    final currentRating = _ratingValues[field.label] ?? 0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final starValue = index + 1;
        final isSelected = starValue <= currentRating;

        return IconButton(
          icon: Icon(isSelected ? Icons.star : Icons.star_border, size: 40),
          color: isSelected ? Colors.amber : Colors.grey,
          onPressed: _isSaving
              ? null
              : () {
                  setState(() {
                    _ratingValues[field.label] = starValue;
                  });
                },
        );
      }),
    );
  }

  /// Build text input
  Widget _buildTextInput(HabitField field) => TextFormField(
    controller: _textControllers[field.label],
    decoration: const InputDecoration(
      hintText: 'Enter notes',
      border: OutlineInputBorder(),
      isDense: true,
    ),
    maxLines: 3,
    enabled: !_isSaving,
  );

  /// Build history card
  Widget _buildHistoryCard(HabitEntry entry) {
    final entryDate = DateTime.parse(entry.date);
    final isToday = entry.date == _currentDate;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isToday ? Colors.blue.withOpacity(0.05) : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date header
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: isToday ? Colors.blue : Colors.grey[600],
                ),
                const SizedBox(width: 8),
                Text(
                  _formatDisplayDate(entryDate),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isToday ? Colors.blue : null,
                  ),
                ),
                if (isToday)
                  const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Chip(
                      label: Text('Today', style: TextStyle(fontSize: 10)),
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Values
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: entry.values.entries.map((valueEntry) {
                final fieldLabel = valueEntry.key;
                final value = valueEntry.value;

                // Find field to get type and unit (safely handle missing fields)
                HabitField field;
                try {
                  field = widget.habit.fields.firstWhere(
                    (f) => f.label == fieldLabel,
                  );
                } catch (e) {
                  // If field not found, create a default one
                  field = HabitField(type: 'text', label: fieldLabel);
                }

                return _buildValueChip(field, value);
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  /// Build value chip for history
  Widget _buildValueChip(HabitField field, dynamic value) {
    String displayValue;

    if (field.type == 'rating') {
      displayValue = '⭐ $value/5';
    } else if (field.type == 'number' && field.unit != null) {
      displayValue = '$value ${field.unit}';
    } else {
      displayValue = value.toString();
    }

    return Chip(
      avatar: Icon(
        _getFieldIcon(field.type),
        size: 16,
        color: _getFieldColor(field.type),
      ),
      label: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            field.label,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
          ),
          Text(displayValue, style: const TextStyle(fontSize: 12)),
        ],
      ),
      visualDensity: VisualDensity.compact,
    );
  }

  /// Get icon for field type
  IconData _getFieldIcon(String type) {
    switch (type) {
      case 'number':
        return Icons.numbers;
      case 'rating':
        return Icons.star;
      case 'text':
        return Icons.text_fields;
      default:
        return Icons.help;
    }
  }

  /// Get color for field type
  Color _getFieldColor(String type) {
    switch (type) {
      case 'number':
        return Colors.blue;
      case 'rating':
        return Colors.amber;
      case 'text':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
