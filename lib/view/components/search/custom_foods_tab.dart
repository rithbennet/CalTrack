import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart'; // <-- Add this import
import '../../../models/curated_food_item.dart';
import '../../../services/custom_food_service.dart';
import '../../../viewmodels/auth_view_model.dart';
import '../../../viewmodels/food_log_view_model.dart';
import '../../../models/food_entry.dart';
import 'search_filters.dart';
import 'search_bar_widget.dart';
import '../shared/compact_food_card.dart';
import '../../search/create_custom_food_screen.dart';

class CustomFoodsTab extends StatefulWidget {
  const CustomFoodsTab({super.key});

  @override
  State<CustomFoodsTab> createState() => _CustomFoodsTabState();
}

class _CustomFoodsTabState extends State<CustomFoodsTab> {
  final TextEditingController _searchController = TextEditingController();
  final CustomFoodService _customFoodService = CustomFoodService();
  final Logger _logger = Logger(); // <-- Add logger instance
  String _selectedFilter = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<CuratedFoodItem> _filterFoods(
    List<CuratedFoodItem> foods,
    String query,
  ) {
    final lowerQuery = query.toLowerCase();

    return foods.where((food) {
      bool matchesQuery =
          query.isEmpty ||
          food.name.toLowerCase().contains(lowerQuery) ||
          food.brand.toLowerCase().contains(lowerQuery) ||
          food.tags.any((tag) => tag.toLowerCase().contains(lowerQuery));

      bool matchesFilter =
          _selectedFilter == 'All' ||
          food.category.toLowerCase() == _selectedFilter.toLowerCase() ||
          food.category.toLowerCase() ==
              _selectedFilter.toLowerCase().replaceAll('s', '');

      return matchesQuery && matchesFilter;
    }).toList();
  }

  void _onSearchChanged(String query) {
    setState(() {});
  }

  void _onFilterChanged(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
  }

