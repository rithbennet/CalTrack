import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async'; // Add this import for Timer
import '../viewmodels/user_view_model.dart';
import '../viewmodels/food_log_view_model.dart';
import '../viewmodels/auth_view_model.dart';
import '../models/food_entry.dart';
import '../models/curated_food_item.dart';
import '../services/food_search_service.dart';
import 'components/search/search_bar_widget.dart';
import 'components/search/food_search_results.dart';
import 'components/search/calorie_goal_header.dart';
import 'components/search/search_filters.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FoodSearchService _searchService = FoodSearchService();

  List<CuratedFoodItem> _searchResults = [];
  bool _isLoading = false;
  String _selectedFilter = 'All';
  Timer? _debounceTimer; // Add debounce timer
  static const int _searchLimit = 15; // Add search result limit
  static const Duration _debounceDuration = Duration(
    milliseconds: 800,
  ); // Debounce delay

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel(); // Cancel timer when disposing
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    // Cancel previous timer if it exists
    _debounceTimer?.cancel();

    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isLoading = false;
      });
      return;
    }

    // Show loading immediately but don't search yet
    setState(() {
      _isLoading = true;
    });

    // Start new timer
    _debounceTimer = Timer(_debounceDuration, () async {
      if (!mounted) return;

      try {
        final results = await _searchService.searchFoods(
          query: query,
          filter: _selectedFilter,
          limit: _searchLimit, // Use the limit
        );

        if (mounted) {
          setState(() {
            _searchResults = results;
            _isLoading = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Search failed: $e')));
        }
      }
    });
  }

  void _onFilterChanged(String filter) {
    setState(() {
      _selectedFilter = filter;
    });

    // Cancel current timer and immediately search with new filter
    _debounceTimer?.cancel();
    if (_searchController.text.isNotEmpty) {
      _performSearchImmediately(_searchController.text);
    }
  }

  // Immediate search for filter changes (no debounce)
  Future<void> _performSearchImmediately(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final results = await _searchService.searchFoods(
        query: query,
        filter: _selectedFilter,
        limit: _searchLimit,
      );

      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Search failed: $e')));
      }
    }
  }

  void _addFoodToLog(CuratedFoodItem foodItem) async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final foodLogViewModel = Provider.of<FoodLogViewModel>(
      context,
      listen: false,
    );

    if (authViewModel.currentUser != null) {
      final foodEntry = FoodEntry(
        name: foodItem.name,
        servings: 1.0,
        servingUnit: foodItem.servingUnit,
        caloriesPerServing: foodItem.caloriesPerServing,
        protein: foodItem.protein,
        carbs: foodItem.carbs,
        fat: foodItem.fat,
        date: DateTime.now(),
      );

      await foodLogViewModel.addEntry(foodEntry);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${foodItem.name} added to your food log!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  void _showApiStatistics() {
    final stats = _searchService.getApiStatistics();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.analytics, color: Colors.blue),
                SizedBox(width: 8),
                Text('API Statistics'),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildStatRow('Total Requests', '${stats['totalRequests']}'),
                  _buildStatRow('Successful', '${stats['successfulRequests']}'),
                  _buildStatRow('Failed', '${stats['failedRequests']}'),
                  _buildStatRow(
                    'Rate Limited',
                    '${stats['rateLimitedRequests']}',
                  ),
                  _buildStatRow(
                    'Success Rate',
                    '${stats['successRate'].toStringAsFixed(1)}%',
                  ),
                  if (stats['lastRequestTime'] != null) ...[
                    const Divider(),
                    Text(
                      'Last Request: ${_formatTime(stats['lastRequestTime'])}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  _searchService.resetApiStatistics();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('API statistics reset')),
                  );
                },
                child: const Text('Reset'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Foods'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: _showApiStatistics,
            tooltip: 'API Statistics',
          ),
        ],
      ),
      body: Column(
        children: [
          // Calorie goal header
          Consumer<UserViewModel>(
            builder: (context, userViewModel, child) {
              return CalorieGoalHeader(
                dailyCalorieTarget:
                    userViewModel.userProfile?.effectiveDailyCalorieTarget ??
                    2000,
              );
            },
          ),

          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SearchBarWidget(
              controller: _searchController,
              onSearchChanged: _performSearch,
              hintText: 'Search for foods (e.g., "chicken breast", "apple")',
            ),
          ),

          // Search filters
          SearchFilters(
            selectedFilter: _selectedFilter,
            onFilterChanged: _onFilterChanged,
          ),

          // Results count indicator
          if (_searchResults.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(
                    'Showing ${_searchResults.length} result${_searchResults.length == 1 ? '' : 's'}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (_searchResults.length == _searchLimit) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: .1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Limited',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],

          // Search results
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _searchResults.isEmpty &&
                        _searchController.text.isNotEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No foods found for "${_searchController.text}"',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try different keywords or check your spelling',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                    : _searchResults.isEmpty
                    ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'Search for foods to add to your log',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Type at least 2 characters to start searching',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                    : FoodSearchResults(
                      searchResults: _searchResults,
                      onAddFood: _addFoodToLog,
                    ),
          ),
        ],
      ),
    );
  }
}
