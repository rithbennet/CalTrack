class FoodEntry {
  final String? id;
  final String name;
  final double servings;
  final String servingUnit;
  final int caloriesPerServing;
  final double protein;
  final double carbs;
  final double fat;
  final DateTime? date;
  final String? notes;

  FoodEntry({
    this.id,
    required this.name,
    required this.servings,
    required this.servingUnit,
    required this.caloriesPerServing,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.date,
    this.notes,
  });

  // Computed property for total calories
  int get totalCalories => (caloriesPerServing * servings).round();

  // Add this factory constructor to handle Firestore data
  factory FoodEntry.fromMap(Map<String, dynamic> map) {
    return FoodEntry(
      id: map['id'],
      name: map['foodName'] ?? '',
      servings: (map['servings'] is num) ? map['servings'].toDouble() : 1.0,
      servingUnit: map['servingUnit'] ?? 'serving',
      caloriesPerServing:
          (map['caloriesPerServing'] is int)
              ? map['caloriesPerServing']
              : (map['caloriesPerServing'] is double)
              ? map['caloriesPerServing'].toInt()
              : (map['calories'] is int) // fallback to old calories field
              ? map['calories']
              : (map['calories'] is double)
              ? map['calories'].toInt()
              : 0,
      protein: (map['protein'] is num) ? map['protein'].toDouble() : 0.0,
      carbs: (map['carbs'] is num) ? map['carbs'].toDouble() : 0.0,
      fat: (map['fat'] is num) ? map['fat'].toDouble() : 0.0,
      date: (map['date'] as dynamic)?.toDate(),
      notes: map['notes'],
    );
  }
}
