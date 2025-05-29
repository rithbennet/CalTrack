import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/barcode_view_model.dart';
import '../../viewmodels/food_log_view_model.dart';
import '../../viewmodels/auth_view_model.dart';
import '../../models/food_entry.dart';

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  bool _isScanning = true;
  final MobileScannerController _controller = MobileScannerController();

  // Serving size selection
  double _selectedServings = 1.0;

  // Predefined serving options with 0.25 increments
  final List<double> _servingOptions = [
    0.25,
    0.5,
    0.75,
    1.0,
    1.25,
    1.5,
    1.75,
    2.0,
    2.25,
    2.5,
    2.75,
    3.0,
    3.25,
    3.5,
    3.75,
    4.0,
    4.25,
    4.5,
    4.75,
    5.0,
    5.5,
    6.0,
    7.0,
    8.0,
    9.0,
    10.0,
  ];

  @override
  Widget build(BuildContext context) {
    final barcodeVM = Provider.of<BarcodeViewModel>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Scan Barcode')),
      body:
          _isScanning
              ? Stack(
                children: [
                  MobileScanner(
                    controller: _controller,
                    onDetect: (BarcodeCapture capture) {
                      _handleBarcode(capture, barcodeVM);
                    },
                  ),
                  Positioned(
                    bottom: 80,
                    left: 20,
                    right: 20,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.photo),
                      label: const Text('Scan from Gallery'),
                      onPressed: () => _scanFromGallery(barcodeVM),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.edit),
                      label: const Text('Enter Barcode Manually'),
                      onPressed: () => _showManualEntryDialog(barcodeVM),
                    ),
                  ),
                ],
              )
              : _buildFoodInfo(context, barcodeVM),
    );
  }

  Future<void> _handleBarcode(
    BarcodeCapture capture,
    BarcodeViewModel vm,
  ) async {
    if (!_isScanning) return;

    final String? code =
        capture.barcodes.isNotEmpty ? capture.barcodes.first.rawValue : null;

    if (code != null) {
      setState(() => _isScanning = false);
      await vm.fetchFoodInfo(code);
    }
  }

  Future<void> _scanFromGallery(BarcodeViewModel vm) async {
    // Capture messenger reference before async operations
    final messenger = ScaffoldMessenger.of(context);

    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null && context.mounted) {
      try {
        final BarcodeCapture? capture = await _controller.analyzeImage(
          image.path,
        );

        if (capture != null && capture.barcodes.isNotEmpty) {
          final String? code = capture.barcodes.first.rawValue;
          if (code != null) {
            setState(() => _isScanning = false);
            await vm.fetchFoodInfo(code);
          }
        } else {
          if (context.mounted) {
            messenger.showSnackBar(
              const SnackBar(content: Text('No barcode found in the image.')),
            );
          }
        }
      } catch (e) {
        // Handle unsupported on simulator or other errors gracefully
        if (context.mounted) {
          messenger.showSnackBar(
            SnackBar(content: Text('Error scanning image: $e')),
          );
        }
      }
    }
  }

  Future<void> _showManualEntryDialog(BarcodeViewModel vm) async {
    final TextEditingController controller = TextEditingController();

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Enter Barcode Manually'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: 'Enter barcode'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // close dialog
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final code = controller.text.trim();
                if (code.isNotEmpty) {
                  // Capture navigator reference before async operation
                  final navigator = Navigator.of(dialogContext);
                  navigator.pop(); // close dialog
                  if (context.mounted) {
                    setState(() => _isScanning = false);
                    await vm.fetchFoodInfo(code);
                  }
                }
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFoodInfo(BuildContext context, BarcodeViewModel vm) {
    final food = vm.scannedFood;
    if (food == null) {
      return const Center(child: Text('No food info found'));
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            food.name,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Barcode: ${food.barcode}',
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nutritional Information (${food.servingSize})',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildNutrientRow(
                    'Calories',
                    '${food.calories.toStringAsFixed(1)} kcal',
                  ),
                  _buildNutrientRow(
                    'Protein',
                    '${food.protein.toStringAsFixed(1)} g',
                  ),
                  _buildNutrientRow(
                    'Carbohydrates',
                    '${food.carbohydrates.toStringAsFixed(1)} g',
                  ),
                  _buildNutrientRow(
                    '  - Sugars',
                    '${food.sugars.toStringAsFixed(1)} g',
                  ),
                  _buildNutrientRow('Fat', '${food.fat.toStringAsFixed(1)} g'),
                  _buildNutrientRow(
                    '  - Saturated Fat',
                    '${food.saturatedFat.toStringAsFixed(1)} g',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Serving size selector
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Serving Size',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: _showServingsPicker,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${_formatServing(_selectedServings)} servings',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const Icon(Icons.arrow_drop_down),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await _addToFoodLog(context, vm);
                  },
                  icon: const Icon(Icons.restaurant, size: 20),
                  label: const Text(
                    'Log Food',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 20,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                    minimumSize: const Size(0, 52),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    vm.clear();
                    setState(() {
                      _isScanning = true;
                      _selectedServings = 1.0; // Reset serving size
                    });
                  },
                  icon: const Icon(Icons.qr_code_scanner, size: 20),
                  label: const Text(
                    'Scan Again',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[100],
                    foregroundColor: Colors.grey[700],
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 20,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 1,
                    minimumSize: const Size(0, 52),
                    side: BorderSide(color: Colors.grey[300]!, width: 1),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight:
                  label.startsWith('  ') ? FontWeight.normal : FontWeight.w500,
            ),
          ),
          Text(value, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Future<void> _addToFoodLog(BuildContext context, BarcodeViewModel vm) async {
    final food = vm.scannedFood;
    if (food == null) return;

    try {
      // Capture provider references and navigator before async operations
      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
      final foodLogViewModel = Provider.of<FoodLogViewModel>(
        context,
        listen: false,
      );
      final navigator = Navigator.of(context);
      final messenger = ScaffoldMessenger.of(context);

      if (authViewModel.currentUser == null) {
        messenger.showSnackBar(
          const SnackBar(content: Text('User not logged in')),
        );
        return;
      }

      // Convert FoodItem to FoodEntry
      // Using the selected serving size
      final foodEntry = FoodEntry(
        name: food.name,
        servings: _selectedServings,
        servingUnit: food.servingSize, // e.g., "per 100g"
        caloriesPerServing: food.calories.round(),
        protein: food.protein,
        carbs: food.carbohydrates,
        fat: food.fat,
      );

      // Add to food log
      await foodLogViewModel.addEntry(foodEntry);

      // Refresh today's calories
      await foodLogViewModel.fetchTodayCalories(authViewModel.currentUser!.id);

      if (context.mounted) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Food added to log successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        navigator.pop();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding food to log: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Helper method to format serving display
  String _formatServing(double serving) {
    if (serving % 1 == 0) {
      return serving.toInt().toString();
    }
    return serving.toString();
  }

  void _showServingsPicker() {
    showCupertinoModalPopup(
      context: context,
      builder:
          (BuildContext context) => Container(
            height: 216,
            padding: const EdgeInsets.only(top: 6.0),
            margin: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            color: CupertinoColors.systemBackground.resolveFrom(context),
            child: SafeArea(
              top: false,
              child: CupertinoPicker(
                magnification: 1.22,
                squeeze: 1.2,
                useMagnifier: true,
                itemExtent: 32.0,
                scrollController: FixedExtentScrollController(
                  initialItem: _servingOptions.indexOf(_selectedServings),
                ),
                onSelectedItemChanged: (int selectedItem) {
                  setState(() {
                    _selectedServings = _servingOptions[selectedItem];
                  });
                },
                children: List<Widget>.generate(_servingOptions.length, (
                  int index,
                ) {
                  return Center(
                    child: Text(_formatServing(_servingOptions[index])),
                  );
                }),
              ),
            ),
          ),
    );
  }
}
