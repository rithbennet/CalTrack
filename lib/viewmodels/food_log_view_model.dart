import 'package:flutter/material.dart';
import '../models/food_entry.dart';
import '../repositories/food_repository.dart';
import '../services/auth_service.dart';

class FoodLogViewModel extends ChangeNotifier {
  final FoodRepository _foodRepository = FoodRepository();
  final AuthService _authService = AuthService();

  List<FoodEntry> _entries = [];
  List<FoodEntry> get entries => _entries;

  Stream<List<FoodEntry>>? _entriesStream;
  Stream<List<FoodEntry>>? get entriesStream => _entriesStream;

  String? get userId => _authService.currentUser?.uid;

  FoodLogViewModel() {
    _initEntriesStream();
  }

  void _initEntriesStream() {
    if (userId != null) {
      _entriesStream = _foodRepository.getFoodEntriesStream(userId!);
      notifyListeners();
    }
  }

  Future<void> addEntry(FoodEntry entry) async {
    if (userId != null) {
      await _foodRepository.addFoodEntry(userId!, entry);
      // The stream will update automatically
    }
  }

  Future<void> removeEntry(FoodEntry entry) async {
    if (userId != null && entry.id != null) {
      await _foodRepository.deleteFoodEntry(userId!, entry.id!);
      // The stream will update automatically
    }
  }
}
