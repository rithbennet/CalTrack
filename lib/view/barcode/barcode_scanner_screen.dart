import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../viewmodels/barcode_view_model.dart';

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  bool _isScanning = true;

  @override
  Widget build(BuildContext context) {
    final barcodeVM = Provider.of<BarcodeViewModel>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Scan Barcode')),
      body:
          _isScanning
              ? MobileScanner(
                onDetect: (BarcodeCapture capture) {
                  // Call an async handler inside but keep this callback sync
                  _handleBarcode(capture, barcodeVM);
                },
              )
              : _buildFoodInfo(context, barcodeVM),
    );
  }

  // Async function handling barcode processing
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
          Text('Name: ${food.name}', style: const TextStyle(fontSize: 20)),
          Text('Calories (total): ${food.caloriesTotal} cal'),
          Text('Calories (per serving): ${food.caloriesPerServing} cal'),
          Text('Serving size: ${food.servingSize}'),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // You can add logic to save this to user's food log here
              Navigator.pop(context);
            },
            child: const Text('Add to Food Log'),
          ),
          ElevatedButton(
            onPressed: () {
              // Restart scanning
              vm.clear();
              setState(() => _isScanning = true);
            },
            child: const Text('Scan Again'),
          ),
        ],
      ),
    );
  }
}
