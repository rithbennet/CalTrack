import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/food_item.dart';

class BarcodeViewModel extends ChangeNotifier {
  FoodItem? scannedFood;

  void clear() {
    scannedFood = null;
    notifyListeners();
  }

  // Helper method to safely convert to double
  double _safeToDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  Future<void> fetchFoodInfo(String barcode) async {
    final url = Uri.parse(
      'https://world.openfoodfacts.net/api/v2/product/$barcode?fields=product_name,nutriscore_data,nutriments,nutrition_grades',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 1) {
          final product = data['product'];
          final nutriments = product['nutriments'] ?? {};

          scannedFood = FoodItem(
            barcode: barcode,
            name: product['product_name'] ?? 'Unknown',
            calories: _safeToDouble(nutriments['energy-kcal_100g']),
            protein: _safeToDouble(nutriments['proteins_100g']),
            carbohydrates: _safeToDouble(nutriments['carbohydrates_100g']),
            sugars: _safeToDouble(nutriments['sugars_100g']),
            fat: _safeToDouble(nutriments['fat_100g']),
            saturatedFat: _safeToDouble(nutriments['saturated-fat_100g']),
            servingSize: 'per 100g',
          );
        } else {
          // Product not found
          scannedFood = null;
        }
      } else {
        scannedFood = null;
      }
    } catch (e) {
      scannedFood = null;
      if (kDebugMode) {
        print('Error fetching food info: $e');
      }
    }

    notifyListeners();
  }
}
