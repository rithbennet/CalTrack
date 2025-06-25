import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/favorite_food.dart';
import '../models/curated_food_item.dart';
import '../models/food_entry.dart';

class FavoriteFoodService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add a food to favorites
  Future<void> addToFavorites(String userId, CuratedFoodItem foodItem) async {
    try {
      // Validate required fields
      if (userId.isEmpty) {
        throw Exception('User ID cannot be empty');
      }

      if (foodItem.name.isEmpty) {
        throw Exception('Food name cannot be empty');
      }

      // Check if food is already in favorites
      final existingFavorite =
          await _firestore
              .collection('users')
              .doc(userId)
              .collection('favorite_foods')
              .where('name', isEqualTo: foodItem.name)
              .where('brand', isEqualTo: foodItem.brand)
              .limit(1)
              .get();

      if (existingFavorite.docs.isNotEmpty) {
        throw Exception('Food is already in favorites');
      }

      final now = DateTime.now();
      final favoriteFood = FavoriteFood(
        id: '', // Will be set by Firestore
        name: foodItem.name,
        brand: foodItem.brand,
        caloriesPerServing: foodItem.caloriesPerServing,
        servingUnit: foodItem.servingUnit,
        servingSize: foodItem.servingSize,
        protein: foodItem.protein,
        carbs: foodItem.carbs,
        fat: foodItem.fat,
        tags: foodItem.tags,
        category: foodItem.category,
        dateAdded: now,
        userId: userId,
      );

      final data = favoriteFood.toMap();
      // Remove the DateTime and replace with proper Timestamp
      data.remove('dateAdded');
      data['dateAdded'] = Timestamp.fromDate(now);
      data['createdAt'] = Timestamp.fromDate(now);
      data['updatedAt'] = Timestamp.fromDate(now);

      print('Adding favorite food to Firestore: ${foodItem.name}');
      print('Data being sent: $data');

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('favorite_foods')
          .add(data);

      print('Successfully added favorite food to Firestore');
    } catch (e) {
      print('Error adding favorite food: $e');
      rethrow;
    }
  }

  // Add a food entry to favorites
  Future<void> addFoodEntryToFavorites(
    String userId,
    FoodEntry foodEntry,
  ) async {
    try {
      print('=== Adding FoodEntry to favorites ===');
      print('FoodEntry name: "${foodEntry.name}"');
      print('FoodEntry id: "${foodEntry.id}"');
      print('FoodEntry caloriesPerServing: ${foodEntry.caloriesPerServing}');
      print('FoodEntry servingUnit: "${foodEntry.servingUnit}"');

      // Convert FoodEntry to CuratedFoodItem for compatibility
      final curatedFood = CuratedFoodItem(
        id: foodEntry.id ?? '',
        name: foodEntry.name,
        brand: '', // Food entries don't have brands
        caloriesPerServing: foodEntry.caloriesPerServing,
        servingUnit: foodEntry.servingUnit,
        servingSize: foodEntry.servings,
        protein: foodEntry.protein,
        carbs: foodEntry.carbs,
        fat: foodEntry.fat,
        tags: [],
        category: 'other',
        rating: 0.0,
        reviewCount: 0,
      );

      print('Converted to CuratedFoodItem name: "${curatedFood.name}"');
      await addToFavorites(userId, curatedFood);
    } catch (e) {
      print('Error adding food entry to favorites: $e');
      rethrow;
    }
  }

  // Remove a food from favorites
  Future<void> removeFromFavorites(String userId, String favoriteId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('favorite_foods')
          .doc(favoriteId)
          .delete();

      print('Successfully removed favorite food');
    } catch (e) {
      print('Error removing favorite food: $e');
      rethrow;
    }
  }

  // Check if a food is in favorites
  Future<bool> isFavorite(
    String userId,
    String foodName,
    String foodBrand,
  ) async {
    try {
      final snapshot =
          await _firestore
              .collection('users')
              .doc(userId)
              .collection('favorite_foods')
              .where('name', isEqualTo: foodName)
              .where('brand', isEqualTo: foodBrand)
              .limit(1)
              .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking if food is favorite: $e');
      return false;
    }
  }

  // Get favorite food ID if it exists
  Future<String?> getFavoriteId(
    String userId,
    String foodName,
    String foodBrand,
  ) async {
    try {
      final snapshot =
          await _firestore
              .collection('users')
              .doc(userId)
              .collection('favorite_foods')
              .where('name', isEqualTo: foodName)
              .where('brand', isEqualTo: foodBrand)
              .limit(1)
              .get();

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first.id;
      }
      return null;
    } catch (e) {
      print('Error getting favorite ID: $e');
      return null;
    }
  }

  // Get all favorite foods for a user
  Stream<List<FavoriteFood>> getFavoriteFoodsStream(String userId) {
    print('Getting favorites stream for user: $userId');
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('favorite_foods')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          print(
            'Received ${snapshot.docs.length} favorite foods from Firestore',
          );
          return snapshot.docs.map((doc) {
            try {
              final data = doc.data();
              data['id'] = doc.id;
              print('=== Processing favorite food doc ===');
              print('Doc ID: ${doc.id}');
              print('Raw data keys: ${data.keys.toList()}');
              print(
                'Name field: ${data['name']} (type: ${data['name'].runtimeType})',
              );
              print(
                'Brand field: ${data['brand']} (type: ${data['brand'].runtimeType})',
              );
              print(
                'DateAdded field: ${data['dateAdded']} (type: ${data['dateAdded'].runtimeType})',
              );
              print(
                'CreatedAt field: ${data['createdAt']} (type: ${data['createdAt'].runtimeType})',
              );

              // Convert Firestore Timestamp to DateTime for dateAdded
              if (data['dateAdded'] != null && data['dateAdded'] is Timestamp) {
                data['dateAdded'] = (data['dateAdded'] as Timestamp).toDate();
              } else if (data['createdAt'] != null &&
                  data['createdAt'] is Timestamp) {
                // Fallback to createdAt if dateAdded is missing
                data['dateAdded'] = (data['createdAt'] as Timestamp).toDate();
              }
              // Ensure dateAdded is not converted again in the model
              // by setting it as a DateTime

              print('Calling FavoriteFood.fromMap...');
              final favoriteFood = FavoriteFood.fromMap(data);
              print(
                'Successfully created FavoriteFood: ${favoriteFood.name}, id: ${favoriteFood.id}',
              );
              return favoriteFood;
            } catch (e) {
              print('Error processing favorite food document ${doc.id}: $e');
              print('Document data: ${doc.data()}');
              // Return a minimal valid favorite food item to prevent crashes
              return FavoriteFood(
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
                dateAdded: DateTime.now(),
                userId: userId,
              );
            }
          }).toList();
        });
  }

  // Get recent favorite foods (limit to 5)
  Future<List<FavoriteFood>> getRecentFavorites(
    String userId, {
    int limit = 5,
  }) async {
    try {
      final snapshot =
          await _firestore
              .collection('users')
              .doc(userId)
              .collection('favorite_foods')
              .orderBy('dateAdded', descending: true)
              .limit(limit)
              .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return FavoriteFood.fromMap(data);
      }).toList();
    } catch (e) {
      print('Error getting recent favorites: $e');
      return [];
    }
  }
}
