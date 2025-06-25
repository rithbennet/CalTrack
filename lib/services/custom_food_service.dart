import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/curated_food_item.dart';

class CustomFoodService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add a custom food item for a user
  Future<void> addCustomFood(String userId, CuratedFoodItem food) async {
    try {
      // Validate required fields
      if (userId.isEmpty) {
        throw Exception('User ID cannot be empty');
      }

      if (food.name.isEmpty) {
        throw Exception('Food name cannot be empty');
      }

      if (food.servingUnit.isEmpty) {
        throw Exception('Serving unit cannot be empty');
      }

      if (food.category.isEmpty) {
        throw Exception('Category cannot be empty');
      }

      final now = DateTime.now();
      final foodData = food.toMap();

      // Add required fields for Firestore security rules
      foodData['userId'] = userId;
      foodData['createdAt'] = Timestamp.fromDate(now);
      foodData['updatedAt'] = Timestamp.fromDate(now);

      print('Adding custom food to Firestore: ${food.name}');
      print('Food data: $foodData');

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('custom_foods')
          .add(foodData);

      print('Successfully added custom food to Firestore');
    } catch (e) {
      print('Error adding custom food: $e');
      rethrow;
    }
  }

  // Get all custom foods for a user
  Stream<List<CuratedFoodItem>> getCustomFoodsStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('custom_foods')
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            try {
              final data = doc.data();
              data['id'] = doc.id;
              print(
                'Processing custom food doc: ${doc.id}, name: ${data['name']}',
              );
              final food = CuratedFoodItem.fromMap(data);
              print('Created CuratedFoodItem: ${food.name}, id: ${food.id}');
              return food;
            } catch (e) {
              print('Error processing custom food document ${doc.id}: $e');
              print('Document data: ${doc.data()}');
              // Return a minimal valid food item to prevent crashes
              return CuratedFoodItem(
                id: doc.id,
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
          }).toList();
        });
  }

  // Search custom foods by name
  Future<List<CuratedFoodItem>> searchCustomFoods({
    required String userId,
    required String query,
    String filter = 'All',
  }) async {
    try {
      final snapshot =
          await _firestore
              .collection('users')
              .doc(userId)
              .collection('custom_foods')
              .get();

      List<CuratedFoodItem> allFoods =
          snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return CuratedFoodItem.fromMap(data);
          }).toList();

      // Filter by search query
      final lowerQuery = query.toLowerCase();
      List<CuratedFoodItem> filteredFoods =
          allFoods.where((food) {
            return food.name.toLowerCase().contains(lowerQuery) ||
                food.brand.toLowerCase().contains(lowerQuery) ||
                food.tags.any((tag) => tag.toLowerCase().contains(lowerQuery));
          }).toList();

      // Apply category filter
      if (filter != 'All') {
        filteredFoods =
            filteredFoods
                .where(
                  (food) =>
                      food.category.toLowerCase() == filter.toLowerCase() ||
                      food.category.toLowerCase() ==
                          filter.toLowerCase().replaceAll('s', ''),
                )
                .toList();
      }

      return filteredFoods;
    } catch (e) {
      print('Error searching custom foods: $e');
      return [];
    }
  }

  // Update a custom food item
  Future<void> updateCustomFood(String userId, CuratedFoodItem food) async {
    try {
      final foodData = food.toMap();
      foodData['updatedAt'] = Timestamp.fromDate(DateTime.now());

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('custom_foods')
          .doc(food.id)
          .update(foodData);
    } catch (e) {
      print('Error updating custom food: $e');
      rethrow;
    }
  }

  // Delete a custom food item
  Future<void> deleteCustomFood(String userId, String foodId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('custom_foods')
          .doc(foodId)
          .delete();
    } catch (e) {
      print('Error deleting custom food: $e');
      rethrow;
    }
  }

  // Get custom foods by category
  Future<List<CuratedFoodItem>> getCustomFoodsByCategory(
    String userId,
    String category,
  ) async {
    try {
      final snapshot =
          await _firestore
              .collection('users')
              .doc(userId)
              .collection('custom_foods')
              .where('category', isEqualTo: category.toLowerCase())
              .orderBy('name')
              .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return CuratedFoodItem.fromMap(data);
      }).toList();
    } catch (e) {
      print('Error getting custom foods by category: $e');
      return [];
    }
  }
}
