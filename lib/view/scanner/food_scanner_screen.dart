import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/food_scanner_view_model.dart';
import '../../viewmodels/food_log_view_model.dart';
import '../../viewmodels/auth_view_model.dart';
import '../../models/food_entry.dart';
// Import modular components
import '../components/scanner/image_selector_widget.dart';
import '../components/scanner/scanner_loading_state.dart';
import '../components/scanner/scanner_error_state.dart';
import '../components/scanner/image_preview_widget.dart';
import '../components/scanner/food_header_widget.dart';
import '../components/scanner/nutrition_info_card.dart';
import '../components/scanner/serving_size_selector.dart';
import '../components/scanner/scanner_action_buttons.dart';
import '../components/scanner/scanner_constants.dart';
import 'edit_food_entry_screen.dart';

class FoodScannerScreen extends StatefulWidget {
  final String? initialImagePath;

  const FoodScannerScreen({super.key, this.initialImagePath});

  @override
  State<FoodScannerScreen> createState() => _FoodScannerScreenState();
}

class _FoodScannerScreenState extends State<FoodScannerScreen> {
  File? _selectedImage;
  double _selectedServings = ScannerConstants.defaultServingSize;
  bool _isAddingToLog = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialImagePath != null) {
      _selectedImage = File(widget.initialImagePath!);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _analyzeImage();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'AI Food Scanner',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Consumer<FoodScannerViewModel>(
        builder: (context, viewModel, child) {
          if (_selectedImage == null) {
            return _buildImageSelector();
          }

          if (viewModel.isLoading) {
            return _buildLoadingState();
          }

          if (viewModel.scannedFood != null) {
            return _buildFoodInfo(context, viewModel);
          }

          return _buildErrorState(viewModel.errorMessage);
        },
      ),
    );
  }

  Widget _buildImageSelector() {
    return ImageSelectorWidget(
      onImageSelected: (String imagePath) {
        setState(() {
          _selectedImage = File(imagePath);
        });
        _analyzeImage();
      },
    );
  }

  Widget _buildLoadingState() {
    return ScannerLoadingState(selectedImage: _selectedImage);
  }

  Widget _buildFoodInfo(BuildContext context, FoodScannerViewModel viewModel) {
    final food = viewModel.scannedFood!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(ScannerConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image preview
          ImagePreviewWidget(image: _selectedImage!, height: 200),
          const SizedBox(height: 20),

          // Food header with name and barcode
          FoodHeaderWidget(food: food),
          const SizedBox(height: 16),

          // Nutritional information card
          NutritionInfoCard(food: food),
          const SizedBox(height: 20),

          // Serving size selector
          ServingSizeSelector(
            selectedServings: _selectedServings,
            servingOptions: ScannerConstants.servingOptions,
            onServingsChanged: (newServings) {
              setState(() {
                _selectedServings = newServings;
              });
            },
          ),
          const SizedBox(height: 24),

          // Action buttons
          ScannerActionButtons(
            isLoading: _isAddingToLog,
            onLogFood: () => _addToFoodLog(context, viewModel),
            onEditEntry: () => _editFoodEntry(context, viewModel),
            onScanAgain: _resetScanner,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String? errorMessage) {
    return ScannerErrorState(
      errorMessage: errorMessage,
      onRetry: _resetScanner,
    );
  }

  Future<void> _addToFoodLog(
    BuildContext context,
    FoodScannerViewModel viewModel,
  ) async {
    final food = viewModel.scannedFood;
    if (food == null) return;

    setState(() {
      _isAddingToLog = true;
    });

    try {
      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
      final foodLogViewModel = Provider.of<FoodLogViewModel>(
        context,
        listen: false,
      );
      final navigator = Navigator.of(context);
      final messenger = ScaffoldMessenger.of(context);

      if (authViewModel.currentUser == null) {
        messenger.showSnackBar(
          SnackBar(
            content: const Text('User not logged in'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        return;
      }

      final foodEntry = FoodEntry(
        name: food.name,
        servings: _selectedServings,
        servingUnit: food.servingSize,
        caloriesPerServing: food.calories.round(),
        protein: food.protein,
        carbs: food.carbohydrates,
        fat: food.fat,
      );

      await foodLogViewModel.addEntry(foodEntry);
      await foodLogViewModel.fetchTodayCalories(authViewModel.currentUser!.id);

      if (context.mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: const Text('Food added to log successfully!'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
        navigator.pop();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding food to log: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      setState(() {
        _isAddingToLog = false;
      });
    }
  }

  Future<void> _editFoodEntry(
    BuildContext context,
    FoodScannerViewModel viewModel,
  ) async {
    final food = viewModel.scannedFood;
    if (food == null) return;

    final result = await Navigator.of(context).push<FoodEntry>(
      MaterialPageRoute(
        builder:
            (context) => EditFoodEntryScreen(
              scannedFood: food,
              initialServings: _selectedServings,
            ),
      ),
    );

    if (result != null && context.mounted) {
      // User saved the edited entry, now add it to the food log
      await _addEditedEntryToLog(context, result);
    }
  }

  Future<void> _addEditedEntryToLog(
    BuildContext context,
    FoodEntry foodEntry,
  ) async {
    setState(() {
      _isAddingToLog = true;
    });

    try {
      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
      final foodLogViewModel = Provider.of<FoodLogViewModel>(
        context,
        listen: false,
      );
      final navigator = Navigator.of(context);
      final messenger = ScaffoldMessenger.of(context);

      if (authViewModel.currentUser == null) {
        messenger.showSnackBar(
          SnackBar(
            content: const Text('User not logged in'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        return;
      }

      await foodLogViewModel.addEntry(foodEntry);
      await foodLogViewModel.fetchTodayCalories(authViewModel.currentUser!.id);

      if (context.mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: const Text('Edited food added to log successfully!'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
        navigator.pop();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding food to log: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      setState(() {
        _isAddingToLog = false;
      });
    }
  }

  void _resetScanner() {
    setState(() {
      _selectedImage = null;
      _selectedServings = ScannerConstants.defaultServingSize;
    });
    final viewModel = Provider.of<FoodScannerViewModel>(context, listen: false);
    viewModel.clear();
  }

  Future<void> _analyzeImage() async {
    if (_selectedImage == null) return;

    final viewModel = Provider.of<FoodScannerViewModel>(context, listen: false);
    await viewModel.analyzeFoodImage(_selectedImage!);
  }
}
