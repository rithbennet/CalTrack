import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../models/curated_food_item.dart';
import '../components/food_form/food_form_pickers.dart';
import '../components/food_form/macronutrient_row.dart';

class CreateCustomFoodScreen extends StatefulWidget {
  final CuratedFoodItem? existingFood; // For editing existing foods

  const CreateCustomFoodScreen({super.key, this.existingFood});

  @override
  State<CreateCustomFoodScreen> createState() => _CreateCustomFoodScreenState();
}

class _CreateCustomFoodScreenState extends State<CreateCustomFoodScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _brandController;
  late TextEditingController _caloriesController;
  late TextEditingController _servingSizeController;

  // Number values for pickers
  late double _protein;
  late double _carbs;
  late double _fat;

  late String _selectedServingUnit;
  late String _selectedCategory;
  final TextEditingController _customUnitController = TextEditingController();

  List<String> _tags = [];
  final TextEditingController _tagController = TextEditingController();

  static const List<String> _categories = [
    'proteins',
    'vegetables',
    'fruits',
    'grains',
    'dairy',
    'snacks',
    'beverages',
    'other',
  ];

  static const List<String> _servingUnits = [
    'g',
    'oz',
    'cup',
    'piece',
    'slice',
    'serving',
    'tbsp',
    'tsp',
    'Custom',
  ];

  @override
  void initState() {
    super.initState();

    if (widget.existingFood != null) {
      // Initialize with existing food data
      final food = widget.existingFood!;
      _nameController = TextEditingController(text: food.name);
      _brandController = TextEditingController(text: food.brand);
      _caloriesController = TextEditingController(
        text: food.caloriesPerServing.toString(),
      );
      _servingSizeController = TextEditingController(
        text: food.servingSize.toString(),
      );

      _protein = food.protein;
      _carbs = food.carbs;
      _fat = food.fat;
      _selectedServingUnit = food.servingUnit;
      _selectedCategory = food.category;
      _tags = List.from(food.tags);
    } else {
      // Initialize with default values
      _nameController = TextEditingController();
      _brandController = TextEditingController();
      _caloriesController = TextEditingController();
      _servingSizeController = TextEditingController(text: '100');

      _protein = 0.0;
      _carbs = 0.0;
      _fat = 0.0;
      _selectedServingUnit = 'g';
      _selectedCategory = 'other';
      _tags = [];
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _caloriesController.dispose();
    _servingSizeController.dispose();
    _customUnitController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    // Validate custom unit if needed
    if (_selectedServingUnit == 'Custom' &&
        _customUnitController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a custom unit')),
      );
      return;
    }

    // Validate calories
    int caloriesValue = int.tryParse(_caloriesController.text) ?? 0;
    if (caloriesValue <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Calories must be greater than 0')),
      );
      return;
    }

    // Validate serving size
    double servingSizeValue = double.tryParse(_servingSizeController.text) ?? 0;
    if (servingSizeValue <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Serving size must be greater than 0')),
      );
      return;
    }

    // Determine the serving unit to use
    String finalServingUnit =
        _selectedServingUnit == 'Custom'
            ? _customUnitController.text.trim()
            : _selectedServingUnit;

    // Validate serving unit is not empty
    if (finalServingUnit.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Serving unit cannot be empty')),
      );
      return;
    }

    // Validate category is not empty
    if (_selectedCategory.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a category')));
      return;
    }

    final customFood = CuratedFoodItem(
      id: widget.existingFood?.id ?? '', // Will be set by Firestore
      name: _nameController.text.trim(),
      brand: _brandController.text.trim(),
      caloriesPerServing: caloriesValue,
      servingUnit: finalServingUnit,
      servingSize: servingSizeValue,
      protein: _protein,
      carbs: _carbs,
      fat: _fat,
      tags: _tags,
      category: _selectedCategory,
      rating: 5.0, // Default rating for custom foods
      reviewCount: 1, // Mark as custom food
    );

    Navigator.pop(context, customFood);
  }

  void _addTag() {
    final tag = _tagController.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  void _showMacronutrientPicker(
    String nutrientName,
    double currentValue,
    Function(double) onChanged,
  ) {
    FoodFormPickers.showMacronutrientPicker(
      context: context,
      nutrientName: nutrientName,
      currentValue: currentValue,
      onChanged: onChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isEditing = widget.existingFood != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Custom Food' : 'Create Custom Food'),
        actions: [
          TextButton(
            onPressed: _submit,
            child: Text(
              isEditing ? 'Update' : 'Create',
              style: TextStyle(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: CupertinoScrollbar(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    // Basic Information Section
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Basic Information',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                labelText: 'Food Name *',
                                hintText: 'e.g., Homemade Chicken Curry',
                                border: OutlineInputBorder(),
                              ),
                              validator:
                                  (value) =>
                                      value == null || value.trim().isEmpty
                                          ? 'Food name is required'
                                          : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _brandController,
                              decoration: const InputDecoration(
                                labelText: 'Brand/Source (Optional)',
                                hintText: 'e.g., Homemade, Mom\'s Recipe',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              value: _selectedCategory,
                              decoration: const InputDecoration(
                                labelText: 'Category',
                                border: OutlineInputBorder(),
                              ),
                              items:
                                  _categories.map((category) {
                                    return DropdownMenuItem(
                                      value: category,
                                      child: Text(
                                        category.replaceFirst(
                                          category[0],
                                          category[0].toUpperCase(),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedCategory = value!;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Serving Information Section
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Serving Information',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _servingSizeController,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      labelText: 'Serving Size *',
                                      border: OutlineInputBorder(),
                                    ),
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Serving size is required';
                                      }
                                      final size = double.tryParse(value);
                                      if (size == null || size <= 0) {
                                        return 'Enter a valid number';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: _selectedServingUnit,
                                    decoration: const InputDecoration(
                                      labelText: 'Unit',
                                      border: OutlineInputBorder(),
                                    ),
                                    items:
                                        _servingUnits.map((unit) {
                                          return DropdownMenuItem(
                                            value: unit,
                                            child: Text(unit),
                                          );
                                        }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedServingUnit = value!;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                            if (_selectedServingUnit == 'Custom') ...[
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _customUnitController,
                                decoration: const InputDecoration(
                                  labelText: 'Custom Unit',
                                  hintText: 'e.g., medium apple, large bowl',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ],
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _caloriesController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Calories per Serving *',
                                suffixText: 'kcal',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: colorScheme.surfaceContainerHighest,
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Calories are required';
                                }
                                final calories = int.tryParse(value);
                                if (calories == null || calories <= 0) {
                                  return 'Enter valid calories';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Macronutrients Section
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Macronutrients (per serving)',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            MacronutrientRow(
                              protein: _protein,
                              carbs: _carbs,
                              fat: _fat,
                              useClickableFields: true,
                              onProteinTap:
                                  () => _showMacronutrientPicker(
                                    'Protein',
                                    _protein,
                                    (value) {
                                      setState(() => _protein = value);
                                    },
                                  ),
                              onCarbsTap:
                                  () => _showMacronutrientPicker(
                                    'Carbs',
                                    _carbs,
                                    (value) {
                                      setState(() => _carbs = value);
                                    },
                                  ),
                              onFatTap:
                                  () => _showMacronutrientPicker('Fat', _fat, (
                                    value,
                                  ) {
                                    setState(() => _fat = value);
                                  }),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Tags Section
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tags (Optional)',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _tagController,
                                    decoration: const InputDecoration(
                                      labelText: 'Add Tag',
                                      hintText: 'e.g., spicy, vegetarian, keto',
                                      border: OutlineInputBorder(),
                                    ),
                                    onFieldSubmitted: (_) => _addTag(),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  onPressed: _addTag,
                                  icon: const Icon(Icons.add),
                                  style: IconButton.styleFrom(
                                    backgroundColor: colorScheme.primary,
                                    foregroundColor: colorScheme.onPrimary,
                                  ),
                                ),
                              ],
                            ),
                            if (_tags.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children:
                                    _tags.map((tag) {
                                      return Chip(
                                        label: Text(tag),
                                        onDeleted: () => _removeTag(tag),
                                        deleteIcon: const Icon(
                                          Icons.close,
                                          size: 18,
                                        ),
                                      );
                                    }).toList(),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          isEditing
                              ? 'Update Custom Food'
                              : 'Create Custom Food',
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
