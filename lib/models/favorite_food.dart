import 'package:logger/logger.dart';

class FavoriteFood {
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
  final DateTime dateAdded;
  final String userId;

  FavoriteFood({
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
    required this.dateAdded,
    required this.userId,
  });

  factory FavoriteFood.fromMap(Map<String, dynamic> map) {
    try {
      final favoriteFood = FavoriteFood(
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
        dateAdded: _parseDateTimeSafely(map['dateAdded']),
        userId: map['userId'] ?? '',
      );

      Logger().i(
        'Successfully created FavoriteFood with name: ${favoriteFood.name}',
      );
      return favoriteFood;
    } catch (e, stackTrace) {
      Logger().e(
        'Error parsing FavoriteFood from map: $e',
        error: e,
        stackTrace: stackTrace,
      );
      Logger().w('Map data: $map');
      // Return a safe default item
      return FavoriteFood(
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
        dateAdded: DateTime.now(),
        userId: map['userId'] ?? '',
      );
    }
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
      'dateAdded': dateAdded,
      'userId': userId,
    };
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

  static DateTime _parseDateTimeSafely(dynamic value) {
    try {
      if (value == null) return DateTime.now();
      if (value is DateTime) return value;

      // Check for Firestore Timestamp by trying to call toDate()
      if (value.runtimeType.toString().contains('Timestamp')) {
        return value.toDate();
      }

      if (value is String) {
        return DateTime.tryParse(value) ?? DateTime.now();
      }

      // If it has a toDate method, try to call it
      try {
        return value.toDate();
      } catch (e) {
        // If toDate() fails, return current time
        return DateTime.now();
      }
    } catch (e) {
      Logger().e(
        'Error parsing DateTime: $e, value: $value, type: ${value.runtimeType}',
      );
      return DateTime.now();
    }
  }
}
