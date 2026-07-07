import 'package:flutter/material.dart';
import '../models/fitness_record.dart';
import '../database/database_helper.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  final DatabaseHelper dbHelper = DatabaseHelper();
  List<FitnessRecord> _records = [];
  List<FitnessRecord> _allRecords = [];
  Map<String, double> _summary = {};
  bool _isLoading = true;
  String _activeFilter = 'All Time';

  static const int dailyStepGoal = 10000;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final data = await dbHelper.getRecords();
      setState(() {
        _allRecords = data;
        _records = data;
        _summary = _calculateWeeklySummary(data);
        _activeFilter = 'All Time';
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Map<String, double> _calculateWeeklySummary(List<FitnessRecord> records) {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final weekRecords = records.where((r) => r.date.isAfter(weekAgo)).toList();

    int totalSteps = 0;
    int totalCalories = 0;
    int totalWorkouts = 0;

    for (var r in weekRecords) {
      totalSteps += r.steps;
      totalCalories += r.calories;
      totalWorkouts += r.workoutDuration;
    }

    return {
      'steps': totalSteps.toDouble(),
      'calories': totalCalories.toDouble(),
      'workouts': totalWorkouts.toDouble(),
      'days': weekRecords.length.toDouble(),
      'avgSteps': weekRecords.isEmpty ? 0 : totalSteps / weekRecords.length,
      'avgCalories':
          weekRecords.isEmpty ? 0 : totalCalories / weekRecords.length,
    };
  }

  void refreshData() => _loadData();

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return '🌅 Good Morning';
    if (hour < 17) return '☀️ Good Afternoon';
    if (hour < 21) return '🌇 Good Evening';
    return '🌙 Good Night';
  }

  int _getTodaySteps() {
    final today = DateTime.now();
    final todayRecord = _records.firstWhere(
      (r) =>
          r.date.year == today.year &&
          r.date.month == today.month &&
          r.date.day == today.day,
      orElse: () => FitnessRecord(
        date: today,
        steps: 0,
        calories: 0,
        workoutDuration: 0,
        workoutType: '',
      ),
    );
    return todayRecord.steps;
  }

  bool _isGoalMet(int steps) => steps >= dailyStepGoal;

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  // ============ BUILT-IN SUMMARY CARD ============
  Widget _buildSummaryCard(String label, int value, IconData icon, Color color,
      {String? subtitle}) {
    final colorWithAlpha = color.withValues(alpha: 0.2);
    final bgColor = Colors.grey.shade900.withValues(alpha: 0.8);

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [colorWithAlpha, bgColor],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value.toString(),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(
                subtitle!,
                style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ============ SIMPLE CHART (No fl_chart needed) ============
  Widget _buildStepsChart() {
    final now = DateTime.now();
    final weekDays =
        List.generate(7, (i) => now.subtract(Duration(days: 6 - i)));

    final stepsData = weekDays.map((date) {
      final record = _records.firstWhere(
        (r) =>
            r.date.year == date.year &&
            r.date.month == date.month &&
            r.date.day == date.day,
        orElse: () => FitnessRecord(
          date: date,
          steps: 0,
          calories: 0,
          workoutDuration: 0,
          workoutType: '',
        ),
      );
      return record.steps;
    }).toList();

    final maxSteps =
        stepsData.isEmpty ? 0 : stepsData.reduce((a, b) => a > b ? a : b);
    final yMax = maxSteps > 0 ? maxSteps * 1.3 : 1000.0;

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.show_chart, color: Colors.tealAccent, size: 24),
                SizedBox(width: 8),
                Text(
                  'Weekly Steps Progress',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: CustomPaint(
                painter: _ChartPainter(stepsData, weekDays, yMax),
                size: const Size(double.infinity, 200),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============ RECENT ACTIVITIES ============
  Widget _buildRecentActivities() {
    final recentRecords = _records.reversed.take(5).toList();

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                  ),
                ),
              )
            else
              ...recentRecords.map((r) => _buildActivityTile(r)),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityTile(FitnessRecord record) {
    IconData getIcon(String type) {
      switch (type.toLowerCase()) {
        case 'running':
          return Icons.directions_run;
        case 'cycling':
          return Icons.directions_bike;
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
        default:
          return Icons.fitness_center;
      }
    }

    Color getColor(String type) {
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
        default:
          return Colors.grey;
      }
    }

    String getMonth(int month) {
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

    String getWeekday(int weekday) {
      const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return weekdays[weekday - 1];
    }

    final colorWithAlpha = getColor(record.workoutType).withValues(alpha: 0.2);

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: colorWithAlpha,
        child: Icon(getIcon(record.workoutType),
            color: getColor(record.workoutType), size: 22),
      ),
      title: Text(record.workoutType,
          style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(
        '${record.steps} steps • ${record.calories} cal • ${record.workoutDuration} min',
        style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text('${getMonth(record.date.month)} ${record.date.day}',
              style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(getWeekday(record.date.weekday),
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
        ],
      ),
    );
  }

  // ============ BUILD ============
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_getGreeting(),
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                    color: Colors.grey)),
            const Text('Fitness Dashboard',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          if (_activeFilter != 'All Time')
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: Colors.tealAccent.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.tealAccent),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.filter_alt,
                      size: 16, color: Colors.tealAccent),
                  const SizedBox(width: 4),
                  Text(_activeFilter,
                      style: const TextStyle(
                          fontSize: 12,
                          color: Colors.tealAccent,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: _resetFilter,
                    child: const Icon(Icons.close,
                        size: 14, color: Colors.tealAccent),
                  ),
                ],
              ),
            ),
          IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: _showFilterDialog),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.tealAccent),
                  SizedBox(height: 16),
                  Text('Loading your fitness data...',
                      style: TextStyle(color: Colors.grey, fontSize: 14)),
                ],
              ),
            )
          : _records.isEmpty
              ? _buildEmptyState()
              : _buildDashboardContent(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.fitness_center, size: 80, color: Colors.grey.shade600),
          const SizedBox(height: 16),
          Text(
            _activeFilter != 'All Time'
                ? 'No activities found for $_activeFilter'
                : 'No activities logged yet',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade400),
          ),
          const SizedBox(height: 8),
          Text(
            _activeFilter != 'All Time'
                ? 'Try changing your filter or log a new activity'
                : 'Tap the "Log Activity" tab to get started',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
          if (_activeFilter != 'All Time') ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _resetFilter,
              icon: const Icon(Icons.clear_all),
              label: const Text('Show All Data'),
              style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDashboardContent() {
    final todaySteps = _getTodaySteps();
    final goalMet = _isGoalMet(todaySteps);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          _buildGoalProgressCard(todaySteps, goalMet),
          const SizedBox(height: 16),
          _buildSummaryCards(),
          const SizedBox(height: 16),
          _buildStepsChart(),
          const SizedBox(height: 16),
          _buildRecentActivities(),
          const SizedBox(height: 16),
          _buildAdditionalStats(),
        ],
      ),
    );
  }

  Widget _buildGoalProgressCard(int todaySteps, bool goalMet) {
    final progressPercent = (todaySteps / dailyStepGoal).clamp(0.0, 1.0);

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Today\'s Progress',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: goalMet ? Colors.green : Colors.orange,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    goalMet ? '🎯 Goal Met!' : 'In Progress',
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Steps',
                    style:
                        TextStyle(fontSize: 14, color: Colors.grey.shade400)),
                Text(
                  '${_formatNumber(todaySteps)} / ${_formatNumber(dailyStepGoal)}',
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progressPercent,
                minHeight: 12,
                backgroundColor: Colors.grey.shade800,
                color: goalMet ? Colors.green : Colors.tealAccent,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${(progressPercent * 100).toStringAsFixed(0)}%',
                    style:
                        TextStyle(fontSize: 12, color: Colors.grey.shade400)),
                Text(goalMet ? '✅ Complete' : 'Keep going!',
                    style:
                        TextStyle(fontSize: 12, color: Colors.grey.shade400)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Steps',
                _summary['steps']?.toInt() ?? 0,
                Icons.directions_walk,
                Colors.blue,
                subtitle: 'This week',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                'Calories',
                _summary['calories']?.toInt() ?? 0,
                Icons.local_fire_department,
                Colors.orange,
                subtitle: 'This week',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Workout (min)',
                _summary['workouts']?.toInt() ?? 0,
                Icons.fitness_center,
                Colors.green,
                subtitle: 'This week',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                'Active Days',
                _summary['days']?.toInt() ?? 0,
                Icons.calendar_today,
                Colors.purple,
                subtitle: 'This week',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAdditionalStats() {
    final avgSteps = _summary['avgSteps']?.toInt() ?? 0;
    final avgCalories = _summary['avgCalories']?.toInt() ?? 0;

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('📊 Weekly Averages',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(_formatNumber(avgSteps),
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.tealAccent)),
                      Text('Avg Steps',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade400)),
                    ],
                  ),
                ),
                Container(height: 30, width: 1, color: Colors.grey.shade800),
                Expanded(
                  child: Column(
                    children: [
                      Text(avgCalories.toString(),
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.orangeAccent)),
                      Text('Avg Calories',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade400)),
                    ],
                  ),
                ),
                Container(height: 30, width: 1, color: Colors.grey.shade800),
                Expanded(
                  child: Column(
                    children: [
                      Text('${_records.length}',
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.greenAccent)),
                      Text('Total Activities',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade400)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ============ FILTER METHODS ============
  void _resetFilter() {
    setState(() {
      _records = _allRecords;
      _summary = _calculateWeeklySummary(_allRecords);
      _activeFilter = 'All Time';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🔓 Filter cleared - Showing all data'),
        backgroundColor: Colors.teal,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _showFilterDialog() async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Filter Data'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.today),
                title: const Text('Today'),
                subtitle: const Text('Show only today\'s activities'),
                onTap: () {
                  Navigator.pop(context);
                  _filterByDate(DateTime.now());
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.weekend),
                title: const Text('This Week'),
                subtitle: const Text('Show last 7 days'),
                onTap: () {
                  Navigator.pop(context);
                  _filterByDateRange(
                    DateTime.now().subtract(const Duration(days: 7)),
                    DateTime.now(),
                  );
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.calendar_month),
                title: const Text('This Month'),
                subtitle: const Text('Show current month'),
                onTap: () {
                  Navigator.pop(context);
                  final firstDay =
                      DateTime(DateTime.now().year, DateTime.now().month, 1);
                  _filterByDateRange(firstDay, DateTime.now());
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.clear_all, color: Colors.red),
                title:
                    const Text('Show All', style: TextStyle(color: Colors.red)),
                subtitle: const Text('Reset filter to show all data'),
                onTap: () {
                  Navigator.pop(context);
                  _resetFilter();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _filterByDate(DateTime date) async {
    setState(() => _isLoading = true);
    final filtered = _allRecords
        .where((r) =>
            r.date.year == date.year &&
            r.date.month == date.month &&
            r.date.day == date.day)
        .toList();
    setState(() {
      _records = filtered;
      _summary = _calculateWeeklySummary(filtered);
      _activeFilter = 'Today';
      _isLoading = false;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('📅 Filtered: Today (${filtered.length} activities)'),
          backgroundColor: Colors.teal,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _filterByDateRange(DateTime start, DateTime end) async {
    setState(() => _isLoading = true);
    final filtered = _allRecords
        .where((r) =>
            r.date.isAfter(start) &&
            r.date.isBefore(end.add(const Duration(days: 1))))
        .toList();
    setState(() {
      _records = filtered;
      _summary = _calculateWeeklySummary(filtered);
      _activeFilter =
          start == DateTime(DateTime.now().year, DateTime.now().month, 1)
              ? 'This Month'
              : 'This Week';
      _isLoading = false;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '📆 Filtered: $_activeFilter (${filtered.length} activities)'),
          backgroundColor: Colors.teal,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}

// ============ CHART PAINTER ============
class _ChartPainter extends CustomPainter {
  final List<int> stepsData;
  final List<DateTime> weekDays;
  final double yMax;

  const _ChartPainter(this.stepsData, this.weekDays, this.yMax);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.tealAccent
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Colors.tealAccent, Colors.transparent],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final dotStrokePaint = Paint()
      ..color = Colors.tealAccent
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    final fillPath = Path();

    final width = size.width;
    final height = size.height;
    const padding = 20.0;
    final chartWidth = width - 2 * padding;
    final chartHeight = height - 2 * padding;

    for (int i = 0; i < stepsData.length; i++) {
      final x = padding + (i / (stepsData.length - 1)) * chartWidth;
      final y = padding + chartHeight - (stepsData[i] / yMax) * chartHeight;

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, height - padding);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo(width - padding, height - padding);
    fillPath.close();
    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);

    for (int i = 0; i < stepsData.length; i++) {
      final x = padding + (i / (stepsData.length - 1)) * chartWidth;
      final y = padding + chartHeight - (stepsData[i] / yMax) * chartHeight;
      canvas.drawCircle(Offset(x, y), 6, dotPaint);
      canvas.drawCircle(Offset(x, y), 6, dotStrokePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ChartPainter oldDelegate) {
    return oldDelegate.stepsData != stepsData;
  }
}
