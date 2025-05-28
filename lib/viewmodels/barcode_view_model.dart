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

  Future<void> fetchFoodInfo(String barcode) async {
    final url = Uri.parse(
      'https://world.openfoodfacts.org/api/v2/product/$barcode',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 1) {
          final product = data['product'];

          scannedFood = FoodItem(
            barcode: barcode,
            name: product['product_name'] ?? 'Unknown',
            caloriesTotal:
                (product['nutriments']['energy-kcal_serving'] ?? 0).toDouble(),
            caloriesPerServing:
                (product['nutriments']['energy-kcal_100g'] ?? 0).toDouble(),
            servingSize: product['serving_size'] ?? 'N/A',
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
