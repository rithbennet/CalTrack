import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:caltrack/models/nutritional_summary.dart';

class WeeklyReportScreen extends StatelessWidget {
  final List<DailyNutritionalSummary> weeklySummary;
  final double targetCalories; // Added this parameter for the daily target

  const WeeklyReportScreen({
    super.key,
    required this.weeklySummary,
    this.targetCalories = 2000, // Default value of 2000 calories
  });

  @override
  Widget build(BuildContext context) {
    // Calculate weekly averages
    final summariesWithEntries = weeklySummary.where(
      (s) => s.foodEntries.isNotEmpty,
    );
    final double avgCalories =
        summariesWithEntries.isEmpty
            ? 0
            : summariesWithEntries
                    .map((s) => s.totalCalories)
                    .reduce((a, b) => a + b) /
                summariesWithEntries.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weekly Report'),
        backgroundColor: Colors.black87,
        elevation: 0,
      ),
      backgroundColor: Colors.black87,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Calorie Intake (Last 7 Days)',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Average: ${avgCalories.toStringAsFixed(0)} kcal / day',
              style: TextStyle(color: Colors.grey[400], fontSize: 16),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: BarChart(
                _buildBarChartData(),
                duration: const Duration(milliseconds: 450),
                curve: Curves.easeOut,
              ),
            ),
            const SizedBox(height: 16),
            // Add this legend
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.deepOrange,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text('Actual', style: TextStyle(color: Colors.grey[400])),
                  ],
                ),
                const SizedBox(width: 24),
                Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.green.shade400,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text('Target', style: TextStyle(color: Colors.grey[400])),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Text(
              'Daily Breakdown',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(color: Colors.grey),
            // Using ListView.builder for performance, even with a small list
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: weeklySummary.length,
              itemBuilder: (context, index) {
                final summary = weeklySummary[index];
                return Card(
                  color: Colors.grey[900],
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ExpansionTile(
                    iconColor: Colors.deepOrange,
                    collapsedIconColor: Colors.white,
                    title: Text(
                      '${DateFormat.EEEE().format(summary.date)} (${DateFormat.Md().format(summary.date)})',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      '${summary.totalCalories.toStringAsFixed(0)} kcal',
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                    children:
                        summary.foodEntries.isEmpty
                            ? [
                              const ListTile(
                                title: Text(
                                  'No entries for this day.',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                            ]
                            : summary.foodEntries.map((entry) {
                              return ListTile(
                                title: Text(
                                  entry.name,
                                  style: const TextStyle(color: Colors.white),
                                ),
                                trailing: Text(
                                  '${entry.totalCalories} kcal',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              );
                            }).toList(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  BarChartData _buildBarChartData() {
    return BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: _calculateMaxY(),
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
          getTooltipColor: (group) => Colors.blueGrey,
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            final summary = weeklySummary[group.x.toInt()];
            String label = '';

            // Check which rod was touched
            if (rodIndex == 0) {
              label = '${summary.totalCalories.toStringAsFixed(0)}\nkcal';
            } else {
              label = '${targetCalories.toStringAsFixed(0)}\nkcal (target)';
            }

            return BarTooltipItem(
              label,
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            );
          },
        ),
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (double value, TitleMeta meta) {
              final summary = weeklySummary[value.toInt()];
              return SideTitleWidget(
                meta: meta,
                space: 8.0,
                child: Text(
                  DateFormat.E().format(summary.date).substring(0, 1),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              );
            },
            reservedSize: 38,
          ),
        ),
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      borderData: FlBorderData(show: false),
      gridData: const FlGridData(show: false),
      barGroups:
          weeklySummary.asMap().entries.map((entry) {
            final index = entry.key;
            final summary = entry.value;
            return BarChartGroupData(
              x: index,
              barRods: [
                // First rod for actual calories
                BarChartRodData(
                  toY: summary.totalCalories,
                  color: Colors.deepOrange,
                  width: 12, // Make bars narrower to fit two side by side
                  borderRadius: BorderRadius.circular(6),
                ),
                // Second rod for target calories
                BarChartRodData(
                  toY: targetCalories,
                  color: Colors.green.shade400, // Different color for target
                  width: 12,
                  borderRadius: BorderRadius.circular(6),
                ),
              ],
              // Add spacing between groups
              barsSpace: 4,
            );
          }).toList(),
    );
  }

  // Update the _calculateMaxY method to consider target calories too
  double _calculateMaxY() {
    if (weeklySummary.isEmpty) {
      return targetCalories * 1.2; // Default based on target
    }

    final maxCalories = weeklySummary
        .map((s) => s.totalCalories)
        .reduce((a, b) => a > b ? a : b);

    // Return whichever is higher: actual calories or target calories, with 20% padding
    return (maxCalories > targetCalories ? maxCalories : targetCalories) * 1.2;
  }
}
