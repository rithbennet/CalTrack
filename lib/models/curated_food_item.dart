import 'package:logger/logger.dart';

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
    try {
      return CuratedFoodItem(
        id: map['id'] ?? '',
        name: (map['name'] ?? '').toString().trim(),
        brand: (map['brand'] ?? '').toString().trim(),
        caloriesPerServing: _parseIntSafely(map['caloriesPerServing'], 0),
        servingUnit: (map['servingUnit'] ?? 'serving').toString().trim(),
        servingSize: _parseDoubleSafely(map['servingSize'], 1.0),
        protein: _parseDoubleSafely(map['protein'], 0.0),
        carbs: _parseDoubleSafely(map['carbs'], 0.0),
        fat: _parseDoubleSafely(map['fat'], 0.0),
        tags: _parseStringList(map['tags']),
        category: (map['category'] ?? 'other').toString().trim(),
        rating: _parseDoubleSafely(map['rating'], 0.0),
        reviewCount: _parseIntSafely(map['reviewCount'], 0),
      );
    } catch (e) {
      Logger().e(
        'Error parsing CuratedFoodItem from map: $e',
        error: e,
        stackTrace: StackTrace.current,
      );
      Logger().e('Map data: $map');
      // Return a safe default item
      return CuratedFoodItem(
        id: map['id'] ?? '',
        name: 'Unknown Food',
        brand: '',
        caloriesPerServing: 0,
        servingUnit: 'serving',
        servingSize: 1.0,
        protein: 0.0,
        carbs: 0.0,
        fat: 0.0,
        tags: [],
        category: 'other',
        rating: 0.0,
        reviewCount: 0,
      );
    }
  }

  static int _parseIntSafely(dynamic value, int defaultValue) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      return int.tryParse(value) ?? defaultValue;
    }
    return defaultValue;
  }

  static double _parseDoubleSafely(dynamic value, double defaultValue) {
    if (value == null) return defaultValue;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? defaultValue;
    }
    return defaultValue;
  }

  static List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    return [];
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
