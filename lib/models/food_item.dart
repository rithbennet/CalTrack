class FoodItem {
  final String barcode;
  final String name;
  final int caloriesTotal;
  final int caloriesPerServing;
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
      caloriesTotal: json['calories_total'] ?? 0,
      caloriesPerServing: json['calories_per_serving'] ?? 0,
      servingSize: json['serving_size'] ?? '',
    );
  }
}
