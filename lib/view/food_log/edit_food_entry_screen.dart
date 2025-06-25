import 'package:flutter/material.dart';
import '../../models/food_entry.dart';
import '../components/food_form/food_form_pickers.dart';
import '../components/food_form/form_section.dart';
import '../components/food_form/serving_selector.dart';
import '../components/food_form/macronutrient_row.dart'
    as macro; // This will now work

class EditFoodLogEntryScreen extends StatefulWidget {
  final FoodEntry existingEntry;

  const EditFoodLogEntryScreen({super.key, required this.existingEntry});

  @override
  State<EditFoodLogEntryScreen> createState() => _EditFoodLogEntryScreenState();
}

class _EditFoodLogEntryScreenState extends State<EditFoodLogEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _caloriesController;
  late TextEditingController _notesController;

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
    // Initialize controllers with existing food data
    _nameController = TextEditingController(text: widget.existingEntry.name);
    _caloriesController = TextEditingController(
      text: widget.existingEntry.caloriesPerServing.toString(),
    );
    _notesController = TextEditingController(
      text: widget.existingEntry.notes ?? '',
    );

    _servings = widget.existingEntry.servings;
    _protein = widget.existingEntry.protein;
    _carbs = widget.existingEntry.carbs;
    _fat = widget.existingEntry.fat;
    _selectedServingUnit = widget.existingEntry.servingUnit;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _caloriesController.dispose();
    _notesController.dispose();
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

    final updatedEntry = FoodEntry(
      id: widget.existingEntry.id, // Keep the same ID
      name: _nameController.text.trim(),
      servings: _servings,
      servingUnit: finalServingUnit,
      caloriesPerServing: caloriesValue,
      protein: _protein,
      carbs: _carbs,
      fat: _fat,
      date: widget.existingEntry.date, // Keep the original date
      notes:
          _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
    );
    Navigator.pop(context, updatedEntry);
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
                      macro.MacronutrientRow(
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

                  const SizedBox(height: 16),

                  // Notes section
                  FormSection(
                    title: 'Notes (Optional)',
                    children: [
                      TextFormField(
                        controller: _notesController,
                        decoration: const InputDecoration(
                          labelText: 'Add any notes about this food entry',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
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
                        'Update Food Entry',
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
    );
  }
}
