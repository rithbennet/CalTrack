import 'dart:async';
import 'package:flutter/material.dart';
import '../models/food_entry.dart';
import '../models/nutritional_summary.dart'; // ADDED: Import the new model
import '../repositories/food_repository.dart';
import '../services/auth_service.dart';
import '../services/logger_service.dart';

class FoodLogViewModel extends ChangeNotifier {
  // --- EXISTING CODE (UNCHANGED) ---
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

  // --- NEW: PROPERTIES FOR NUTRITIONAL REPORTS ---
  DailyNutritionalSummary _todaySummary = DailyNutritionalSummary(
    date: DateTime.now(),
  );
  DailyNutritionalSummary get todaySummary => _todaySummary;

  List<DailyNutritionalSummary> _weeklySummary = [];
  List<DailyNutritionalSummary> get weeklySummary => _weeklySummary;
  // --- END NEW PROPERTIES ---

  void initializeForUser(String userId) {
    try {
      _logger.debug('Initializing food log for user: $userId');
      _streamSubscription?.cancel();
      _entriesStream = _foodRepository.getFoodEntriesStream(userId);

      _streamSubscription = _entriesStream!.listen(
        (data) => _handleData(data),
        onError: (error) => _handleError(error),
      );
    } catch (e) {
      _logger.error('Exception initializing food log', e);
      _entries = [];
      // ADDED: Also reset summaries on error
      _calculateSummaries();
      notifyListeners();
    }
  }

  // MODIFIED: This method now also triggers summary calculations
  void _handleData(List<FoodEntry> data) {
    _logger.debug('Received ${data.length} entries');
    _entries = data;
    // ADDED: Trigger summary calculations whenever data changes
    _calculateSummaries();
    notifyListeners();
  }

  // MODIFIED: This method now also resets summaries on error
  void _handleError(dynamic error) {
    _logger.error('Error in food entries stream', error);
    _entries = [];
    // ADDED: Also reset summaries on error
    _calculateSummaries();
    notifyListeners();
  }

  // --- NEW: METHODS FOR CALCULATING SUMMARIES ---

  /// Calculates daily and weekly summaries from the current list of entries.
  void _calculateSummaries() {
    final now = DateTime.now();

    // --- Calculate Today's Summary ---
    final todayEntries =
        _entries.where((entry) {
          // Gracefully handle nullable date property
          return entry.date != null && _isSameDay(entry.date!, now);
        }).toList();

    double totalCalories = 0, totalProtein = 0, totalCarbs = 0, totalFat = 0;
    for (var entry in todayEntries) {
      // Use the computed property for calories and multiply macros by servings
      totalCalories += entry.totalCalories;
      totalProtein += entry.protein * entry.servings;
      totalCarbs += entry.carbs * entry.servings;
      totalFat += entry.fat * entry.servings;
    }
    _todaySummary = DailyNutritionalSummary(
      date: now,
      totalCalories: totalCalories,
      totalProtein: totalProtein,
      totalCarbs: totalCarbs,
      totalFat: totalFat,
      foodEntries: todayEntries,
    );

    // --- Calculate Weekly Summary ---
    final weeklySummaries = <DailyNutritionalSummary>[];
    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: i));
      final dayEntries =
          _entries.where((entry) {
            return entry.date != null && _isSameDay(entry.date!, date);
          }).toList();

      double dayCalories = 0, dayProtein = 0, dayCarbs = 0, dayFat = 0;
      for (var entry in dayEntries) {
        dayCalories += entry.totalCalories;
        dayProtein += entry.protein * entry.servings;
        dayCarbs += entry.carbs * entry.servings;
        dayFat += entry.fat * entry.servings;
      }

      weeklySummaries.add(
        DailyNutritionalSummary(
          date: date,
          totalCalories: dayCalories,
          totalProtein: dayProtein,
          totalCarbs: dayCarbs,
          totalFat: dayFat,
          foodEntries: dayEntries,
        ),
      );
    }
    // Reverse the list so it's in chronological order (e.g., Mon, Tue, Wed...)
    _weeklySummary = weeklySummaries.reversed.toList();
  }

  /// Helper to compare dates without considering time.
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
  // --- END NEW METHODS ---

  // --- EXISTING CODE (UNCHANGED) ---
  Future<void> addEntry(FoodEntry entry) async {
    if (userId != null) {
      await _foodRepository.addFoodEntry(userId!, entry);
      // The stream listener will update _entries and summaries automatically
    }
  }

  Future<void> removeEntry(FoodEntry entry) async {
    if (userId != null && entry.id != null) {
      await _foodRepository.deleteFoodEntry(userId!, entry.id!);
      // The stream listener will update _entries and summaries automatically
      await fetchTodayCalories(userId!); // This existing call remains
    }
  }

  Future<void> updateEntry(FoodEntry entry) async {
    if (userId != null && entry.id != null) {
      await _foodRepository.updateFoodEntry(userId!, entry);
      await fetchTodayCalories(userId!); // This existing call remains
      // The stream listener will update _entries and summaries automatically
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
