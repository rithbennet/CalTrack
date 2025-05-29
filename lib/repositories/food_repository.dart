import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/food_entry.dart';
import '../services/logger_service.dart';

class FoodRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LoggerService _logger = LoggerService();

  // Add a new food entry to the user's calorie_entries collection
  Future<void> addFoodEntry(String userId, FoodEntry entry) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('calorie_entries')
          .add({
            'foodName': entry.name,
            'servings': entry.servings,
            'servingUnit': entry.servingUnit,
            'caloriesPerServing': entry.caloriesPerServing,
            'protein': entry.protein,
            'carbs': entry.carbs,
            'fat': entry.fat,
            'totalCalories': entry.totalCalories, // For backward compatibility
            'calories': entry.totalCalories, // Keep old field for compatibility
            'date': DateTime.now(),
            'createdAt': FieldValue.serverTimestamp(),
            'notes': entry.notes ?? '',
          });
      _logger.info('Added food entry for user $userId: ${entry.name}');
    } catch (e) {
      _logger.error('Error adding food entry', e);
      rethrow;
    }
  }

  // Get stream of food entries for a specific user
  Stream<List<FoodEntry>> getFoodEntriesStream(String userId) {
    _logger.debug('Getting food entries stream for user: $userId');
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('calorie_entries')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          _logger.debug('Received ${snapshot.docs.length} food entries');
          return snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id; // Add document ID to the data
            return FoodEntry.fromMap(data);
          }).toList();
        });
  }

  // Delete a food entry
  Future<void> deleteFoodEntry(String userId, String entryId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('calorie_entries')
          .doc(entryId)
          .delete();
    } catch (e) {
      _logger.error('Error deleting food entry', e);
      rethrow;
    }
  }

  // Get total calories for today for a specific user
  Future<int> getTodayCalories(String userId) async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);

    final snapshot =
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('calorie_entries')
            .where('date', isGreaterThanOrEqualTo: startOfDay)
            .where('date', isLessThanOrEqualTo: endOfDay)
            .get();

    int total = 0;
    for (var doc in snapshot.docs) {
      final data = doc.data();
      // Try new field first, fall back to old field for backward compatibility
      int calories = (data['totalCalories'] ?? data['calories'] ?? 0) as int;
      total += calories;
    }
    return total;
  }
}
