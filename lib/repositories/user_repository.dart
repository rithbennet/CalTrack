// lib/repositories/user_repository.dart
import 'package:caltrack/services/firestore_service.dart';
import 'package:caltrack/models/user_model.dart';

class UserRepository {
  final FirestoreService _firestoreService;
  static const String _collectionName = 'users';

  UserRepository({FirestoreService? firestoreService})
    : _firestoreService = firestoreService ?? FirestoreService();

  /// Creates a new user profile in Firestore
  Future<void> createUser(UserModel user) async {
    try {
      await _firestoreService.createDocument(
        collection: _collectionName,
        documentId: user.id,
        data: user.toMap(),
      );
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  /// Gets a user by their ID
  Future<UserModel?> getUser(String userId) async {
    try {
      final data = await _firestoreService.getDocument(
        collection: _collectionName,
        documentId: userId,
      );
      return data != null ? UserModel.fromMap(data) : null;
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  /// Updates an existing user profile
  Future<void> updateUser(UserModel user) async {
    try {
      await _firestoreService.updateDocument(
        collection: _collectionName,
        documentId: user.id,
        data: user.toMap(),
      );
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  /// Deletes a user profile
  Future<void> deleteUser(String userId) async {
    try {
      await _firestoreService.deleteDocument(
        collection: _collectionName,
        documentId: userId,
      );
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }

  /// Checks if a user profile exists
  Future<bool> userExists(String userId) async {
    try {
      return await _firestoreService.documentExists(
        collection: _collectionName,
        documentId: userId,
      );
    } catch (e) {
      throw Exception('Failed to check user existence: $e');
    }
  }

  /// Streams user profile data for real-time updates
  Stream<UserModel?> streamUser(String userId) {
    try {
      return _firestoreService
          .streamDocument(collection: _collectionName, documentId: userId)
          .map((data) {
            return data != null ? UserModel.fromMap(data) : null;
          });
    } catch (e) {
      throw Exception('Failed to stream user: $e');
    }
  }

  /// Gets multiple users (for admin purposes or user search)
  Future<List<UserModel>> getUsers({
    int? limit,
    String? orderBy,
    bool descending = false,
  }) async {
    try {
      final data = await _firestoreService.getDocuments(
        collection: _collectionName,
        queryBuilder: (query) {
          if (orderBy != null) {
            return query.orderBy(orderBy, descending: descending);
          }
          return query;
        },
        limit: limit,
      );

      return data.map((userData) => UserModel.fromMap(userData)).toList();
    } catch (e) {
      throw Exception('Failed to get users: $e');
    }
  }

  /// Creates or updates a user profile (upsert operation)
  Future<void> createOrUpdateUser(UserModel user) async {
    try {
      final exists = await userExists(user.id);
      if (exists) {
        await updateUser(user);
      } else {
        await createUser(user);
      }
    } catch (e) {
      throw Exception('Failed to create or update user: $e');
    }
  }

  /// Updates specific fields of a user profile
  Future<void> updateUserFields(
    String userId,
    Map<String, dynamic> fields,
  ) async {
    try {
      await _firestoreService.updateDocument(
        collection: _collectionName,
        documentId: userId,
        data: fields,
      );
    } catch (e) {
      throw Exception('Failed to update user fields: $e');
    }
  }

  /// Gets the current logged-in user
  Future<UserModel?> getCurrentUser() async {
    try {
      final currentUserId = _firestoreService.currentUserId;
      if (currentUserId == null) return null;

      return await getUser(currentUserId);
    } catch (e) {
      throw Exception('Failed to get current user: $e');
    }
  }

  /// Streams the current logged-in user
  Stream<UserModel?> streamCurrentUser() {
    try {
      final currentUserId = _firestoreService.currentUserId;
      if (currentUserId == null) {
        return Stream.value(null);
      }

      return streamUser(currentUserId);
    } catch (e) {
      throw Exception('Failed to stream current user: $e');
    }
  }
}
