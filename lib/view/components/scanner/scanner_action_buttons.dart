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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: isLoading ? null : onLogFood,
            icon:
                isLoading
                    ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          colorScheme.onPrimary,
                        ),
                      ),
                    )
                    : Icon(
                      Icons.restaurant,
                      size: 20,
                      color: colorScheme.onPrimary,
                    ),
            label: Text(
              isLoading ? 'Adding...' : 'Log Food',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onPrimary,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              disabledBackgroundColor: colorScheme.primary.withOpacity(0.7),
              disabledForegroundColor: colorScheme.onPrimary.withOpacity(0.7),
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
          child: OutlinedButton.icon(
            onPressed: isLoading ? null : onScanAgain,
            icon: const Icon(Icons.camera_alt, size: 20),
            label: Text(
              'Scan Again',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: colorScheme.primary,
              disabledForegroundColor: colorScheme.onSurface.withValues(
                alpha: 0.6,
              ),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: BorderSide(color: colorScheme.primary, width: 1.5),
              minimumSize: const Size(0, 52),
            ),
          ),
        ),
      ],
    );
  }
}
