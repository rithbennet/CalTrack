import 'package:flutter/material.dart';
import 'package:logger/web.dart';
import '../../../models/curated_food_item.dart';

class CompactFoodCard extends StatelessWidget {
  final CuratedFoodItem food;
  final VoidCallback onTap;
  final Widget? actions;
  final bool showCustomBadge;

  const CompactFoodCard({
    super.key,
    required this.food,
    required this.onTap,
    this.actions,
    this.showCustomBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: () {
          try {
            onTap();
          } catch (e) {
            Logger().e('Error in CompactFoodCard onTap: $e');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
            );
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  if (showCustomBadge) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'CUSTOM',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 9,
                        ),
                      ),
                    ),
                    const Spacer(),
                  ] else
                    const Spacer(),
                  if (actions != null) actions!,
                ],
              ),

              const SizedBox(height: 8),

              // Food name
              Text(
                food.name.isNotEmpty ? food.name : 'Unnamed Food',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              if (food.brand.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  food.brand,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              const Spacer(),

              // Calories
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      '${food.caloriesPerServing}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'cal',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onPrimaryContainer.withValues(
                          alpha: 0.8,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Macros
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _MacroText('P: ${food.protein.toInt()}g', Colors.blue),
                  _MacroText('C: ${food.carbs.toInt()}g', Colors.orange),
                  _MacroText('F: ${food.fat.toInt()}g', Colors.red),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MacroText extends StatelessWidget {
  final String text;
  final Color color;

  const _MacroText(this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600),
    );
  }
}
