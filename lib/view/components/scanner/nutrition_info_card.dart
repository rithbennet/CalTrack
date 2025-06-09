import 'package:flutter/material.dart';
import '../../../models/food_item.dart';

class NutritionInfoCard extends StatelessWidget {
  final FoodItem food;

  const NutritionInfoCard({super.key, required this.food});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nutritional Information (${food.servingSize})',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildNutrientRow(
              'Calories',
              '${food.calories.toStringAsFixed(1)} kcal',
            ),
            _buildNutrientRow(
              'Protein',
              '${food.protein.toStringAsFixed(1)} g',
            ),
            _buildNutrientRow(
              'Carbohydrates',
              '${food.carbohydrates.toStringAsFixed(1)} g',
            ),
            _buildNutrientRow(
              '  - Sugars',
              '${food.sugars.toStringAsFixed(1)} g',
            ),
            _buildNutrientRow('Fat', '${food.fat.toStringAsFixed(1)} g'),
            _buildNutrientRow(
              '  - Saturated Fat',
              '${food.saturatedFat.toStringAsFixed(1)} g',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutrientRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight:
                  label.startsWith('  ') ? FontWeight.normal : FontWeight.w500,
            ),
          ),
          Text(value, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
