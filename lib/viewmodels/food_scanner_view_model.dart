import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/food_item.dart';
import '../services/gen_ai_service.dart';

class FoodScannerViewModel extends ChangeNotifier {
  FoodItem? _scannedFood;
  bool _isLoading = false;
  String? _errorMessage;

  FoodItem? get scannedFood => _scannedFood;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  final GeminiAiService _aiService = GeminiAiService();

  /// Analyzes a food image using AI to extract nutritional information
  Future<void> analyzeFoodImage(File imageFile) async {
    _isLoading = true;
    _errorMessage = null;
    _scannedFood = null;
    notifyListeners();

    try {
      final foodItem = await _aiService.getFoodDataFromImage(imageFile);

      if (foodItem != null) {
        _scannedFood = foodItem;
        _errorMessage = null;
      } else {
        _errorMessage =
            'Could not analyze the image. Please try with a clearer photo of food.';
      }
    } catch (e) {
      _errorMessage =
          'An error occurred while analyzing the image: ${e.toString()}';
      if (kDebugMode) {
        print('Error analyzing food image: $e');
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Clears the current scan results and resets the state
  void clear() {
    _scannedFood = null;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  /// Returns whether there is a successful scan result
  bool get hasResult => _scannedFood != null;

  /// Returns whether there is an error
  bool get hasError => _errorMessage != null;
}
