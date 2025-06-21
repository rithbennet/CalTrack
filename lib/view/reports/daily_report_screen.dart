// lib/view/reports/daily_report_screen.dart
import 'package:flutter/material.dart';
import 'package:caltrack/models/nutritional_summary.dart';
// You might want to use a charting library like fl_chart
// import 'package:fl_chart/fl_chart.dart';

class DailyReportScreen extends StatelessWidget {
  final DailyNutritionalSummary summary;

  const DailyReportScreen({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daily Report - ${summary.date.month}/${summary.date.day}'),
        backgroundColor: Colors.black87,
      ),
      backgroundColor: Colors.black87,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Calories: ${summary.totalCalories.toStringAsFixed(0)} kcal',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Macro Breakdown',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 16),
            _buildMacroInfo(
              'Protein',
              '${summary.totalProtein.toStringAsFixed(1)}g',
              Colors.blue,
            ),
            _buildMacroInfo(
              'Carbohydrates',
              '${summary.totalCarbs.toStringAsFixed(1)}g',
              Colors.green,
            ),
            _buildMacroInfo(
              'Fat',
              '${summary.totalFat.toStringAsFixed(1)}g',
              Colors.orange,
            ),
            const SizedBox(height: 24),
            Text(
              'Logged Foods',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: Colors.white),
            ),
            const Divider(color: Colors.grey),
            // List all the foods logged
            ...summary.foodEntries.map(
              (entry) => ListTile(
                title: Text(
                  entry.name,
                  style: const TextStyle(color: Colors.white),
                ),
                trailing: Text(
                  '${entry.caloriesPerServing.toStringAsFixed(0)} kcal',
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroInfo(String title, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(width: 10, height: 10, color: color),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
