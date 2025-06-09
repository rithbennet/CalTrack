import 'package:flutter/material.dart';
import '../../../models/food_item.dart';

class FoodHeaderWidget extends StatelessWidget {
  final FoodItem food;

  const FoodHeaderWidget({super.key, required this.food});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          food.name,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        if (food.barcode.isNotEmpty && food.barcode != 'N/A') ...[
          const SizedBox(height: 8),
          Text(
            'Barcode: ${food.barcode}',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ],
    );
  }
}
