import 'dart:io';
import 'package:flutter/material.dart';

class ScannerLoadingState extends StatelessWidget {
  final File? selectedImage;

  const ScannerLoadingState({super.key, this.selectedImage});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (selectedImage != null) ...[
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: FileImage(selectedImage!),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 24),
                Text(
                  'Analyzing your food...',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'This may take a few seconds',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
