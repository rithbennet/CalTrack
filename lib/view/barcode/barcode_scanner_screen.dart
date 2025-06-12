import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/barcode_view_model.dart';
import '../../viewmodels/food_log_view_model.dart';
import '../../viewmodels/auth_view_model.dart';
import '../../models/food_entry.dart';
import 'package:flutter_svg/flutter_svg.dart';
// Import modular components
import '../components/barcode/barcode_scanner_widget.dart';
import '../components/barcode/barcode_food_header.dart';
import '../components/barcode/barcode_nutrition_card.dart';
import '../components/barcode/barcode_serving_size_selector.dart';
import '../components/barcode/barcode_action_buttons.dart';
import '../components/barcode/barcode_manual_entry_dialog.dart';
import '../components/scanner/scanner_constants.dart';
import '../scanner/edit_food_entry_screen.dart';

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  bool _isScanning = true;
  bool _isAddingToLog = false;

  // Serving size selection
  double _selectedServings = ScannerConstants.defaultServingSize;

  @override
  Widget build(BuildContext context) {
    final barcodeVM = Provider.of<BarcodeViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Barcode'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
      ),
      body:
          _isScanning
              ? _buildScannerView(barcodeVM)
              : _buildFoodInfoView(barcodeVM),
    );
  }

  Widget _buildScannerView(BarcodeViewModel barcodeVM) {
    return BarcodeScannerWidget(
      onBarcodeDetected: (String barcode) => _handleBarcode(barcode, barcodeVM),
      onManualEntry: () => _showManualEntryDialog(barcodeVM),
    );
  }

  Widget _buildFoodInfoView(BarcodeViewModel barcodeVM) {
    final food = barcodeVM.scannedFood;
    if (food == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'No food information found',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 220,
              height: 60,
              child: ElevatedButton.icon(
                icon: SvgPicture.asset(
                  'assets/icons/scan-barcode.svg',
                  width: 32,
                  height: 32,
                  colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
                ),
                label: const Text('Scan Again', style: TextStyle(fontSize: 20)),
                onPressed: () => _resetScanner(barcodeVM),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 24,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Food header with name and barcode
          BarcodeFoodHeaderWidget(food: food),
          const SizedBox(height: 16),

          // Nutrition information card
          BarcodeNutritionCard(food: food),
          const SizedBox(height: 16),

          // Serving size selector
          BarcodeServingSizeSelector(
            selectedServings: _selectedServings,
            servingOptions: ScannerConstants.servingOptions,
            onServingsChanged: (double servings) {
              setState(() {
                _selectedServings = servings;
              });
            },
          ),
          const SizedBox(height: 24),

          // Action buttons
          BarcodeActionButtons(
            isLoading: _isAddingToLog,
            onLogFood: () => _addToFoodLog(barcodeVM),
            onEditEntry: () => _editFoodEntry(context, barcodeVM),
            onScanAgain: () => _resetScanner(barcodeVM),
          ),
        ],
      ),
    );
  }

  Future<void> _handleBarcode(String barcode, BarcodeViewModel vm) async {
    if (!_isScanning) return;

    setState(() => _isScanning = false);
    await vm.fetchFoodInfo(barcode);
  }

  Future<void> _showManualEntryDialog(BarcodeViewModel vm) async {
    await BarcodeManualEntryDialog.show(
      context: context,
      onBarcodeEntered: (String barcode) async {
        setState(() => _isScanning = false);
        await vm.fetchFoodInfo(barcode);
      },
    );
  }

  Future<void> _addToFoodLog(BarcodeViewModel vm) async {
    final food = vm.scannedFood;
    if (food == null) return;

    setState(() => _isAddingToLog = true);

    try {
      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
      final foodLogViewModel = Provider.of<FoodLogViewModel>(
        context,
        listen: false,
      );
      if (authViewModel.currentUser == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('User not logged in')));
        return;
      }

      // Convert FoodItem to FoodEntry with selected serving size
      final foodEntry = FoodEntry(
        name: food.name,
        servings: _selectedServings,
        servingUnit: food.servingSize,
        caloriesPerServing: food.calories.round(),
        protein: food.protein,
        carbs: food.carbohydrates,
        fat: food.fat,
      );

      // Add to food log
      await foodLogViewModel.addEntry(foodEntry);

      // Refresh today's calories
      await foodLogViewModel.fetchTodayCalories(authViewModel.currentUser!.id);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Food added to log successfully!'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding food to log: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isAddingToLog = false);
      }
    }
  }

  Future<void> _editFoodEntry(
    BuildContext context,
    BarcodeViewModel barcodeVM,
  ) async {
    final food = barcodeVM.scannedFood;
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

  void _resetScanner(BarcodeViewModel vm) {
    vm.clear();
    setState(() {
      _isScanning = true;
      _selectedServings = ScannerConstants.defaultServingSize;
    });
  }
}
