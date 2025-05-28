import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/barcode_view_model.dart';

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  bool _isScanning = true;
  final MobileScannerController _controller = MobileScannerController();

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
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.photo),
                      label: const Text('Scan from Gallery'),
                      onPressed: () => _scanFromGallery(barcodeVM),
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
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No barcode found in the image.')),
        );
      }
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
              // Add logic to save to user's food log here
              Navigator.pop(context);
            },
            child: const Text('Add to Food Log'),
          ),
          ElevatedButton(
            onPressed: () {
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
