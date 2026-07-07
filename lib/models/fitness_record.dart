class FitnessRecord {
  int? id;
  DateTime date;
  int steps;
  int calories;
  int workoutDuration;
  String workoutType;

  FitnessRecord({
    this.id,
    required this.date,
    required this.steps,
    required this.calories,
    required this.workoutDuration,
    required this.workoutType,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'steps': steps,
      'calories': calories,
      'workoutDuration': workoutDuration,
      'workoutType': workoutType,
    };
  }

  factory FitnessRecord.fromMap(Map<String, dynamic> map) {
    return FitnessRecord(
      id: map['id'],
      date: DateTime.parse(map['date']),
      steps: map['steps'],
      calories: map['calories'],
      workoutDuration: map['workoutDuration'],
      workoutType: map['workoutType'],
    );
  }

  // Copy with method for updates
  FitnessRecord copyWith({
    int? id,
    DateTime? date,
    int? steps,
    int? calories,
    int? workoutDuration,
    String? workoutType,
  }) {
    return FitnessRecord(
      id: id ?? this.id,
      date: date ?? this.date,
      steps: steps ?? this.steps,
      calories: calories ?? this.calories,
      workoutDuration: workoutDuration ?? this.workoutDuration,
      workoutType: workoutType ?? this.workoutType,
    );
  }

  @override
  String toString() {
    return 'FitnessRecord{id: $id, date: $date, steps: $steps, calories: $calories, workoutDuration: $workoutDuration, workoutType: $workoutType}';
  }
}
