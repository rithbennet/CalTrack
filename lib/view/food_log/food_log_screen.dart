import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/food_entry.dart';
import '../../viewmodels/food_log_view_model.dart';
import '../../viewmodels/auth_view_model.dart';
import 'add_food_screen.dart';
import '../../theme/app_theme.dart';

class FoodLogScreen extends StatefulWidget {
  const FoodLogScreen({super.key});

  @override
  State<FoodLogScreen> createState() => _FoodLogScreenState();
}

class _FoodLogScreenState extends State<FoodLogScreen> {
  bool _timedOut = false;

  @override
  void initState() {
    super.initState();
    // Remove Firebase initialization as it's already initialized
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final foodLogViewModel = Provider.of<FoodLogViewModel>(
      context,
      listen: false,
    );

    if (authViewModel.currentUser != null) {
      foodLogViewModel.initializeForUser(authViewModel.currentUser!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<FoodLogViewModel>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Food Log')),
      body: StreamBuilder<List<FoodEntry>>(
        stream: viewModel.entriesStream,
        builder: (context, snapshot) {
          // Debug print
          print(
            'Stream state: ${snapshot.connectionState}, hasData: ${snapshot.hasData}, error: ${snapshot.error}',
          );

          // Handle all stream states
          if (snapshot.connectionState == ConnectionState.waiting &&
              !_timedOut) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // Check if we need to show the timeout UI
          if (_timedOut &&
              (snapshot.connectionState == ConnectionState.waiting ||
                  snapshot.data == null)) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Taking longer than expected...'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Refresh the screen
                      final authViewModel = Provider.of<AuthViewModel>(
                        context,
                        listen: false,
                      );
                      if (authViewModel.currentUser != null) {
                        // Initialize the food log for the current user
                        viewModel.initializeForUser(
                          authViewModel.currentUser!.id,
                        );
                      }
                      setState(() {
                        _timedOut = false;
                      });
                      // Reset timeout
                      Future.delayed(const Duration(seconds: 5), () {
                        if (mounted) {
                          setState(() {
                            _timedOut = true;
                          });
                        }
                      });
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // Even if we don't have data, we should stop loading
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
