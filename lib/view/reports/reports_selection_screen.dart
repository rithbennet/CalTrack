import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:caltrack/viewmodels/food_log_view_model.dart';
import 'package:caltrack/viewmodels/user_view_model.dart';
import 'daily_report_screen.dart';
import 'weekly_report_screen.dart';

class ReportsSelectionScreen extends StatelessWidget {
  const ReportsSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title: const Text('Reports'),
        backgroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Daily Report Button
              ElevatedButton(
                onPressed: () => _navigateToDailyReport(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  minimumSize: const Size.fromHeight(60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Daily Report',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 20),

              // Weekly Report Button
              ElevatedButton(
                onPressed: () => _navigateToWeeklyReport(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  minimumSize: const Size.fromHeight(60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Weekly Report',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToDailyReport(BuildContext context) {
    final foodLogViewModel = Provider.of<FoodLogViewModel>(
      context,
      listen: false,
    );
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => DailyReportScreen(
              summary: foodLogViewModel.todaySummary,
              // targetCalories: (userViewModel.userProfile?.effectiveDailyCalorieTarget ?? 2000).toDouble(),
            ),
      ),
    );
  }

  void _navigateToWeeklyReport(BuildContext context) {
    final foodLogViewModel = Provider.of<FoodLogViewModel>(
      context,
      listen: false,
    );
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => WeeklyReportScreen(
              weeklySummary: foodLogViewModel.weeklySummary,
              targetCalories:
                  (userViewModel.userProfile?.effectiveDailyCalorieTarget ??
                          2000)
                      .toDouble(),
            ),
      ),
    );
  }
}
