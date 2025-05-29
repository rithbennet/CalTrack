import 'dart:async';
import 'package:flutter/material.dart';
import '../models/food_entry.dart';
import '../repositories/food_repository.dart';
import '../services/auth_service.dart';
import '../services/logger_service.dart';

class FoodLogViewModel extends ChangeNotifier {
  final FoodRepository _foodRepository = FoodRepository();
  final AuthService _authService = AuthService();
  final LoggerService _logger = LoggerService();

  List<FoodEntry> _entries = [];
  List<FoodEntry> get entries => _entries;

  Stream<List<FoodEntry>>? _entriesStream;
  Stream<List<FoodEntry>>? get entriesStream => _entriesStream;

  StreamSubscription<List<FoodEntry>>? _streamSubscription;

  String? get userId => _authService.currentUser?.uid;

  int _todayCalories = 0;
  int get todayCalories => _todayCalories;

  // This method allows explicit initialization with a user ID
  void initializeForUser(String userId) {
    try {
      _logger.debug('Initializing food log for user: $userId');

      // Cancel any existing subscription to prevent memory leaks
      _streamSubscription?.cancel();

      _entriesStream = _foodRepository.getFoodEntriesStream(userId);

      // Add proper error handling to the stream listener
      _streamSubscription = _entriesStream!.listen(
        (data) => _handleData(data),
        onError: (error) => _handleError(error),
      );
    } catch (e) {
      _logger.error('Exception initializing food log', e);
      _entries = [];
      notifyListeners();
    }
  }

  // Add these helper methods to handle the stream data and errors
  void _handleData(List<FoodEntry> data) {
    _logger.debug('Received ${data.length} entries');
    _entries = data;
    notifyListeners();
  }

  void _handleError(dynamic error) {
    _logger.error('Error in food entries stream', error);
    _entries = [];
    notifyListeners();
  }

  Future<void> addEntry(FoodEntry entry) async {
    if (userId != null) {
      await _foodRepository.addFoodEntry(userId!, entry);
      // The stream listener will update _entries automatically
    }
  }

  Future<void> removeEntry(FoodEntry entry) async {
    if (userId != null && entry.id != null) {
      await _foodRepository.deleteFoodEntry(userId!, entry.id!);
      // The stream listener will update _entries automatically
      await fetchTodayCalories(
        userId!,
      ); // Refresh today's calories after deletion
    }
  }

  Future<void> fetchTodayCalories(String userId) async {
    _todayCalories = await _foodRepository.getTodayCalories(userId);
    notifyListeners();
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }
}
