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

  // GENERIC CRUD OPERATIONS

  /// Creates a document in the specified collection
  Future<void> createDocument({
    required String collection,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    try {
      data['createdAt'] = FieldValue.serverTimestamp();
      data['updatedAt'] = FieldValue.serverTimestamp();

      await _db.collection(collection).doc(documentId).set(data);
    } catch (e) {
      print('Error creating document in $collection: $e');
      rethrow;
    }
  }

  /// Gets a document from the specified collection
  Future<Map<String, dynamic>?> getDocument({
    required String collection,
    required String documentId,
  }) async {
    try {
      DocumentSnapshot doc =
          await _db.collection(collection).doc(documentId).get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }
      return null;
    } catch (e) {
      print('Error getting document from $collection: $e');
      rethrow;
    }
  }

  /// Updates a document in the specified collection
  Future<void> updateDocument({
    required String collection,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    try {
      data['updatedAt'] = FieldValue.serverTimestamp();
      await _db.collection(collection).doc(documentId).update(data);
    } catch (e) {
      print('Error updating document in $collection: $e');
      rethrow;
    }
  }

  /// Deletes a document from the specified collection
  Future<void> deleteDocument({
    required String collection,
    required String documentId,
  }) async {
    try {
      await _db.collection(collection).doc(documentId).delete();
    } catch (e) {
      print('Error deleting document from $collection: $e');
      rethrow;
    }
  }

  /// Checks if a document exists in the specified collection
  Future<bool> documentExists({
    required String collection,
    required String documentId,
  }) async {
    try {
      DocumentSnapshot doc =
          await _db.collection(collection).doc(documentId).get();
      return doc.exists;
    } catch (e) {
      print('Error checking document existence in $collection: $e');
      return false;
    }
  }

  /// Streams a document for real-time updates
  Stream<Map<String, dynamic>?> streamDocument({
    required String collection,
    required String documentId,
  }) {
    return _db.collection(collection).doc(documentId).snapshots().map((doc) {
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }
      return null;
    });
  }

  /// Gets multiple documents from a collection with optional query
  Future<List<Map<String, dynamic>>> getDocuments({
    required String collection,
    Query Function(Query query)? queryBuilder,
    int? limit,
  }) async {
    try {
      Query query = _db.collection(collection);

      if (queryBuilder != null) {
        query = queryBuilder(query);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      QuerySnapshot snapshot = await query.get();

      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error getting documents from $collection: $e');
      rethrow;
    }
  }

  /// Streams multiple documents for real-time updates
  Stream<List<Map<String, dynamic>>> streamDocuments({
    required String collection,
    Query Function(Query query)? queryBuilder,
    int? limit,
  }) {
    try {
      Query query = _db.collection(collection);

      if (queryBuilder != null) {
        query = queryBuilder(query);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      return query.snapshots().map((snapshot) {
        return snapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          return data;
        }).toList();
      });
    } catch (e) {
      print('Error streaming documents from $collection: $e');
      rethrow;
    }
  }

  /// Creates a document with auto-generated ID
  Future<String> createDocumentWithAutoId({
    required String collection,
    required Map<String, dynamic> data,
  }) async {
    try {
      data['createdAt'] = FieldValue.serverTimestamp();
      data['updatedAt'] = FieldValue.serverTimestamp();

      DocumentReference docRef = await _db.collection(collection).add(data);
      return docRef.id;
    } catch (e) {
      print('Error creating document with auto ID in $collection: $e');
      rethrow;
    }
  }

  /// Batch operations for multiple documents
  Future<void> batchWrite(List<Map<String, dynamic>> operations) async {
    try {
      WriteBatch batch = _db.batch();

      for (var operation in operations) {
        String type = operation['type']; // 'create', 'update', 'delete'
        String collection = operation['collection'];
        String documentId = operation['documentId'];

        DocumentReference docRef = _db.collection(collection).doc(documentId);

        switch (type) {
          case 'create':
            Map<String, dynamic> data = operation['data'];
            data['createdAt'] = FieldValue.serverTimestamp();
            data['updatedAt'] = FieldValue.serverTimestamp();
            batch.set(docRef, data);
            break;
          case 'update':
            Map<String, dynamic> data = operation['data'];
            data['updatedAt'] = FieldValue.serverTimestamp();
            batch.update(docRef, data);
            break;
          case 'delete':
            batch.delete(docRef);
            break;
        }
      }

      await batch.commit();
    } catch (e) {
      print('Error performing batch operations: $e');
      rethrow;
    }
  }
}
