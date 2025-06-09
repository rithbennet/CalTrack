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
      barcode: json['barcode'] ?? 'N/A',
      name: json['name'] ?? 'Unknown',
      calories: _parseDouble(json['calories']),
      protein: _parseDouble(json['protein']),
      carbohydrates: _parseDouble(json['carbohydrates']),
      sugars: _parseDouble(json['sugars']),
      fat: _parseDouble(json['fat']),
      saturatedFat: _parseDouble(json['saturatedFat']),
      servingSize: json['servingSize'] ?? 'per 100g',
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }
}
