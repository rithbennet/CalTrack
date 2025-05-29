import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:caltrack/viewmodels/food_log_view_model.dart';
import 'package:caltrack/viewmodels/auth_view_model.dart';
import 'package:caltrack/models/food_entry.dart';
import '../../food_log/add_food_screen.dart';
import '../../food_log/food_log_screen.dart';
import 'recent_food_entries_carousel.dart';
import 'section_header.dart';

class FoodTrackingSection extends StatelessWidget {
  const FoodTrackingSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        const SectionHeader(title: 'Food Tracking'),
        const SizedBox(height: 16),

        // Add Food button
        TextButton.icon(
          onPressed: () async {
            // Capture provider references before async operation
            final foodLogViewModel = Provider.of<FoodLogViewModel>(
              context,
              listen: false,
            );
            final authViewModel = Provider.of<AuthViewModel>(
              context,
              listen: false,
            );

            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddFoodScreen()),
            );

            if (result is FoodEntry && context.mounted) {
              // Add the entry to the food log
              foodLogViewModel.addEntry(result);
              if (authViewModel.currentUser != null) {
                await foodLogViewModel.fetchTodayCalories(
                  authViewModel.currentUser!.id,
                ); // Refresh calories
              }
            }
          },
          icon: const Icon(Icons.add, color: Colors.deepOrange),
          label: const Text(
            'Add Food',
            style: TextStyle(color: Colors.deepOrange),
          ),
        ),

        const SizedBox(height: 16),

        // Recent Food Entries Carousel
        const RecentFoodEntriesCarousel(),

        // View all entries button
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FoodLogScreen()),
              );
            },
            child: const Text(
              'View all entries →',
              style: TextStyle(color: Colors.deepOrange),
            ),
          ),
        ),
      ],
    );
  }
}
