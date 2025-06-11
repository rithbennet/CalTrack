import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import '../models/curated_food_item.dart';
import 'api_logger_service.dart'; // Add this import

class FoodSearchService {
  static const String _baseUrl = 'https://api.nal.usda.gov/fdc/v1';
  static String get _apiKey => dotenv.env['USDA_API_KEY'] ?? 'DEMO_KEY';
  
  final ApiLoggerService _apiLogger = ApiLoggerService(); // Add this

  Future<List<CuratedFoodItem>> searchFoods({
    required String query,
    String filter = 'All',
    int limit = 20,
  }) async {
    // Don't search for queries that are too short
    if (query.trim().length < 2) {
      return [];
    }

    final endpoint = '$_baseUrl/foods/search';
    final parameters = {
      'api_key': _apiKey,
      'query': query.trim(),
      'pageSize': limit.toString(),
      'dataType': 'Branded,Foundation,Survey (FNDDS)',
    };

    // Log the API request
    _apiLogger.logApiRequest(
      endpoint: endpoint,
      query: query.trim(),
      parameters: parameters,
      filter: filter,
    );

    final startTime = DateTime.now();

    try {
      final url = Uri.parse(endpoint).replace(queryParameters: parameters);
      final response = await http.get(url);
      final responseTime = DateTime.now().difference(startTime);

      // Extract rate limit headers
      final responseHeaders = <String, String>{};
      response.headers.forEach((key, value) {
        if (key.toLowerCase().contains('ratelimit') || 
            key.toLowerCase().contains('x-ratelimit')) {
          responseHeaders[key] = value;
        }
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final foods = data['foods'] as List;

        // Apply additional client-side filtering if needed
        List<CuratedFoodItem> results = foods
            .map((food) => _convertToFoodItem(food))
            .toList();

        // Apply category filter if not "All"
        if (filter != 'All') {
          final originalCount = results.length;
          results = results.where((food) => 
            food.category.toLowerCase() == filter.toLowerCase() ||
            food.category.toLowerCase() == filter.toLowerCase().replaceAll('s', '')
          ).toList();
          
          // Log filtering info
          Logger().d('Filtered from $originalCount to ${results.length} results for category: $filter');
        }

        // Ensure we don't exceed the limit after filtering
        final finalResults = results.take(limit).toList();

        // Log successful API response
        _apiLogger.logApiSuccess(
          endpoint: endpoint,
          resultCount: finalResults.length,
          statusCode: response.statusCode,
          responseTime: responseTime,
          responseHeaders: responseHeaders,
        );

        return finalResults;
      } else {
        // Log API error
        _apiLogger.logApiError(
          endpoint: endpoint,
          statusCode: response.statusCode,
          error: 'HTTP ${response.statusCode}: ${response.reasonPhrase}',
          responseTime: responseTime,
          responseHeaders: responseHeaders,
        );
        return [];
      }
    } catch (e, stackTrace) {
      final responseTime = DateTime.now().difference(startTime);
      
      // Log API error
      _apiLogger.logApiError(
        endpoint: endpoint,
        statusCode: 0, // Unknown status code for network errors
        error: e.toString(),
        responseTime: responseTime,
        stackTrace: stackTrace,
      );

      Logger().e(
        'Error searching USDA foods',
        error: e,
        stackTrace: stackTrace,
      );
      return [];
    }
  }

  // Add method to get API statistics
  void logApiStatistics() {
    _apiLogger.logApiStatistics();
  }

  // Add method to reset statistics
  void resetApiStatistics() {
    _apiLogger.resetStatistics();
  }

  // Add method to get current statistics
  Map<String, dynamic> getApiStatistics() {
    return {
      'totalRequests': _apiLogger.totalRequests,
      'successfulRequests': _apiLogger.successfulRequests,
      'failedRequests': _apiLogger.failedRequests,
      'rateLimitedRequests': _apiLogger.rateLimitedRequests,
      'lastRequestTime': _apiLogger.lastRequestTime,
      'successRate': _apiLogger.totalRequests > 0 
          ? (_apiLogger.successfulRequests / _apiLogger.totalRequests * 100)
          : 0.0,
    };
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
        desc.contains('fish') ||
        desc.contains('pork') ||
        desc.contains('turkey') ||
        desc.contains('lamb') ||
        desc.contains('protein')) {
      return 'proteins';
    } else if (desc.contains('apple') ||
        desc.contains('banana') ||
        desc.contains('orange') ||
        desc.contains('berry') ||
        desc.contains('grape') ||
        desc.contains('fruit')) {
      return 'fruits';
    } else if (desc.contains('lettuce') ||
        desc.contains('carrot') ||
        desc.contains('broccoli') ||
        desc.contains('spinach') ||
        desc.contains('tomato') ||
        desc.contains('vegetable')) {
      return 'vegetables';
    } else if (desc.contains('bread') ||
        desc.contains('rice') ||
        desc.contains('pasta') ||
        desc.contains('wheat') ||
        desc.contains('oat') ||
        desc.contains('grain')) {
      return 'grains';
    } else if (desc.contains('milk') ||
        desc.contains('cheese') ||
        desc.contains('yogurt') ||
        desc.contains('butter') ||
        desc.contains('cream')) {
      return 'dairy';
    } else if (desc.contains('cookie') ||
        desc.contains('chip') ||
        desc.contains('candy') ||
        desc.contains('chocolate') ||
        desc.contains('snack')) {
      return 'snacks';
    } else if (desc.contains('juice') ||
        desc.contains('soda') ||
        desc.contains('drink') ||
        desc.contains('water') ||
        desc.contains('tea') ||
        desc.contains('coffee')) {
      return 'beverages';
    }

    return 'other'; // This was missing in your original code
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
