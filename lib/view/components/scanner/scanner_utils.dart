class ScannerUtils {
  /// Formats serving size for display
  /// Converts decimal values to fractions where appropriate
  static String formatServing(double serving) {
    if (serving == 0.25) return '1/4';
    if (serving == 0.5) return '1/2';
    if (serving == 0.75) return '3/4';
    if (serving == 1.25) return '1 1/4';
    if (serving == 1.5) return '1 1/2';
    if (serving == 1.75) return '1 3/4';
    if (serving == 2.25) return '2 1/4';
    if (serving == 2.5) return '2 1/2';
    if (serving == 2.75) return '2 3/4';

    // For whole numbers, remove decimal
    if (serving % 1 == 0) {
      return serving.toInt().toString();
    }

    // For other decimals, show as is
    return serving.toString();
  }

  /// Calculates total calories based on serving size
  static int calculateTotalCalories(
    double caloriesPerServing,
    double servings,
  ) {
    return (caloriesPerServing * servings).round();
  }

  /// Validates if serving size is valid
  static bool isValidServingSize(double serving) {
    return serving > 0 && serving <= 20; // Max 20 servings
  }

  /// Gets the closest valid serving size from the predefined options
  static double getClosestServingSize(double target, List<double> options) {
    if (options.isEmpty) return 1.0;

    double closest = options.first;
    double minDifference = (target - closest).abs();

    for (double option in options) {
      double difference = (target - option).abs();
      if (difference < minDifference) {
        minDifference = difference;
        closest = option;
      }
    }

    return closest;
  }
}
