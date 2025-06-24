// lib/view/components/home/daily_report_card.dart
import 'package:flutter/material.dart';
import 'package:caltrack/models/nutritional_summary.dart';

class DailyReportCard extends StatelessWidget {
  final DailyNutritionalSummary summary;
  final VoidCallback onTap;

  const DailyReportCard({
    super.key,
    required this.summary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: const Color(0xFF1F1F1F),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Daily Report',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '${summary.totalCalories.toStringAsFixed(0)} kcal',
                style: const TextStyle(
                  color: Colors.tealAccent,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tap to see details',
                style: TextStyle(color: Colors.grey[400]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
