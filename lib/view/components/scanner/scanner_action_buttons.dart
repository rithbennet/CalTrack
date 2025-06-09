import 'package:flutter/material.dart';

class ScannerActionButtons extends StatelessWidget {
  final VoidCallback onLogFood;
  final VoidCallback onScanAgain;
  final bool isLoading;

  const ScannerActionButtons({
    super.key,
    required this.onLogFood,
    required this.onScanAgain,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: isLoading ? null : onLogFood,
            icon: Icon(
              isLoading ? Icons.hourglass_empty : Icons.restaurant,
              size: 20,
            ),
            label: Text(
              isLoading ? 'Adding...' : 'Log Food',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey[400],
              disabledForegroundColor: Colors.grey[200],
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              minimumSize: const Size(0, 52),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: isLoading ? null : onScanAgain,
            icon: const Icon(Icons.camera_alt, size: 20),
            label: const Text(
              'Scan Again',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[100],
              foregroundColor: Colors.grey[700],
              disabledBackgroundColor: Colors.grey[300],
              disabledForegroundColor: Colors.grey[500],
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: BorderSide(color: Colors.grey[300]!, width: 1),
              minimumSize: const Size(0, 52),
            ),
          ),
        ),
      ],
    );
  }
}
