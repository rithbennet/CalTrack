import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
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

  void _onFilterChanged(String filter) {
    setState(() {
      _selectedFilter = filter;
    });

    if (_searchController.text.isNotEmpty) {
      _performSearch(_searchController.text);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Foods'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Calorie goal header
          Consumer<UserViewModel>(
            builder: (context, userViewModel, child) {
              return CalorieGoalHeader(
                dailyCalorieTarget:
                    userViewModel.userProfile?.effectiveDailyCalorieTarget ??
                    2000, // Changed to use effectiveDailyCalorieTarget
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

          // Search results
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _searchResults.isEmpty &&
                        _searchController.text.isNotEmpty
                    ? const Center(
                      child: Text(
                        'No foods found. Try different keywords.',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
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
