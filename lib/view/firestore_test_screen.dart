import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:caltrack/services/firestore_service.dart';

class FirestoreTestScreen extends StatefulWidget {
  const FirestoreTestScreen({super.key});

  @override
  State<FirestoreTestScreen> createState() => _FirestoreTestScreenState();
}

class _FirestoreTestScreenState extends State<FirestoreTestScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  bool _isLoading = false;
  String _statusMessage = '';
  List<Map<String, dynamic>> _calorieEntries = [];

  @override
  void initState() {
    super.initState();
    _testConnection();
  }

  Future<void> _testConnection() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Testing Firestore connection...';
    });

    try {
      bool connectionSuccess = await _firestoreService.testConnection();

      if (connectionSuccess) {
        setState(() {
          _statusMessage = '✅ Firestore connection successful!';
        });

        // Test user profile operations
        await _testUserProfileOperations();

        // Test calorie entry operations
        await _testCalorieEntryOperations();
      } else {
        setState(() {
          _statusMessage = '❌ Firestore connection failed!';
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = '❌ Error testing connection: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testUserProfileOperations() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    try {
      // Create/update user profile
      await _firestoreService.createUserProfile(
        userId: currentUser.uid,
        email: currentUser.email!,
        displayName: currentUser.displayName,
        photoURL: currentUser.photoURL,
      );

      // Get user profile
      Map<String, dynamic>? profile = await _firestoreService.getUserProfile(
        currentUser.uid,
      );

      setState(() {
        _statusMessage += '\n✅ User profile operations successful!';
        if (profile != null) {
          _statusMessage += '\n📄 Profile: ${profile['email']}';
        }
      });
    } catch (e) {
      setState(() {
        _statusMessage += '\n❌ User profile operations failed: $e';
      });
    }
  }

  Future<void> _testCalorieEntryOperations() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    try {
      // Add a test calorie entry
      String? entryId = await _firestoreService.addCalorieEntry(
        userId: currentUser.uid,
        foodName: 'Test Food',
        calories: 250.0,
        date: DateTime.now(),
        notes: 'Test entry from Firestore test',
      );

      if (entryId != null) {
        setState(() {
          _statusMessage += '\n✅ Calorie entry added successfully!';
        });

        // Get calorie entries for today
        List<Map<String, dynamic>> entries = await _firestoreService
            .getCalorieEntriesForDate(currentUser.uid, DateTime.now());

        setState(() {
          _calorieEntries = entries;
          _statusMessage +=
              '\n📊 Found ${entries.length} calorie entries for today';
        });

        // Calculate total calories
        double totalCalories = await _firestoreService.getTotalCaloriesForDate(
          currentUser.uid,
          DateTime.now(),
        );

        setState(() {
          _statusMessage +=
              '\n🔥 Total calories today: ${totalCalories.toStringAsFixed(1)}';
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage += '\n❌ Calorie entry operations failed: $e';
      });
    }
  }

  Future<void> _addSampleEntry() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      String? entryId = await _firestoreService.addCalorieEntry(
        userId: currentUser.uid,
        foodName: 'Sample Food ${DateTime.now().millisecondsSinceEpoch}',
        calories:
            (100 + (DateTime.now().millisecondsSinceEpoch % 400)).toDouble(),
        date: DateTime.now(),
        notes: 'Sample entry added manually',
      );

      if (entryId != null) {
        // Refresh the entries list
        List<Map<String, dynamic>> entries = await _firestoreService
            .getCalorieEntriesForDate(currentUser.uid, DateTime.now());

        setState(() {
          _calorieEntries = entries;
          _statusMessage =
              _statusMessage.split('\n📊')[0] +
              '\n📊 Found ${entries.length} calorie entries for today';
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error adding entry: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteEntry(String entryId) async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      bool success = await _firestoreService.deleteCalorieEntry(
        currentUser.uid,
        entryId,
      );

      if (success) {
        // Refresh the entries list
        List<Map<String, dynamic>> entries = await _firestoreService
            .getCalorieEntriesForDate(currentUser.uid, DateTime.now());

        setState(() {
          _calorieEntries = entries;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Entry deleted successfully')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error deleting entry: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firestore Test'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Connection Status',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    if (_isLoading)
                      const Row(
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 8),
                          Text('Testing...'),
                        ],
                      )
                    else
                      Text(
                        _statusMessage,
                        style: const TextStyle(fontFamily: 'monospace'),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _isLoading ? null : _testConnection,
                  child: const Text('Test Connection'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isLoading ? null : _addSampleEntry,
                  child: const Text('Add Sample Entry'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Calorie Entries Today (${_calorieEntries.length})',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Expanded(
              child:
                  _calorieEntries.isEmpty
                      ? const Center(
                        child: Text('No calorie entries for today'),
                      )
                      : ListView.builder(
                        itemCount: _calorieEntries.length,
                        itemBuilder: (context, index) {
                          final entry = _calorieEntries[index];
                          return Card(
                            child: ListTile(
                              title: Text(entry['foodName'] ?? 'Unknown Food'),
                              subtitle: Text(
                                'Calories: ${entry['calories']?.toStringAsFixed(1) ?? '0'}\n'
                                'Notes: ${entry['notes'] ?? 'No notes'}',
                              ),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => _deleteEntry(entry['id']),
                              ),
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
