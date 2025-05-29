import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:caltrack/viewmodels/food_log_view_model.dart';
import 'package:caltrack/services/logger_service.dart';
import 'food_entry_card.dart';

class RecentFoodEntriesCarousel extends StatelessWidget {
  const RecentFoodEntriesCarousel({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FoodLogViewModel>(
      builder: (context, foodLogViewModel, child) {
        LoggerService().debug(
          "Building carousel: ${foodLogViewModel.entries.length} entries",
        );

        final entries = foodLogViewModel.entries;

        if (entries.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'No recent entries. Add your first meal!',
              style: TextStyle(color: Colors.grey[400]),
            ),
          );
        }

        return SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: entries.length > 5 ? 5 : entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];
              return FoodEntryCard(entry: entry);
            },
          ),
        );
      },
    );
  }
}
