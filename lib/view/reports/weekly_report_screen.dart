import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:caltrack/models/nutritional_summary.dart';

class WeeklyReportScreen extends StatelessWidget {
  final List<DailyNutritionalSummary> weeklySummary;

  const WeeklyReportScreen({super.key, required this.weeklySummary});

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
                swapAnimationDuration: const Duration(milliseconds: 450),
                swapAnimationCurve: Curves.easeOut,
              ),
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
          // UPDATED THIS LINE: Replaced 'tooltipBgColor' with 'getTooltipColor'
          getTooltipColor: (group) => Colors.blueGrey,
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            final summary = weeklySummary[group.x.toInt()];
            return BarTooltipItem(
              '${summary.totalCalories.toStringAsFixed(0)}\nkcal',
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
                BarChartRodData(
                  toY: summary.totalCalories,
                  color: Colors.deepOrange,
                  width: 20,
                  borderRadius: BorderRadius.circular(6),
                ),
              ],
            );
          }).toList(),
    );
  }

  // Helper to set the chart's max Y value slightly above the highest bar
  double _calculateMaxY() {
    if (weeklySummary.isEmpty) return 2000; // Default value
    final maxCalories = weeklySummary
        .map((s) => s.totalCalories)
        .reduce((a, b) => a > b ? a : b);
    return maxCalories * 1.2; // 20% padding at the top
  }
}
