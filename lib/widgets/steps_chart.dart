import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/fitness_record.dart';

class StepsChart extends StatelessWidget {
  final List<FitnessRecord> records;

  const StepsChart({super.key, required this.records});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final weekDays =
        List.generate(7, (i) => now.subtract(Duration(days: 6 - i)));

    final stepsData = weekDays.map((date) {
      final record = records.firstWhere(
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
      return record.steps.toDouble();
    }).toList();

    // Fixed: Handle empty data case
    final maxSteps =
        stepsData.isEmpty ? 0 : stepsData.reduce((a, b) => a > b ? a : b);
    final yMax = maxSteps > 0 ? maxSteps * 1.3 : 1000.0;

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
                Icon(Icons.show_chart, color: Colors.tealAccent, size: 24),
                SizedBox(width: 8),
                Text(
                  'Weekly Steps Progress',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    horizontalInterval: yMax / 4,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.shade800,
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < weekDays.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                DateFormat('E').format(weekDays[index]),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade400,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          if (value == 0) return const Text('');
                          return Text(
                            '${(value / 1000).toStringAsFixed(0)}k',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade400,
                            ),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: 6,
                  minY: 0,
                  maxY: yMax,
                  lineBarsData: [
                    LineChartBarData(
                      spots: stepsData
                          .asMap()
                          .entries
                          .map((e) => FlSpot(e.key.toDouble(), e.value))
                          .toList(),
                      isCurved: true,
                      gradient: const LinearGradient(
                        colors: [Colors.tealAccent, Colors.lightGreenAccent],
                      ),
                      barWidth: 4,
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            Colors.tealAccent.withValues(alpha: 0.3),
                            Colors.lightGreenAccent.withValues(alpha: 0.1),
                          ],
                        ),
                      ),
                      dotData: const FlDotData(
                        show: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
