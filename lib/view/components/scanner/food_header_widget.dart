import 'package:flutter/material.dart';
import '../../../models/food_item.dart';

class FoodHeaderWidget extends StatelessWidget {
  final FoodItem food;

  const FoodHeaderWidget({super.key, required this.food});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          food.name,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        if (food.barcode.isNotEmpty && food.barcode != 'N/A') ...[
          const SizedBox(height: 8),
          Text(
            'Barcode: ${food.barcode}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ],
    );
  }
}
