import 'package:flutter/material.dart';

class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onSearchChanged;
  final String hintText;

  const SearchBarWidget({
    super.key,
    required this.controller,
    required this.onSearchChanged,
    required this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return TextField(
      controller: controller,
      onChanged: onSearchChanged,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        prefixIcon: Icon(Icons.search, color: colorScheme.onSurfaceVariant),
        suffixIcon:
            controller.text.isNotEmpty
                ? IconButton(
                  icon: Icon(Icons.clear, color: colorScheme.onSurfaceVariant),
                  onPressed: () {
                    controller.clear();
                    onSearchChanged('');
                  },
                )
                : null,
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary),
        ),
      ),
    );
  }
}
