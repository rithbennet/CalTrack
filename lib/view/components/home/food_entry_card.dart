import 'package:flutter/material.dart';
import 'package:caltrack/models/food_entry.dart';
import '../../food_log/edit_food_entry_screen.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/food_log_view_model.dart';

class FoodEntryCard extends StatelessWidget {
  final FoodEntry entry;

  const FoodEntryCard({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EditFoodLogEntryScreen(existingEntry: entry),
          ),
        );
        if (result is FoodEntry && context.mounted) {
          final foodLogViewModel = Provider.of<FoodLogViewModel>(
            context,
            listen: false,
          );
          foodLogViewModel.updateEntry(result);
        }
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.grey[850],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.deepOrange.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                entry.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${entry.servings} ${entry.servingUnit}',
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                  Text(
                    '${entry.totalCalories} kcal',
                    style: const TextStyle(
                      color: Colors.deepOrange,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              if (entry.date != null)
                Text(
                  '${entry.date!.day}/${entry.date!.month}',
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
