import 'package:flutter/material.dart';
import '../models/food_entry.dart';

class FoodLogViewModel extends ChangeNotifier {
  final List<FoodEntry> _entries = [];

  List<FoodEntry> get entries => List.unmodifiable(_entries);

  void addEntry(FoodEntry entry) {
    _entries.add(entry);
    notifyListeners();
  }

  void removeEntry(FoodEntry entry) {
    _entries.remove(entry);
    notifyListeners();
  }
}
