import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/fitness_record.dart';
import '../database/database_helper.dart';

class LogScreen extends StatefulWidget {
  final VoidCallback onRecordAdded;
  const LogScreen({super.key, required this.onRecordAdded});

  @override
  State<LogScreen> createState() => _LogScreenState();
}

class _LogScreenState extends State<LogScreen> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseHelper dbHelper = DatabaseHelper();

  final _stepsController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _durationController = TextEditingController();

  String _selectedWorkoutType = 'Running';
  DateTime _selectedDate = DateTime.now();
  bool _isSubmitting = false;

  final List<String> _workoutTypes = [
    'Running',
    'Cycling',
    'Weightlifting',
    'Yoga',
    'Walking',
    'Swimming',
    'HIIT',
    'Pilates',
  ];

  Future<void> _saveRecord() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);

      final record = FitnessRecord(
        date: _selectedDate,
        steps: int.parse(_stepsController.text),
        calories: int.parse(_caloriesController.text),
        workoutDuration: int.parse(_durationController.text),
        workoutType: _selectedWorkoutType,
      );

      await dbHelper.insertRecord(record);
      widget.onRecordAdded();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Activity logged successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        _clearForm();
      }

      setState(() => _isSubmitting = false);
    }
  }

  void _clearForm() {
    _stepsController.clear();
    _caloriesController.clear();
    _durationController.clear();
    setState(() {
      _selectedWorkoutType = 'Running';
      _selectedDate = DateTime.now();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Log Activity',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '📊 Enter Your Fitness Details',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Log your daily activities to track progress',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade400,
                ),
              ),
              const SizedBox(height: 32),
              DropdownButtonFormField<String>(
                initialValue: _selectedWorkoutType,
                dropdownColor: Colors.grey.shade900,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                decoration: InputDecoration(
                  labelText: 'Workout Type',
                  labelStyle: TextStyle(color: Colors.grey.shade400),
                  prefixIcon: const Icon(Icons.fitness_center,
                      color: Colors.tealAccent),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey.shade700),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide:
                        const BorderSide(color: Colors.tealAccent, width: 2),
                  ),
                ),
                items: _workoutTypes
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedWorkoutType = value);
                  }
                },
                validator: (value) =>
                    value == null ? 'Select a workout type' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _stepsController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Steps',
                  labelStyle: TextStyle(color: Colors.grey.shade400),
                  prefixIcon: const Icon(Icons.directions_walk,
                      color: Colors.tealAccent),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey.shade700),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide:
                        const BorderSide(color: Colors.tealAccent, width: 2),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return 'Enter steps';
                  }
                  if (int.tryParse(v) == null) {
                    return 'Enter a valid number';
                  }
                  if (int.parse(v) < 0) {
                    return 'Steps cannot be negative';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _caloriesController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Calories Burned',
                  labelStyle: TextStyle(color: Colors.grey.shade400),
                  prefixIcon: const Icon(Icons.local_fire_department,
                      color: Colors.tealAccent),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey.shade700),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide:
                        const BorderSide(color: Colors.tealAccent, width: 2),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return 'Enter calories';
                  }
                  if (int.tryParse(v) == null) {
                    return 'Enter a valid number';
                  }
                  if (int.parse(v) < 0) {
                    return 'Calories cannot be negative';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _durationController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Workout Duration (minutes)',
                  labelStyle: TextStyle(color: Colors.grey.shade400),
                  prefixIcon: const Icon(Icons.timer, color: Colors.tealAccent),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey.shade700),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide:
                        const BorderSide(color: Colors.tealAccent, width: 2),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return 'Enter duration';
                  }
                  if (int.tryParse(v) == null) {
                    return 'Enter a valid number';
                  }
                  if (int.parse(v) < 1) {
                    return 'Duration must be at least 1 minute';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ListTile(
                leading:
                    const Icon(Icons.calendar_today, color: Colors.tealAccent),
                title: Text(
                  'Date: ${DateFormat('MMM d, yyyy').format(_selectedDate)}',
                  style: const TextStyle(fontSize: 16),
                ),
                trailing: IconButton(
                  icon:
                      const Icon(Icons.edit_calendar, color: Colors.tealAccent),
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.dark(
                              primary: Colors.tealAccent,
                              onPrimary: Colors.black,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (date != null) {
                      setState(() => _selectedDate = date);
                    }
                  },
                ),
                tileColor: Colors.grey.shade900,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.shade700),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _saveRecord,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.tealAccent,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 8,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.black,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.save),
                            SizedBox(width: 8),
                            Text(
                              'Log Activity',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _stepsController.dispose();
    _caloriesController.dispose();
    _durationController.dispose();
    super.dispose();
  }
}
