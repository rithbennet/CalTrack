import 'package:flutter/material.dart';

class SearchFilters extends StatelessWidget {
  final String selectedFilter;
  final Function(String) onFilterChanged;

  const SearchFilters({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  static const List<String> filters = [
    'All',
    'Proteins',
    'Vegetables',
    'Fruits',
    'Grains',
    'Dairy',
    'Snacks',
    'Beverages',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = filter == selectedFilter;

          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (_) => onFilterChanged(filter),
              backgroundColor: colorScheme.surfaceContainerHighest,
              selectedColor: colorScheme.primary,
              labelStyle: TextStyle(
                color:
                    isSelected
                        ? colorScheme.onPrimary
                        : colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              side: BorderSide(
                color:
                    isSelected
                        ? colorScheme.primary
                        : colorScheme.outline.withValues(alpha: .2),
              ),
            ),
          );
        },
      ),
    );
  }
}