  void _addFoodToLog(CuratedFoodItem foodItem) async {
    _logger.i('Adding food to log: ${foodItem.name}, ID: ${foodItem.id}');

    try {
      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
      final foodLogViewModel = Provider.of<FoodLogViewModel>(
        context,
        listen: false,
      );

      if (authViewModel.currentUser == null) {
        _logger.e('Error: No authenticated user');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please log in to add foods'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Validate required fields
      if (foodItem.name.isEmpty) {
        _logger.e('Error: Food name is empty');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error: Food name is missing'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      if (foodItem.servingUnit.isEmpty) {
        _logger.e('Error: Serving unit is empty');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error: Serving unit is missing'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

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

      _logger.d('Created food entry: ${foodEntry.name}');

      await foodLogViewModel.addEntry(foodEntry);

      _logger.i('Successfully added food entry to log');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${foodItem.name} added to your food log!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e, stackTrace) {
      _logger.e(
        'Error adding food to log: $e',
        error: e,
        stackTrace: stackTrace,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding food: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _createNewCustomFood() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreateCustomFoodScreen()),
    );

    if (result is CuratedFoodItem && mounted) {
      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
      if (authViewModel.currentUser != null) {
        await _customFoodService.addCustomFood(
          authViewModel.currentUser!.id,
          result,
        );

        _logger.i('Custom food added: ${result.name}');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${result.name} added to your custom foods!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    }
  }

  void _editCustomFood(CuratedFoodItem food) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateCustomFoodScreen(existingFood: food),
      ),
    );

    if (result is CuratedFoodItem && mounted) {
      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
      if (authViewModel.currentUser != null) {
        await _customFoodService.updateCustomFood(
          authViewModel.currentUser!.id,
          result,
        );

        _logger.i('Custom food updated: ${result.name}');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${result.name} updated!'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    }
  }

  void _deleteCustomFood(CuratedFoodItem food) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Custom Food'),
            content: Text('Are you sure you want to delete "${food.name}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (confirmed == true && mounted) {
      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
      if (authViewModel.currentUser != null) {
        await _customFoodService.deleteCustomFood(
          authViewModel.currentUser!.id,
          food.id,
        );

        _logger.i('Custom food deleted: ${food.name}');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${food.name} deleted'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final authViewModel = Provider.of<AuthViewModel>(context);
    final userId = authViewModel.currentUser?.id;

    if (userId == null) {
      return const Center(child: Text('Please log in to view custom foods'));
    }

    return Column(
      children: [
        // Create New Food Button
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _createNewCustomFood,
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Create New Food'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            ),
          ),
        ),

        // Search bar using existing component
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SearchBarWidget(
            controller: _searchController,
            onSearchChanged: _onSearchChanged,
            hintText: 'Search your custom foods...',
          ),
        ),

        // Filters
        SearchFilters(
          selectedFilter: _selectedFilter,
          onFilterChanged: _onFilterChanged,
        ),

        // Custom foods list with StreamBuilder
        Expanded(
          child: StreamBuilder<List<CuratedFoodItem>>(
            stream: _customFoodService.getCustomFoodsStream(userId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                _logger.e('Custom foods error: ${snapshot.error}');
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading custom foods',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        snapshot.error.toString(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.red.shade600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => setState(() {}),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              final allFoods = snapshot.data ?? [];
              final filteredFoods = _filterFoods(
                allFoods,
                _searchController.text,
              );

              if (filteredFoods.isEmpty) {
                if (allFoods.isEmpty) {
                  // No custom foods at all
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer.withValues(
                              alpha: 0.3,
                            ),
                            borderRadius: BorderRadius.circular(32),
                          ),
                          child: Icon(
                            Icons.restaurant_menu,
                            size: 64,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'No custom foods yet',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Text(
                            'Create your first custom food item to get started with your personal recipe collection',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant.withValues(
                                alpha: 0.8,
                              ),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton.icon(
                          onPressed: _createNewCustomFood,
                          icon: const Icon(Icons.add_circle_outline),
                          label: const Text('Create Your First Food'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  // Has foods but none match search/filter
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(32),
                          ),
                          child: Icon(
                            Icons.search_off,
                            size: 64,
                            color: Colors.orange.shade600,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'No foods found',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Text(
                            'Try different keywords or create a new custom food that matches your search',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant.withValues(
                                alpha: 0.8,
                              ),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            OutlinedButton.icon(
                              onPressed: () {
                                _searchController.clear();
                                _onSearchChanged('');
                              },
                              icon: const Icon(Icons.clear),
                              label: const Text('Clear Search'),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton.icon(
                              onPressed: _createNewCustomFood,
                              icon: const Icon(Icons.add),
                              label: const Text('Create Food'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorScheme.primary,
                                foregroundColor: colorScheme.onPrimary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }
              }

              // Show foods in grid
              return Column(
                children: [
                  // Results count
                  Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 16,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${filteredFoods.length} custom food${filteredFoods.length == 1 ? '' : 's'}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (_searchController.text.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'filtered',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.primary,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Grid view
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.75,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                      itemCount: filteredFoods.length,
                      itemBuilder: (context, index) {
                        final food = filteredFoods[index];
                        return CompactFoodCard(
                          food: food,
                          onTap: () => _addFoodToLog(food),
                          showCustomBadge: true,
                          actions: PopupMenuButton<String>(
                            padding: EdgeInsets.zero,
                            iconSize: 18,
                            onSelected: (value) {
                              switch (value) {
                                case 'edit':
                                  _editCustomFood(food);
                                  break;
                                case 'delete':
                                  _deleteCustomFood(food);
                                  break;
                              }
                            },
                            itemBuilder:
                                (context) => [
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit, size: 16),
                                        SizedBox(width: 8),
                                        Text('Edit'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.delete,
                                          size: 16,
                                          color: Colors.red,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Delete',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
