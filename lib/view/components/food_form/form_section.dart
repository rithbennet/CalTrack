import 'package:flutter/material.dart';

/// A reusable form section widget with consistent styling
class FormSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final EdgeInsetsGeometry? padding;

  const FormSection({
    super.key,
    required this.title,
    required this.children,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}

/// A reusable macronutrient row widget
class MacronutrientRow extends StatelessWidget {
  final double protein;
  final double carbs;
  final double fat;
  final VoidCallback onProteinTap;
  final VoidCallback onCarbsTap;
  final VoidCallback onFatTap;
  final bool useClickableFields;

  const MacronutrientRow({
    super.key,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.onProteinTap,
    required this.onCarbsTap,
    required this.onFatTap,
    this.useClickableFields = false,
  });

  @override
  Widget build(BuildContext context) {
    if (useClickableFields) {
      return Column(
        children: [
          _buildClickableField(
            context,
            'Protein',
            '${protein.toStringAsFixed(1)}g',
            onProteinTap,
          ),
          const SizedBox(height: 12),
          _buildClickableField(
            context,
            'Carbohydrates',
            '${carbs.toStringAsFixed(1)}g',
            onCarbsTap,
          ),
          const SizedBox(height: 12),
          _buildClickableField(
            context,
            'Fat',
            '${fat.toStringAsFixed(1)}g',
            onFatTap,
          ),
        ],
      );
    }

    return IntrinsicHeight(
      child: Row(
        children: [
          Expanded(
            child: _buildPickerField(
              context,
              'Protein',
              protein.toStringAsFixed(1),
              'g',
              onProteinTap,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildPickerField(
              context,
              'Carbs',
              carbs.toStringAsFixed(1),
              'g',
              onCarbsTap,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildPickerField(
              context,
              'Fat',
              fat.toStringAsFixed(1),
              'g',
              onFatTap,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPickerField(
    BuildContext context,
    String label,
    String value,
    String unit,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colorScheme.surfaceContainerHighest),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '$value $unit',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildClickableField(
    BuildContext context,
    String label,
    String value,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: colorScheme.outline),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(value, style: theme.textTheme.bodyLarge),
                ],
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
