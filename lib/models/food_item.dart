class FoodItem {
  final String barcode;
  final String name;
  final double calories;
  final double protein;
  final double carbohydrates;
  final double sugars;
  final double fat;
  final double saturatedFat;
  final String servingSize; // e.g., "per 100g", "per serving", etc.

  FoodItem({
    required this.barcode,
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbohydrates,
    required this.sugars,
    required this.fat,
    required this.saturatedFat,
    required this.servingSize,
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      barcode: json['barcode'] ?? '',
      name: json['name'] ?? 'Unknown',
      calories: (json['calories'] ?? 0).toDouble(),
      protein: (json['protein'] ?? 0).toDouble(),
      carbohydrates: (json['carbohydrates'] ?? 0).toDouble(),
      sugars: (json['sugars'] ?? 0).toDouble(),
      fat: (json['fat'] ?? 0).toDouble(),
      saturatedFat: (json['saturated_fat'] ?? 0).toDouble(),
      servingSize: json['serving_size'] ?? 'per 100g',
    );
  }
}
