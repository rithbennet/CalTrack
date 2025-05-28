import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/food_entry.dart';
import '../../viewmodels/food_log_view_model.dart'; // Update this import path
import 'add_food_screen.dart';
import '../../theme/app_theme.dart';

class FoodLogScreen extends StatelessWidget {
  const FoodLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<FoodLogViewModel>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Food Log')),
      body: StreamBuilder<List<FoodEntry>>(
        stream: viewModel.entriesStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final entries = snapshot.data ?? [];

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
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${entry.calories} kcal'),
                      if (entry.notes != null && entry.notes!.isNotEmpty)
                        Text(
                          entry.notes!,
                          style: const TextStyle(fontSize: 12),
                        ),
                      if (entry.date != null)
                        Text(
                          '${entry.date!.day}/${entry.date!.month}/${entry.date!.year}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                    ],
                  ),
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
            viewModel.addEntry(result);
          }
        },
      ),
    );
  }
}
