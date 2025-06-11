class CuratedFoodItem {
  final String id;
  final String name;
  final String brand;
  final int caloriesPerServing;
  final String servingUnit;
  final double servingSize;
  final double protein;
  final double carbs;
  final double fat;
  final List<String> tags;
  final String category;
  final double rating;
  final int reviewCount;

  CuratedFoodItem({
    required this.id,
    required this.name,
    required this.brand,
    required this.caloriesPerServing,
    required this.servingUnit,
    required this.servingSize,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.tags,
    required this.category,
    required this.rating,
    required this.reviewCount,
  });

  factory CuratedFoodItem.fromMap(Map<String, dynamic> map) {
    return CuratedFoodItem(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      brand: map['brand'] ?? '',
      caloriesPerServing: map['caloriesPerServing'] ?? 0,
      servingUnit: map['servingUnit'] ?? 'serving',
      servingSize: (map['servingSize'] ?? 1.0).toDouble(),
      protein: (map['protein'] ?? 0.0).toDouble(),
      carbs: (map['carbs'] ?? 0.0).toDouble(),
      fat: (map['fat'] ?? 0.0).toDouble(),
      tags: List<String>.from(map['tags'] ?? []),
      category: map['category'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      reviewCount: map['reviewCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'caloriesPerServing': caloriesPerServing,
      'servingUnit': servingUnit,
      'servingSize': servingSize,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'tags': tags,
      'category': category,
      'rating': rating,
      'reviewCount': reviewCount,
    };
  }
}
