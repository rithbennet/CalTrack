// lib/models/nutritional_summary.dart

import 'package:caltrack/models/food_entry.dart'; // Assuming this is your model

class DailyNutritionalSummary {
  final DateTime date;
  final double totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;
  final List<FoodEntry> foodEntries;

  DailyNutritionalSummary({
    required this.date,
    this.totalCalories = 0.0,
    this.totalProtein = 0.0,
    this.totalCarbs = 0.0,
    this.totalFat = 0.0,
    this.foodEntries = const [],
  });
}
