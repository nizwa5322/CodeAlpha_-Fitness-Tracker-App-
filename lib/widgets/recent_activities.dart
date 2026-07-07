import 'package:flutter/material.dart';
import '../models/fitness_record.dart';

class RecentActivities extends StatelessWidget {
  final List<FitnessRecord> records;

  const RecentActivities({super.key, required this.records});

  IconData _getWorkoutIcon(String type) {
    switch (type.toLowerCase()) {
      case 'running':
        return Icons.directions_run;
      case 'cycling':
        return Icons.directions_bike; // Fixed: Changed from Icons.cycling
      case 'weightlifting':
        return Icons.fitness_center;
      case 'yoga':
        return Icons.self_improvement;
      case 'walking':
        return Icons.directions_walk;
      case 'swimming':
        return Icons.pool;
      case 'hiit':
        return Icons.flash_on;
      case 'pilates':
        return Icons.accessibility_new;
      case 'dancing':
        return Icons.music_note;
      case 'boxing':
        return Icons.sports_martial_arts;
      default:
        return Icons.fitness_center;
    }
  }

  Color _getWorkoutColor(String type) {
    switch (type.toLowerCase()) {
      case 'running':
        return Colors.blue;
      case 'cycling':
        return Colors.green;
      case 'weightlifting':
        return Colors.orange;
      case 'yoga':
        return Colors.purple;
      case 'walking':
        return Colors.teal;
      case 'swimming':
        return Colors.cyan;
      case 'hiit':
        return Colors.red;
      case 'pilates':
        return Colors.pink;
      case 'dancing':
        return Colors.amber;
      case 'boxing':
        return Colors.deepOrange;
      default:
        return Colors.grey;
    }
  }

  String _getMonth(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }

  String _getWeekday(int weekday) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return weekdays[weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    final recentRecords = records.reversed.take(5).toList();

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.history, color: Colors.tealAccent, size: 24),
                SizedBox(width: 8),
                Text(
                  'Recent Activities',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (recentRecords.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text(
                    'No recent activities',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 14,
                    ),
                  ),
                ),
              )
            else
              ...recentRecords.map((record) => _buildActivityTile(record)),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityTile(FitnessRecord record) {
    final iconColor = _getWorkoutColor(record.workoutType);
    final colorWithAlpha = iconColor.withValues(alpha: 0.2);

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: colorWithAlpha,
        child: Icon(
          _getWorkoutIcon(record.workoutType),
          color: iconColor,
          size: 22,
        ),
      ),
      title: Text(
        record.workoutType,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        '${record.steps} steps • ${record.calories} cal • ${record.workoutDuration} min',
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey.shade400,
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '${_getMonth(record.date.month)} ${record.date.day}',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            _getWeekday(record.date.weekday),
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}
