class FoodItem {
  final String barcode;
  final String name;
  final double caloriesTotal; // changed from int to double
  final double caloriesPerServing; // changed from int to double
  final String servingSize;

  FoodItem({
    required this.barcode,
    required this.name,
    required this.caloriesTotal,
    required this.caloriesPerServing,
    required this.servingSize,
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      barcode: json['barcode'] ?? '',
      name: json['name'] ?? 'Unknown',
      caloriesTotal: (json['calories_total'] ?? 0).toDouble(),
      caloriesPerServing: (json['calories_per_serving'] ?? 0).toDouble(),
      servingSize: json['serving_size'] ?? '',
    );
  }
}
