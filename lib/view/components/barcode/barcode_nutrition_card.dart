import 'package:flutter/material.dart';
import '../../../models/food_item.dart';

class BarcodeNutritionCard extends StatelessWidget {
  final FoodItem food;

  const BarcodeNutritionCard({super.key, required this.food});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 2,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nutritional Information (${food.servingSize})',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            _buildNutrientRow(
              'Calories',
              '${food.calories.toStringAsFixed(1)} kcal',
              context,
            ),
            _buildNutrientRow(
              'Protein',
              '${food.protein.toStringAsFixed(1)} g',
              context,
            ),
            _buildNutrientRow(
              'Carbohydrates',
              '${food.carbohydrates.toStringAsFixed(1)} g',
              context,
            ),
            _buildNutrientRow(
              '  - Sugars',
              '${food.sugars.toStringAsFixed(1)} g',
              context,
            ),
            _buildNutrientRow(
              'Fat',
              '${food.fat.toStringAsFixed(1)} g',
              context,
            ),
            _buildNutrientRow(
              '  - Saturated Fat',
              '${food.saturatedFat.toStringAsFixed(1)} g',
              context,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutrientRow(String label, String value, BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight:
                  label.startsWith('  ') ? FontWeight.normal : FontWeight.w500,
              color: colorScheme.onSurface,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
