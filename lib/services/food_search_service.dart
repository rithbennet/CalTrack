import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/curated_food_item.dart';

class FoodSearchService {
  static const String _baseUrl = 'https://api.nal.usda.gov/fdc/v1';
  static const String _apiKey = 'DEMO_KEY'; // Get free key from USDA

  Future<List<CuratedFoodItem>> searchFoods({
    required String query,
    String filter = 'All',
    int limit = 20,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/foods/search').replace(
        queryParameters: {
          'api_key': _apiKey,
          'query': query,
          'pageSize': limit.toString(),
          'dataType':
              'Branded,Foundation,Survey (FNDDS)', // Include various data types
        },
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final foods = data['foods'] as List;

        return foods.map((food) => _convertToFoodItem(food)).toList();
      }

      return [];
    } catch (e) {
      print('Error searching USDA foods: $e');
      return [];
    }
  }

  CuratedFoodItem _convertToFoodItem(Map<String, dynamic> usdaFood) {
    // Extract nutrition data from USDA format
    final nutrients = usdaFood['foodNutrients'] as List? ?? [];

    double getNutrientValue(int nutrientId) {
      try {
        final nutrient = nutrients.firstWhere(
          (n) => n['nutrientId'] == nutrientId,
          orElse: () => {'value': 0.0},
        );
        return (nutrient['value'] ?? 0.0).toDouble();
      } catch (e) {
        return 0.0;
      }
    }

    // USDA Nutrient IDs
    final calories = getNutrientValue(1008); // Energy (kcal)
    final protein = getNutrientValue(1003); // Protein
    final carbs = getNutrientValue(1005); // Carbohydrates
    final fat = getNutrientValue(1004); // Total lipid (fat)

    return CuratedFoodItem(
      id: usdaFood['fdcId'].toString(),
      name: usdaFood['description'] ?? 'Unknown Food',
      brand: usdaFood['brandOwner'] ?? '',
      caloriesPerServing: calories.round(),
      servingUnit: 'g', // USDA uses grams as base unit
      servingSize: 100.0, // USDA nutrition is per 100g
      protein: protein,
      carbs: carbs,
      fat: fat,
      tags: _extractTags(usdaFood),
      category: _determineCategory(usdaFood['description'] ?? ''),
      rating: 4.0, // Default rating since USDA doesn't have ratings
      reviewCount: 0,
    );
  }

  List<String> _extractTags(Map<String, dynamic> food) {
    List<String> tags = [];

    // Add brand as tag
    if (food['brandOwner'] != null) {
      tags.add(food['brandOwner']);
    }

    // Add data type as tag
    if (food['dataType'] != null) {
      tags.add(food['dataType']);
    }

    // Extract keywords from description
    final description = (food['description'] ?? '').toLowerCase();
    if (description.contains('organic')) tags.add('organic');
    if (description.contains('low fat')) tags.add('low-fat');
    if (description.contains('sugar free')) tags.add('sugar-free');

    return tags;
  }

  String _determineCategory(String description) {
    final desc = description.toLowerCase();

    if (desc.contains('chicken') ||
        desc.contains('beef') ||
        desc.contains('fish')) {
      return 'proteins';
    } else if (desc.contains('apple') ||
        desc.contains('banana') ||
        desc.contains('fruit')) {
      return 'fruits';
    } else if (desc.contains('lettuce') ||
        desc.contains('carrot') ||
        desc.contains('vegetable')) {
      return 'vegetables';
    } else if (desc.contains('bread') ||
        desc.contains('rice') ||
        desc.contains('pasta')) {
      return 'grains';
    } else if (desc.contains('milk') ||
        desc.contains('cheese') ||
        desc.contains('yogurt')) {
      return 'dairy';
    } else if (desc.contains('cookie') ||
        desc.contains('chip') ||
        desc.contains('candy')) {
      return 'snacks';
    } else if (desc.contains('juice') ||
        desc.contains('soda') ||
        desc.contains('drink')) {
      return 'beverages';
    }

    return 'other';
  }

  // Keep your existing methods but they won't be used with USDA
  Future<List<CuratedFoodItem>> getFoodsByCategory(String category) async {
    return searchFoods(query: category, filter: category);
  }

  Future<List<CuratedFoodItem>> getRecommendedFoods(int calorieTarget) async {
    // Search for common healthy foods within calorie range
    final healthyFoods = [
      'chicken breast',
      'salmon',
      'broccoli',
      'quinoa',
      'greek yogurt',
    ];
    List<CuratedFoodItem> recommendations = [];

    for (String food in healthyFoods) {
      final results = await searchFoods(query: food, limit: 2);
      recommendations.addAll(results);
    }

    // Filter by calorie target
    final maxCalories = (calorieTarget * 0.3).round();
    return recommendations
        .where((food) => food.caloriesPerServing <= maxCalories)
        .toList();
  }
}
