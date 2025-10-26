import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/habits/domain/entities/habit.dart';
import 'package:frontend/features/habits/presentation/bloc/habits_bloc.dart';
import 'package:frontend/features/habits/presentation/bloc/habits_event.dart';
import 'package:frontend/features/habits/presentation/bloc/habits_state.dart';
import 'package:frontend/features/habits/presentation/widgets/habit_bar_chart.dart';
import 'package:frontend/features/habits/presentation/widgets/habit_line_chart.dart';
import 'package:frontend/features/habits/presentation/widgets/habit_summary_cards.dart';
import 'package:intl/intl.dart';

/// Habit tracking page with statistics tabs
class HabitTrackingWithStatsPage extends StatefulWidget {
  const HabitTrackingWithStatsPage({
    required this.habit,
    super.key,
  });

  final Habit habit;

  @override
  State<HabitTrackingWithStatsPage> createState() =>
      _HabitTrackingWithStatsPageState();
}

class _HabitTrackingWithStatsPageState extends State<HabitTrackingWithStatsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedPeriod = 7; // days: 7, 14, 30, 90

  // Track tab form state
  final Map<String, TextEditingController> _textControllers = {};
  final Map<String, int> _ratingValues = {}; // 1-5 stars
  final Map<String, bool> _booleanValues = {};
  final Map<String, TimeOfDay?> _timeValues = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Initialize controllers for each field
    for (final field in widget.habit.fields) {
      if (field.type == 'number' || field.type == 'text') {
        _textControllers[field.label] = TextEditingController();
      } else if (field.type == 'rating') {
        _ratingValues[field.label] = 0; // 0 = not set
      } else if (field.type == 'boolean') {
        _booleanValues[field.label] = false;
      } else if (field.type == 'time') {
        _timeValues[field.label] = null;
      }
    }

    // Debug logging
    debugPrint('HabitTrackingWithStatsPage: Initialized for habit ${widget.habit.id}');

    // Load statistics when Statistics tab is selected
    _tabController.addListener(() {
      if (_tabController.index == 1 && !_tabController.indexIsChanging) {
        debugPrint('Statistics tab selected, loading data for $_selectedPeriod days');
        // Statistics tab selected
        context.read<HabitsBloc>().add(
          LoadHabitStatisticsEvent(
            userId: widget.habit.userId,
            habitId: widget.habit.id,
            days: _selectedPeriod,
          ),
        );
      } else if (_tabController.index == 2 && !_tabController.indexIsChanging) {
        debugPrint('History tab selected, loading entries');
        // History tab selected
        final now = DateTime.now();
        final thirtyDaysAgo = now.subtract(const Duration(days: 30));
        context.read<HabitsBloc>().add(
          LoadEntriesEvent(widget.habit.id, thirtyDaysAgo, now),
        );
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    // Dispose all text controllers
    for (final controller in _textControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(widget.habit.name),
      bottom: TabBar(
        controller: _tabController,
        labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
        labelColor: Theme.of(context).colorScheme.onPrimary,
        unselectedLabelColor: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.7),
        indicatorColor: Theme.of(context).colorScheme.onPrimary,
        tabs: const [
          Tab(icon: Icon(Icons.add_circle), text: 'Track'),
          Tab(icon: Icon(Icons.bar_chart), text: 'Statistics'),
          Tab(icon: Icon(Icons.history), text: 'History'),
        ],
      ),
    ),
    body: TabBarView(
      controller: _tabController,
      children: [
        // Track tab - form to log new entries
        _buildTrackTab(),
        // Statistics tab
        _buildStatisticsTab(),
        // History tab - reuse the history section from tracking page
        _buildHistoryTab(),
      ],
    ),
  );

  /// Build Track tab with form to log new entries
  Widget _buildTrackTab() => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Date card
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Today',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                        Text(
                          DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now()),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Habit info
            Text(
              widget.habit.name,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),

            const SizedBox(height: 24),

            // Form fields
            ...widget.habit.fields.map((field) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildFieldInput(field),
              )),

            const SizedBox(height: 24),

            // Submit button
            ElevatedButton.icon(
              onPressed: _submitEntry,
              icon: const Icon(Icons.check_circle, size: 28),
              label: const Text(
                'Log Entry',
                style: TextStyle(fontSize: 18),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      );

  /// Build input field based on field type
  Widget _buildFieldInput(HabitField field) {
    final label = field.label;
    final type = field.type;

    switch (type) {
      case 'number':
        return TextFormField(
          controller: _textControllers[label],
          decoration: InputDecoration(
            labelText: label,
            suffixText: field.unit ?? '',
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.numbers),
          ),
          keyboardType: TextInputType.number,
        );

      case 'rating':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: List.generate(5, (index) {
                final starValue = index + 1;
                final isSelected = (_ratingValues[label] ?? 0) >= starValue;
                return IconButton(
                  icon: Icon(
                    isSelected ? Icons.star : Icons.star_border,
                    color: isSelected ? Colors.amber : Colors.grey,
                    size: 36,
                  ),
                  onPressed: () {
                    setState(() {
                      _ratingValues[label] = starValue;
                    });
                  },
                );
              }),
            ),
          ],
        );

      case 'boolean':
        return SwitchListTile(
          title: Text(label),
          value: _booleanValues[label] ?? false,
          onChanged: (value) {
            setState(() {
              _booleanValues[label] = value;
            });
          },
          contentPadding: EdgeInsets.zero,
        );

      case 'text':
        return TextFormField(
          controller: _textControllers[label],
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.text_fields),
          ),
          maxLines: 3,
          maxLength: 200,
        );

      case 'time':
        final timeValue = _timeValues[label];
        return InkWell(
          onTap: () async {
            final picked = await showTimePicker(
              context: context,
              initialTime: timeValue ?? TimeOfDay.now(),
            );
            if (picked != null) {
              setState(() {
                _timeValues[label] = picked;
              });
            }
          },
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: label,
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.access_time),
            ),
            child: Text(
              timeValue != null
                  ? timeValue.format(context)
                  : 'Select time',
              style: TextStyle(
                color: timeValue != null ? null : Colors.grey,
              ),
            ),
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }

  /// Submit entry to backend
  Future<void> _submitEntry() async {
    // Collect all values
    final values = <String, dynamic>{};

    for (final field in widget.habit.fields) {
      final label = field.label;
      final type = field.type;

      switch (type) {
        case 'number':
          final text = _textControllers[label]?.text ?? '';
          if (text.isNotEmpty) {
            values[label] = double.tryParse(text) ?? 0;
          }
        case 'rating':
          final rating = _ratingValues[label] ?? 0;
          if (rating > 0) {
            values[label] = rating;
          }
        case 'boolean':
          values[label] = _booleanValues[label] ?? false;
        case 'text':
          final text = _textControllers[label]?.text ?? '';
          if (text.isNotEmpty) {
            values[label] = text;
          }
        case 'time':
          final time = _timeValues[label];
          if (time != null) {
            values[label] = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
          }
      }
    }

    // Validation: at least one field must be filled
    if (values.isEmpty) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in at least one field'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Add entry via BLoC
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final entry = HabitEntry(date: today, values: values);
    context.read<HabitsBloc>().add(
          AddEntryEvent(widget.habit.id, entry),
        );

    // Clear form
    for (final controller in _textControllers.values) {
      controller.clear();
    }
    setState(() {
      for (final key in _ratingValues.keys) {
        _ratingValues[key] = 0;
      }
      for (final key in _booleanValues.keys) {
        _booleanValues[key] = false;
      }
      for (final key in _timeValues.keys) {
        _timeValues[key] = null;
      }
    });

    if (!mounted) {
      return;
    }

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Entry logged successfully!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );

    // Switch to History tab
    // Note: The tab listener will automatically load data when switching
    _tabController.animateTo(2);
  }

  /// Build Statistics tab with charts and summary
  Widget _buildStatisticsTab() => BlocBuilder<HabitsBloc, HabitsState>(
    builder: (context, state) {
      debugPrint('Statistics tab build - state: ${state.runtimeType}');

      if (state is HabitsLoading) {
        return const Center(child: CircularProgressIndicator());
      }

      if (state is HabitStatisticsLoaded) {
        final statistics = state.statistics;
        final habit = state.habit;
        final entries = state.entries;

        debugPrint('Statistics loaded: ${entries.length} entries, current streak: ${statistics.currentStreak}');

        // Check if there are any entries
        if (entries.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bar_chart, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 24),
                  Text(
                    'No data yet',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Start tracking to see your statistics',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () {
                      _tabController.animateTo(0); // Go to Track tab
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add First Entry'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              // Period selector
              _buildPeriodSelector(),

              // Summary cards
              HabitSummaryCards(statistics: statistics),

              const SizedBox(height: 16),

              // Charts for number fields
              ...habit.fields
                  .where((f) => f.type == 'number')
                  .map(
                    (field) => Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: HabitLineChart(
                        entries: entries,
                        fieldLabel: field.label,
                        unit: field.unit,
                      ),
                    ),
                  ),

              // Charts for rating fields
              ...habit.fields
                  .where((f) => f.type == 'rating')
                  .map(
                    (field) => Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: HabitBarChart(
                        entries: entries,
                        fieldLabel: field.label,
                      ),
                    ),
                  ),

              const SizedBox(height: 24),
            ],
          ),
        );
      }

      if (state is HabitsError) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text(
                'Error loading statistics',
                style: TextStyle(fontSize: 18, color: Colors.grey[700]),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  state.message,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  context.read<HabitsBloc>().add(
                    LoadHabitStatisticsEvent(
                      userId: widget.habit.userId,
                      habitId: widget.habit.id,
                      days: _selectedPeriod,
                    ),
                  );
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        );
      }

      // Initial state or no data loaded yet
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Loading statistics...',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    },
  );

  /// Build period selector chips
  Widget _buildPeriodSelector() => Container(
    padding: const EdgeInsets.all(16),
    child: Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildPeriodChip('7D', 7),
        _buildPeriodChip('14D', 14),
        _buildPeriodChip('30D', 30),
        _buildPeriodChip('3M', 90),
      ],
    ),
  );

  /// Build individual period chip
  Widget _buildPeriodChip(String label, int days) {
    final isSelected = _selectedPeriod == days;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedPeriod = days;
          });
          // Reload statistics with new period
          context.read<HabitsBloc>().add(
            LoadHabitStatisticsEvent(
              userId: widget.habit.userId,
              habitId: widget.habit.id,
              days: days,
            ),
          );
        }
      },
    );
  }

  /// Build History tab
  Widget _buildHistoryTab() => BlocBuilder<HabitsBloc, HabitsState>(
    builder: (context, state) {
      debugPrint('History tab build - state: ${state.runtimeType}');

      if (state is HabitsLoading) {
        return const Center(child: CircularProgressIndicator());
      }

      if (state is EntriesLoaded) {
        final entries = state.entries;
        debugPrint('History loaded: ${entries.length} entries');

        if (entries.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 24),
                  Text(
                    'No entries yet',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Track your first entry in the Track tab!',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () {
                      _tabController.animateTo(0); // Go to Track tab
                    },
                    icon: const Icon(Icons.add_circle),
                    label: const Text('Start Tracking'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: entries.length,
          itemBuilder: (context, index) {
            final entry = entries[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 2,
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  child: Icon(
                    Icons.check_circle,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                title: Text(
                  entry.date,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: entry.values.entries
                        .map(
                          (e) => Chip(
                            label: Text(
                              '${e.key}: ${e.value}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            visualDensity: VisualDensity.compact,
                            backgroundColor: Colors.blue.shade50,
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            );
          },
        );
      }

      if (state is HabitsError) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 80, color: Colors.red[300]),
                const SizedBox(height: 24),
                Text(
                  'Error loading history',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                Text(
                  state.message,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    final now = DateTime.now();
                    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
                    context.read<HabitsBloc>().add(
                      LoadEntriesEvent(widget.habit.id, thirtyDaysAgo, now),
                    );
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        );
      }

      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Loading history...',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    },
  );
}
