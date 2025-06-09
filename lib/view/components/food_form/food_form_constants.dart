class FoodFormConstants {
  // Predefined serving fractions
  static const List<double> servingOptions = [
    0.25,
    0.5,
    0.75,
    1.0,
    1.25,
    1.5,
    1.75,
    2.0,
    2.25,
    2.5,
    2.75,
    3.0,
    3.5,
    4.0,
    4.5,
    5.0,
    6.0,
    7.0,
    8.0,
    9.0,
    10.0,
  ];

  // Predefined serving units
  static const List<String> servingUnits = [
    '100g',
    '1 cup',
    '1 tbsp',
    '1 tsp',
    '1 oz',
    '1 slice',
    '1 piece',
    '1 serving',
    '1 bowl',
    '1 plate',
    '1 glass',
    '1 lb',
    'Custom',
  ];

  // Helper method to format serving display
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
    if (serving % 1 == 0) return serving.toInt().toString();
    return serving.toString();
  }
}
