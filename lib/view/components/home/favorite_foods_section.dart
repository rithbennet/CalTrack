import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import '../../../models/favorite_food.dart';
import '../../../services/favorite_food_service.dart';
import '../../../viewmodels/auth_view_model.dart';
import '../../../viewmodels/food_log_view_model.dart';
import '../../../models/food_entry.dart';
import '../../search_screen.dart';

class FavoriteFoodsSection extends StatelessWidget {
  const FavoriteFoodsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final authViewModel = Provider.of<AuthViewModel>(context);
    final userId = authViewModel.currentUser?.id;

    if (userId == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.star, color: Colors.amber, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Favorite Foods',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: () {
                // Navigate to search screen to see more favorites
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SearchScreen()),
                );
              },
              child: Text(
                'View All',
                style: TextStyle(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Favorite Foods List
        StreamBuilder<List<FavoriteFood>>(
          stream: FavoriteFoodService().getFavoriteFoodsStream(userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return SizedBox(
                height: 120,
                child: const Center(child: CircularProgressIndicator()),
              );
            }

            if (snapshot.hasError) {
              return Container(
                height: 120,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.red.shade400,
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Error loading favorites',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.red.shade400,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            final favorites = snapshot.data ?? [];

            if (favorites.isEmpty) {
              return Container(
                height: 120,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.outline.withValues(alpha: 0.3),
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.star_border,
                        color: Colors.amber.withValues(alpha: 0.7),
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No favorite foods yet',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Add foods to favorites from your food log',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white54,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }

            // Show horizontal scrollable list of favorite foods (limit to recent 10)
            final recentFavorites = favorites.take(10).toList();

            return SizedBox(
              height: 160,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: recentFavorites.length,
                itemBuilder: (context, index) {
                  final favorite = recentFavorites[index];

                  return Container(
                    width: 140,
                    margin: const EdgeInsets.only(right: 12),
                    child: _FavoriteFoodCard(
                      favorite: favorite,
                      onTap: () => _addFavoriteToLog(context, favorite),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  void _addFavoriteToLog(BuildContext context, FavoriteFood favorite) async {
    try {
      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
      final foodLogViewModel = Provider.of<FoodLogViewModel>(
        context,
        listen: false,
      );

      if (authViewModel.currentUser != null) {
        final foodEntry = FoodEntry(
          name: favorite.name,
          servings: 1.0,
          servingUnit: favorite.servingUnit,
          caloriesPerServing: favorite.caloriesPerServing,
          protein: favorite.protein,
          carbs: favorite.carbs,
          fat: favorite.fat,
          date: DateTime.now(),
        );

        await foodLogViewModel.addEntry(foodEntry);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${favorite.name} added to your food log!'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      Logger().e('Error adding favorite to log: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding ${favorite.name}: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}

class _FavoriteFoodCard extends StatelessWidget {
  final FavoriteFood favorite;
  final VoidCallback onTap;

  const _FavoriteFoodCard({required this.favorite, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.1),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with star icon
              Row(
                children: [
                  Icon(Icons.star, color: Colors.amber, size: 16),
                  const Spacer(),
                  Text(
                    '${favorite.caloriesPerServing} cal',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Food name
              Expanded(
                child: Text(
                  favorite.name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              const SizedBox(height: 8),

              // Macros row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _MacroText('P: ${favorite.protein.toInt()}g', Colors.blue),
                  _MacroText('C: ${favorite.carbs.toInt()}g', Colors.orange),
                  _MacroText('F: ${favorite.fat.toInt()}g', Colors.red),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MacroText extends StatelessWidget {
  final String text;
  final Color color;

  const _MacroText(this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w600),
    );
  }
}
