import 'package:flutter/foundation.dart';
import '../models/food_item.dart';

class BarcodeViewModel extends ChangeNotifier {
  FoodItem? scannedFood;

  void clear() {
    scannedFood = null;
    notifyListeners();
  }

  Future<void> fetchFoodInfo(String barcode) async {
    // TODO: Implement actual API call to get food info by barcode
    // For now, dummy data example:
    await Future.delayed(Duration(seconds: 1));
    scannedFood = FoodItem(
      barcode: barcode,
      name: 'Sample Food',
      caloriesTotal: 250,
      caloriesPerServing: 100,
      servingSize: '100g',
    );
    notifyListeners();
  }
}
