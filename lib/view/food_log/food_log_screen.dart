import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/food_entry.dart';
import '../../viewmodels/food_log_view_model.dart';
import 'add_food_screen.dart';
import '../../theme/app_theme.dart';

class FoodLogScreen extends StatelessWidget {
  const FoodLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(title: const Text('Food Log')),
        body: Consumer<FoodLogViewModel>(
          builder: (context, viewModel, _) {
            final entries = viewModel.entries;
            if (entries.isEmpty) {
              return const Center(child: Text('No food entries yet.'));
            }
            return ListView.builder(
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final entry = entries[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(entry.name),
                    subtitle: Text('${entry.calories} kcal'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: AppTheme.primary),
                      onPressed: () => viewModel.removeEntry(entry),
                    ),
                  ),
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
              Provider.of<FoodLogViewModel>(context, listen: false).addEntry(result);
            }
          },
        ),
      );
  }
}
