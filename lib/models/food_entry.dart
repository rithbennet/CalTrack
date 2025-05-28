class FoodEntry {
  final String? id;
  final String name;
  final int calories;
  final DateTime? date;
  final String? notes;

  FoodEntry({
    this.id,
    required this.name,
    required this.calories,
    this.date,
    this.notes,
  });

  // Add this factory constructor to handle Firestore data
  factory FoodEntry.fromMap(Map<String, dynamic> map) {
    return FoodEntry(
      id: map['id'],
      name: map['foodName'] ?? '',
      calories:
          (map['calories'] is int)
              ? map['calories']
              : (map['calories'] is double)
              ? map['calories'].toInt()
              : 0,
      date: (map['date'] as dynamic)?.toDate(),
      notes: map['notes'],
    );
  }
}
