import 'package:flutter/material.dart';

class MacronutrientRow extends StatelessWidget {
  final double protein;
  final double carbs;
  final double fat;
  final bool useClickableFields;
  final VoidCallback? onProteinTap;
  final VoidCallback? onCarbsTap;
  final VoidCallback? onFatTap;

  const MacronutrientRow({
    super.key,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.useClickableFields = false,
    this.onProteinTap,
    this.onCarbsTap,
    this.onFatTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildMacroField(
            context: context,
            label: 'Protein',
            value: protein,
            unit: 'g',
            color: Colors.blue,
            onTap: useClickableFields ? onProteinTap : null,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMacroField(
            context: context,
            label: 'Carbs',
            value: carbs,
            unit: 'g',
            color: Colors.orange,
            onTap: useClickableFields ? onCarbsTap : null,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMacroField(
            context: context,
            label: 'Fat',
            value: fat,
            unit: 'g',
            color: Colors.red,
            onTap: useClickableFields ? onFatTap : null,
          ),
        ),
      ],
    );
  }

  Widget _buildMacroField({
    required BuildContext context,
    required String label,
    required double value,
    required String unit,
    required Color color,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${value.toStringAsFixed(1)}$unit',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (useClickableFields) ...[
              const SizedBox(height: 2),
              Icon(Icons.edit, size: 12, color: colorScheme.onSurfaceVariant),
            ],
          ],
        ),
      ),
    );
  }
}
