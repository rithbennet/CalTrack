import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class ServingSizeSelector extends StatelessWidget {
  final double selectedServings;
  final List<double> servingOptions;
  final ValueChanged<double> onServingsChanged;

  const ServingSizeSelector({
    super.key,
    required this.selectedServings,
    required this.servingOptions,
    required this.onServingsChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 2,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Serving Size',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => _showServingsPicker(context),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 12,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: colorScheme.outline),
                  borderRadius: BorderRadius.circular(8),
                  color: colorScheme.surface,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_formatServing(selectedServings)} servings',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                    Icon(Icons.arrow_drop_down, color: colorScheme.onSurface),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showServingsPicker(BuildContext context) {
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
                  initialItem: servingOptions.indexOf(selectedServings),
                ),
                onSelectedItemChanged: (int selectedItem) {
                  onServingsChanged(servingOptions[selectedItem]);
                },
                children: List<Widget>.generate(servingOptions.length, (
                  int index,
                ) {
                  return Center(
                    child: Text(_formatServing(servingOptions[index])),
                  );
                }),
              ),
            ),
          ),
    );
  }

  String _formatServing(double serving) {
    if (serving % 1 == 0) {
      return serving.toInt().toString();
    }
    return serving.toString();
  }
}
