import 'dart:io';
import '../../../models/food_item.dart';
import '../../../models/food_entry.dart';

/// Abstract interface for different types of scanners
abstract class ScannerService {
  /// Analyzes an image and returns food information
  Future<FoodItem?> analyzeImage(File image);

  /// Scans a barcode and returns food information
  Future<FoodItem?> scanBarcode(String barcode);

  /// Converts FoodItem to FoodEntry with serving information
  FoodEntry createFoodEntry(FoodItem food, double servings);

  /// Clears any cached data
  void clear();
}

/// Implementation for AI-based food scanning
class AIFoodScannerService implements ScannerService {
  @override
  Future<FoodItem?> analyzeImage(File image) async {
    // This would integrate with your AI service
    // For now, this is a placeholder that matches the existing implementation
    throw UnimplementedError('AI food scanning not implemented yet');
  }

  @override
  Future<FoodItem?> scanBarcode(String barcode) async {
    // This could also be implemented for barcode fallback
    throw UnimplementedError('Barcode scanning in AI service not implemented');
  }

  @override
  FoodEntry createFoodEntry(FoodItem food, double servings) {
    return FoodEntry(
      name: food.name,
      servings: servings,
      servingUnit: food.servingSize,
      caloriesPerServing: food.calories.round(),
      protein: food.protein,
      carbs: food.carbohydrates,
      fat: food.fat,
    );
  }

  @override
  void clear() {
    // Clear any cached data if needed
  }
}

/// Implementation for barcode-based food scanning
class BarcodeFoodScannerService implements ScannerService {
  @override
  Future<FoodItem?> analyzeImage(File image) async {
    // This would use barcode detection on image
    throw UnimplementedError('Image analysis for barcode not implemented');
  }

  @override
  Future<FoodItem?> scanBarcode(String barcode) async {
    // This would integrate with your barcode lookup service
    throw UnimplementedError('Barcode lookup not implemented yet');
  }

  @override
  FoodEntry createFoodEntry(FoodItem food, double servings) {
    return FoodEntry(
      name: food.name,
      servings: servings,
      servingUnit: food.servingSize,
      caloriesPerServing: food.calories.round(),
      protein: food.protein,
      carbs: food.carbohydrates,
      fat: food.fat,
    );
  }

  @override
  void clear() {
    // Clear any cached data if needed
  }
}
