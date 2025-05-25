import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Test connection to Firestore
  Future<bool> testConnection() async {
    try {
      // Try to write a test document
      await _db.collection('connection_test').doc('test').set({
        'timestamp': FieldValue.serverTimestamp(),
        'message': 'Connection test successful',
      });

      // Try to read the document back
      DocumentSnapshot doc =
          await _db.collection('connection_test').doc('test').get();

      // Clean up the test document
      await _db.collection('connection_test').doc('test').delete();

      return doc.exists;
    } catch (e) {
      print('Firestore connection test failed: $e');
      return false;
    }
  }

  // Create user profile
  Future<void> createUserProfile({
    required String userId,
    required String email,
    String? displayName,
    String? photoURL,
  }) async {
    try {
      await _db.collection('users').doc(userId).set({
        'email': email,
        'displayName': displayName,
        'photoURL': photoURL,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error creating user profile: $e');
      rethrow;
    }
  }

  // Get user profile
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      DocumentSnapshot doc = await _db.collection('users').doc(userId).get();
      return doc.exists ? doc.data() as Map<String, dynamic>? : null;
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  // Update user profile
  Future<void> updateUserProfile(
    String userId,
    Map<String, dynamic> data,
  ) async {
    try {
      data['updatedAt'] = FieldValue.serverTimestamp();
      await _db.collection('users').doc(userId).update(data);
    } catch (e) {
      print('Error updating user profile: $e');
      rethrow;
    }
  }

  // Add a sample calorie entry
  Future<String?> addCalorieEntry({
    required String userId,
    required String foodName,
    required double calories,
    required DateTime date,
    String? notes,
  }) async {
    try {
      DocumentReference docRef = await _db
          .collection('users')
          .doc(userId)
          .collection('calorie_entries')
          .add({
            'foodName': foodName,
            'calories': calories,
            'date': Timestamp.fromDate(date),
            'notes': notes,
            'createdAt': FieldValue.serverTimestamp(),
          });
      return docRef.id;
    } catch (e) {
      print('Error adding calorie entry: $e');
      return null;
    }
  }

  // Get calorie entries for a specific date
  Future<List<Map<String, dynamic>>> getCalorieEntriesForDate(
    String userId,
    DateTime date,
  ) async {
    try {
      DateTime startOfDay = DateTime(date.year, date.month, date.day);
      DateTime endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      QuerySnapshot snapshot =
          await _db
              .collection('users')
              .doc(userId)
              .collection('calorie_entries')
              .where(
                'date',
                isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
              )
              .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
              .orderBy('date', descending: true)
              .get();

      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error getting calorie entries: $e');
      return [];
    }
  }

  // Delete calorie entry
  Future<bool> deleteCalorieEntry(String userId, String entryId) async {
    try {
      await _db
          .collection('users')
          .doc(userId)
          .collection('calorie_entries')
          .doc(entryId)
          .delete();
      return true;
    } catch (e) {
      print('Error deleting calorie entry: $e');
      return false;
    }
  }

  // Stream of user's calorie entries for real-time updates
  Stream<List<Map<String, dynamic>>> streamCalorieEntriesForDate(
    String userId,
    DateTime date,
  ) {
    DateTime startOfDay = DateTime(date.year, date.month, date.day);
    DateTime endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    return _db
        .collection('users')
        .doc(userId)
        .collection('calorie_entries')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            Map<String, dynamic> data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList();
        });
  }

  // Get total calories for a specific date
  Future<double> getTotalCaloriesForDate(String userId, DateTime date) async {
    try {
      List<Map<String, dynamic>> entries = await getCalorieEntriesForDate(
        userId,
        date,
      );
      double total = 0;
      for (var entry in entries) {
        total += (entry['calories'] as num).toDouble();
      }
      return total;
    } catch (e) {
      print('Error calculating total calories: $e');
      return 0;
    }
  }
}
