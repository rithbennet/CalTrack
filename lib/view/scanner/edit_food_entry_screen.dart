import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../models/food_entry.dart';
import '../../models/food_item.dart';
import '../components/food_form/food_form_pickers.dart';
import '../components/food_form/form_section.dart';
import '../components/food_form/serving_selector.dart';

class EditFoodEntryScreen extends StatefulWidget {
  final FoodItem scannedFood;
  final double initialServings;

  const EditFoodEntryScreen({
    super.key,
    required this.scannedFood,
    this.initialServings = 1.0,
  });

  @override
  State<EditFoodEntryScreen> createState() => _EditFoodEntryScreenState();
}

class _EditFoodEntryScreenState extends State<EditFoodEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _caloriesController;

  // Number values for pickers
  late double _servings;
  late double _protein;
  late double _carbs;
  late double _fat;

  late String _selectedServingUnit;
  final TextEditingController _customUnitController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize controllers with scanned food data
    _nameController = TextEditingController(text: widget.scannedFood.name);
    _caloriesController = TextEditingController(
      text: widget.scannedFood.calories.round().toString(),
    );

    _servings = widget.initialServings;
    _protein = widget.scannedFood.protein;
    _carbs = widget.scannedFood.carbohydrates;
    _fat = widget.scannedFood.fat;
    _selectedServingUnit = widget.scannedFood.servingSize;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _caloriesController.dispose();
    _customUnitController.dispose();
    super.dispose();
  }

  void _submit() {
    // Validate the form
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

    // Validate calories (must be greater than 0)
    int caloriesValue = int.tryParse(_caloriesController.text) ?? 0;
    if (caloriesValue <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Calories per serving must be greater than 0'),
        ),
      );
      return;
    }

    // Determine the serving unit to use
    String finalServingUnit =
        _selectedServingUnit == 'Custom'
            ? _customUnitController.text.trim()
            : _selectedServingUnit;

    final entry = FoodEntry(
      name: _nameController.text.trim(),
      servings: _servings,
      servingUnit: finalServingUnit,
      caloriesPerServing: caloriesValue,
      protein: _protein,
      carbs: _carbs,
      fat: _fat,
    );
    Navigator.pop(context, entry);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Food Entry'),
        actions: [
          TextButton(
            onPressed: _submit,
            child: Text(
              'Save',
              style: TextStyle(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () {
          // Dismiss keyboard when tapping outside text fields
          FocusScope.of(context).unfocus();
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: CupertinoScrollbar(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    // Food name section
                    FormSection(
                      title: 'Food Information',
                      children: [
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Food Name',
                            border: OutlineInputBorder(),
                          ),
                          validator:
                              (value) =>
                                  value == null || value.trim().isEmpty
                                      ? 'Enter a name'
                                      : null,
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Serving information section
                    FormSection(
                      title: 'Serving Information',
                      children: [
                        ServingSelector(
                          servings: _servings,
                          selectedUnit: _selectedServingUnit,
                          onServingsChanged:
                              (value) => setState(() => _servings = value),
                          onUnitChanged:
                              (value) =>
                                  setState(() => _selectedServingUnit = value),
                          customUnitController: _customUnitController,
                          showCustomUnitField: _selectedServingUnit == 'Custom',
                        ),
                        const SizedBox(height: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Calories per Serving Unit',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _caloriesController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: 'Enter calories',
                                suffixText: 'cal',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: colorScheme.surfaceContainerHighest,
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Enter calories per serving';
                                }
                                final calories = int.tryParse(value);
                                if (calories == null || calories <= 0) {
                                  return 'Enter a valid number greater than 0';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Macronutrients section
                    FormSection(
                      title: 'Macronutrients (per serving)',
                      children: [
                        MacronutrientRow(
                          protein: _protein,
                          carbs: _carbs,
                          fat: _fat,
                          useClickableFields: true,
                          onProteinTap:
                              () => FoodFormPickers.showMacronutrientPicker(
                                context: context,
                                nutrientName: 'Protein',
                                currentValue: _protein,
                                onChanged:
                                    (value) => setState(() => _protein = value),
                              ),
                          onCarbsTap:
                              () => FoodFormPickers.showMacronutrientPicker(
                                context: context,
                                nutrientName: 'Carbs',
                                currentValue: _carbs,
                                onChanged:
                                    (value) => setState(() => _carbs = value),
                              ),
                          onFatTap:
                              () => FoodFormPickers.showMacronutrientPicker(
                                context: context,
                                nutrientName: 'Fat',
                                currentValue: _fat,
                                onChanged:
                                    (value) => setState(() => _fat = value),
                              ),
                        ),
                      ],
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
                          'Save Changes',
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
