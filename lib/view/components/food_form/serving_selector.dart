import 'package:flutter/material.dart';
import 'food_form_constants.dart';
import 'food_form_pickers.dart';
import 'picker_field.dart';

/// A reusable serving selector widget that handles both servings and units
class ServingSelector extends StatelessWidget {
  final double servings;
  final String selectedUnit;
  final Function(double) onServingsChanged;
  final Function(String) onUnitChanged;
  final TextEditingController? customUnitController;
  final bool showCustomUnitField;

  const ServingSelector({
    super.key,
    required this.servings,
    required this.selectedUnit,
    required this.onServingsChanged,
    required this.onUnitChanged,
    this.customUnitController,
    this.showCustomUnitField = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 2,
              child: PickerField(
                label: 'Servings',
                value: FoodFormConstants.formatServing(servings),
                unit: '',
                showUnit: false,
                onTap: () => _showServingsPicker(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Unit',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => _showServingUnitPicker(context),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 18,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: colorScheme.surfaceContainerHighest,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              selectedUnit,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: colorScheme.onSurface,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Icon(
                            Icons.arrow_drop_down,
                            color: colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (showCustomUnitField && selectedUnit == 'Custom') ...[
          const SizedBox(height: 16),
          TextFormField(
            controller: customUnitController,
            decoration: const InputDecoration(
              labelText: 'Custom Unit (e.g., medium apple)',
              border: OutlineInputBorder(),
            ),
            validator:
                (value) =>
                    selectedUnit == 'Custom' &&
                            (value == null || value.trim().isEmpty)
                        ? 'Enter custom unit'
                        : null,
          ),
        ],
      ],
    );
  }

  void _showServingsPicker(BuildContext context) {
    FoodFormPickers.showServingsPicker(
      context: context,
      selectedServings: servings,
      onServingsChanged: onServingsChanged,
    );
  }

  void _showServingUnitPicker(BuildContext context) {
    FoodFormPickers.showServingUnitPicker(
      context: context,
      selectedUnit: selectedUnit,
      onUnitChanged: onUnitChanged,
    );
  }
}
