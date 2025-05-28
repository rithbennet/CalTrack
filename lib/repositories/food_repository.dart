import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/food_entry.dart';

class FoodRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add a new food entry to the user's calorie_entries collection
  Future<void> addFoodEntry(String userId, FoodEntry entry) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('calorie_entries')
          .add({
            'foodName': entry.name,
            'calories': entry.calories,
            'date': DateTime.now(),
            'createdAt': FieldValue.serverTimestamp(),
            'notes': entry.notes ?? '',
          });
    } catch (e) {
      print('Error adding food entry: $e');
      rethrow;
    }
  }

  // Get stream of food entries for a specific user
  Stream<List<FoodEntry>> getFoodEntriesStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('calorie_entries')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
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
      print('Error deleting food entry: $e');
      rethrow;
    }
  }

  // Update a food entry
  Future<void> updateFoodEntry(String userId, FoodEntry entry) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('calorie_entries')
          .doc(entry.id)
          .update({
            'foodName': entry.name,
            'calories': entry.calories,
            'notes': entry.notes ?? '',
          });
    } catch (e) {
      print('Error updating food entry: $e');
      rethrow;
    }
  }
}
