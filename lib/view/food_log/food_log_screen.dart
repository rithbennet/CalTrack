import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import '../../models/food_entry.dart';
import '../../viewmodels/food_log_view_model.dart';
import '../../viewmodels/auth_view_model.dart';
import '../../services/favorite_food_service.dart';
import 'add_food_screen.dart';
import 'edit_food_entry_screen.dart';
import '../../theme/app_theme.dart';
import '../../services/logger_service.dart';

class FoodLogScreen extends StatefulWidget {
  const FoodLogScreen({super.key});

  @override
  State<FoodLogScreen> createState() => _FoodLogScreenState();
}

class _FoodLogScreenState extends State<FoodLogScreen> {
  bool _timedOut = false;
  final LoggerService _logger = LoggerService();

  @override
  void initState() {
    super.initState();
    // Remove Firebase initialization as it's already initialized
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final foodLogViewModel = Provider.of<FoodLogViewModel>(
      context,
      listen: false,
    );

    if (authViewModel.currentUser != null) {
      foodLogViewModel.initializeForUser(authViewModel.currentUser!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<FoodLogViewModel>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Food Log')),
      body: StreamBuilder<List<FoodEntry>>(
        stream: viewModel.entriesStream,
        builder: (context, snapshot) {
          // Debug print
          _logger.debug(
            'Stream state: ${snapshot.connectionState}, hasData: ${snapshot.hasData}, error: ${snapshot.error}',
          );

          // Handle all stream states
          if (snapshot.connectionState == ConnectionState.waiting &&
              !_timedOut) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // Check if we need to show the timeout UI
          if (_timedOut &&
              (snapshot.connectionState == ConnectionState.waiting ||
                  snapshot.data == null)) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Taking longer than expected...'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Refresh the screen
                      final authViewModel = Provider.of<AuthViewModel>(
                        context,
                        listen: false,
                      );
                      if (authViewModel.currentUser != null) {
                        // Initialize the food log for the current user
                        viewModel.initializeForUser(
                          authViewModel.currentUser!.id,
                        );
                      }
                      setState(() {
                        _timedOut = false;
                      });
                      // Reset timeout
                      Future.delayed(const Duration(seconds: 5), () {
                        if (mounted) {
                          setState(() {
                            _timedOut = true;
                          });
                        }
                      });
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // Even if we don't have data, we should stop loading
          final entries = snapshot.data ?? [];

          if (entries.isEmpty) {
            return const Center(child: Text('No food entries yet.'));
          }

          return ListView.builder(
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];
              return _FoodEntryCard(
                entry: entry,
                onEdit: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => EditFoodLogEntryScreen(existingEntry: entry),
                    ),
                  );
                  if (result is FoodEntry) {
                    viewModel.updateEntry(result);
                  }
                },
                onDelete: () => viewModel.removeEntry(entry),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primary,
        child: const Icon(Icons.add),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddFoodScreen()),
          );
          if (result is FoodEntry) {
            viewModel.addEntry(result);
          }
        },
      ),
    );
  }
}

class _FoodEntryCard extends StatefulWidget {
  final FoodEntry entry;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _FoodEntryCard({
    required this.entry,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<_FoodEntryCard> createState() => _FoodEntryCardState();
}

class _FoodEntryCardState extends State<_FoodEntryCard> {
  final FavoriteFoodService _favoriteFoodService = FavoriteFoodService();
  bool _isFavorite = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkIfFavorite();
  }

  Future<void> _checkIfFavorite() async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    if (authViewModel.currentUser != null) {
      final isFav = await _favoriteFoodService.isFavorite(
        authViewModel.currentUser!.id,
        widget.entry.name,
        '', // Food entries don't have brands
      );
      if (mounted) {
        setState(() {
          _isFavorite = isFav;
        });
      }
    }
  }

  Future<void> _toggleFavorite() async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    if (authViewModel.currentUser == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      if (_isFavorite) {
        // Remove from favorites
        final favoriteId = await _favoriteFoodService.getFavoriteId(
          authViewModel.currentUser!.id,
          widget.entry.name,
          '',
        );
        if (favoriteId != null) {
          await _favoriteFoodService.removeFromFavorites(
            authViewModel.currentUser!.id,
            favoriteId,
          );
          if (mounted) {
            setState(() {
              _isFavorite = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${widget.entry.name} removed from favorites'),
                backgroundColor: Colors.orange,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        }
      } else {
        // Add to favorites
        await _favoriteFoodService.addFoodEntryToFavorites(
          authViewModel.currentUser!.id,
          widget.entry,
        );
        if (mounted) {
          setState(() {
            _isFavorite = true;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${widget.entry.name} added to favorites!'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      Logger().e('Error toggling favorite: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(widget.entry.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.entry.servings} ${widget.entry.servingUnit} • ${widget.entry.totalCalories} kcal',
            ),
            Text(
              'P: ${widget.entry.protein.toStringAsFixed(1)}g • C: ${widget.entry.carbs.toStringAsFixed(1)}g • F: ${widget.entry.fat.toStringAsFixed(1)}g',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            if (widget.entry.notes != null && widget.entry.notes!.isNotEmpty)
              Text(widget.entry.notes!, style: const TextStyle(fontSize: 12)),
            if (widget.entry.date != null)
              Text(
                '${widget.entry.date!.day}/${widget.entry.date!.month}/${widget.entry.date!.year}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Favorite Star Button
            _isLoading
                ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                : IconButton(
                  icon: Icon(
                    _isFavorite ? Icons.star : Icons.star_border,
                    color: _isFavorite ? Colors.amber : Colors.grey,
                  ),
                  onPressed: _toggleFavorite,
                  tooltip:
                      _isFavorite
                          ? 'Remove from favorites'
                          : 'Add to favorites',
                ),
            IconButton(
              icon: const Icon(Icons.edit, color: AppTheme.primary),
              onPressed: widget.onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: AppTheme.primary),
              onPressed: widget.onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
