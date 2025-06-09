import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image_picker/image_picker.dart';

class BarcodeScannerWidget extends StatefulWidget {
  final Function(String barcode) onBarcodeDetected;
  final Function() onManualEntry;

  const BarcodeScannerWidget({
    super.key,
    required this.onBarcodeDetected,
    required this.onManualEntry,
  });

  @override
  State<BarcodeScannerWidget> createState() => _BarcodeScannerWidgetState();
}

class _BarcodeScannerWidgetState extends State<BarcodeScannerWidget> {
  final MobileScannerController _controller = MobileScannerController();

  @override
  void dispose() {
    _controller.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Stack(
      children: [
        // Camera preview
        MobileScanner(
          controller: _controller,
          onDetect: (BarcodeCapture capture) {
            final String? code =
                capture.barcodes.isNotEmpty
                    ? capture.barcodes.first.rawValue
                    : null;
            if (code != null) {
              widget.onBarcodeDetected(code);
            }
          },
        ),

        // Overlay with scan area indicator
        _buildScanOverlay(colorScheme),

        // Bottom action buttons
        Positioned(
          bottom: 40,
          left: 20,
          right: 20,
          child: Column(
            children: [
              // Gallery and Manual entry buttons
              Row(
                children: [
                  Expanded(
                    child: _buildOverlayButton(
                      icon: Icons.photo_library,
                      label: 'Gallery',
                      onPressed: _scanFromGallery,
                      colorScheme: colorScheme,
                    ),
                  ),
                  const SizedBox(
                    width: 16,
                  ), // Increased spacing between buttons
                  Expanded(
                    child: _buildOverlayButton(
                      icon: Icons.edit,
                      label: 'Manual Entry',
                      onPressed: widget.onManualEntry,
                      colorScheme: colorScheme,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40), // Increased bottom padding
            ],
          ),
        ),

        // Instructions overlay
        Positioned(
          top: 60,
          left: 20,
          right: 20,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surface.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.primary.withValues(alpha: 0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              'Position the barcode in the center and it will scan automatically',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScanOverlay(ColorScheme colorScheme) {
    return Center(
      child: Container(
        width: 280,
        height: 140,
        decoration: BoxDecoration(
          border: Border.all(color: colorScheme.primary, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          children: [
            // Corner indicators
            Positioned(
              top: -1,
              left: -1,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: colorScheme.primary, width: 6),
                    left: BorderSide(color: colorScheme.primary, width: 6),
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                  ),
                ),
              ),
            ),
            Positioned(
              top: -1,
              right: -1,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: colorScheme.primary, width: 6),
                    right: BorderSide(color: colorScheme.primary, width: 6),
                  ),
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(12),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -1,
              left: -1,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: colorScheme.primary, width: 6),
                    left: BorderSide(color: colorScheme.primary, width: 6),
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -1,
              right: -1,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: colorScheme.primary, width: 6),
                    right: BorderSide(color: colorScheme.primary, width: 6),
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomRight: Radius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverlayButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required ColorScheme colorScheme,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(
        label,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.surface.withValues(alpha: 0.9),
        foregroundColor: colorScheme.onSurface,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        shadowColor: Colors.black.withValues(alpha: 0.3),
      ),
    );
  }

  Future<void> _scanFromGallery() async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null && mounted) {
        try {
          final BarcodeCapture? capture = await _controller.analyzeImage(
            image.path,
          );

          if (capture != null && capture.barcodes.isNotEmpty) {
            final String? code = capture.barcodes.first.rawValue;
            if (code != null) {
              widget.onBarcodeDetected(code);
            }
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('No barcode found in the image'),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
            }
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error scanning image: $e'),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to select image: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}
