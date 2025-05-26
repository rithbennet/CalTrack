// Utility class for calorie calculations
class CalorieCalculator {
  // Activity level multipliers for TDEE calculation
  static const Map<String, double> activityMultipliers = {
    'Sedentary': 1.2,
    'Lightly Active': 1.375,
    'Moderately Active': 1.55,
    'Very Active': 1.725,
    'Extremely Active': 1.9,
  };

  // Goal adjustments (calories per day)
  static const Map<String, int> goalAdjustments = {
    'Lose Weight': -500, // 500 calorie deficit for ~1 lb/week loss
    'Maintain Weight': 0,
    'Gain Weight': 500, // 500 calorie surplus for ~1 lb/week gain
  };

  // Calculate BMR using Mifflin-St Jeor Equation
  static double? calculateBMR({
    required double weight, // kg
    required double height, // cm
    required int age,
    required String gender,
  }) {
    try {
      if (gender.toLowerCase() == 'male') {
        return 10 * weight + 6.25 * height - 5 * age + 5;
      } else {
        return 10 * weight + 6.25 * height - 5 * age - 161;
      }
    } catch (e) {
      return null;
    }
  }

  // Calculate TDEE (Total Daily Energy Expenditure)
  static double? calculateTDEE({
    required double bmr,
    required String activityLevel,
  }) {
    final multiplier = activityMultipliers[activityLevel];
    if (multiplier == null) return null;

    return bmr * multiplier;
  }

  // Calculate daily calorie target based on goal
  static int? calculateDailyCalorieTarget({
    required double tdee,
    required String goal,
  }) {
    final adjustment = goalAdjustments[goal];
    if (adjustment == null) return null;

    return (tdee + adjustment).round();
  }

  // Complete calculation from user data to daily calorie target
  static int? calculateCompleteTarget({
    required double weight,
    required double height,
    required int age,
    required String gender,
    required String activityLevel,
    required String goal,
  }) {
    final bmr = calculateBMR(
      weight: weight,
      height: height,
      age: age,
      gender: gender,
    );

    if (bmr == null) return null;

    final tdee = calculateTDEE(bmr: bmr, activityLevel: activityLevel);
    if (tdee == null) return null;

    return calculateDailyCalorieTarget(tdee: tdee, goal: goal);
  }

  // Get activity level descriptions
  static String getActivityDescription(String activityLevel) {
    switch (activityLevel) {
      case 'Sedentary':
        return 'Little or no exercise';
      case 'Lightly Active':
        return 'Light exercise 1-3 days/week';
      case 'Moderately Active':
        return 'Moderate exercise 3-5 days/week';
      case 'Very Active':
        return 'Hard exercise 6-7 days/week';
      case 'Extremely Active':
        return 'Very hard exercise, physical job';
      default:
        return '';
    }
  }

  // Get goal descriptions
  static String getGoalDescription(String goal) {
    switch (goal) {
      case 'Lose Weight':
        return 'Create a calorie deficit (500 cal/day deficit)';
      case 'Maintain Weight':
        return 'Balance calories in and out';
      case 'Gain Weight':
        return 'Create a calorie surplus (500 cal/day surplus)';
      default:
        return '';
    }
  }
}
