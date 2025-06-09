import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../models/food_entry.dart';
import '../../models/food_item.dart';

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

  // Predefined serving fractions
  final List<double> _servingOptions = [
    0.25,
    0.5,
    0.75,
    1.0,
    1.25,
    1.5,
    1.75,
    2.0,
    2.25,
    2.5,
    2.75,
    3.0,
    3.5,
    4.0,
    4.5,
    5.0,
    6.0,
    7.0,
    8.0,
    9.0,
    10.0,
  ];

  // Predefined serving units
  final List<String> _servingUnits = [
    '100g',
    '1 cup',
    '1 tbsp',
    '1 tsp',
    '1 oz',
    '1 slice',
    '1 piece',
    '1 serving',
    '1 bowl',
    '1 plate',
    '1 glass',
    '1 lb',
    'Custom',
  ];

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

  // Helper method to format serving display
  String _formatServing(double serving) {
    if (serving == 0.25) return '1/4';
    if (serving == 0.5) return '1/2';
    if (serving == 0.75) return '3/4';
    if (serving == 1.25) return '1 1/4';
    if (serving == 1.5) return '1 1/2';
    if (serving == 1.75) return '1 3/4';
    if (serving == 2.25) return '2 1/4';
    if (serving == 2.5) return '2 1/2';
    if (serving == 2.75) return '2 3/4';
    if (serving % 1 == 0) return serving.toInt().toString();
    return serving.toString();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _customUnitController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }

  void _submit() {
    // Validate the form (only text fields now)
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

  void _showServingUnitPicker() {
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
                  initialItem: _servingUnits.indexOf(_selectedServingUnit),
                ),
                onSelectedItemChanged: (int selectedItem) {
                  setState(() {
                    _selectedServingUnit = _servingUnits[selectedItem];
                  });
                },
                children: List<Widget>.generate(_servingUnits.length, (
                  int index,
                ) {
                  return Center(child: Text(_servingUnits[index]));
                }),
              ),
            ),
          ),
    );
  }

  void _showServingPicker() {
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
                  initialItem: _servingOptions.indexOf(_servings),
                ),
                onSelectedItemChanged: (int selectedItem) {
                  setState(() {
                    _servings = _servingOptions[selectedItem];
                  });
                },
                children: List<Widget>.generate(_servingOptions.length, (
                  int index,
                ) {
                  return Center(
                    child: Text(_formatServing(_servingOptions[index])),
                  );
                }),
              ),
            ),
          ),
    );
  }

  void _showProteinPicker() {
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
                  initialItem: (_protein * 2).round(),
                ),
                onSelectedItemChanged: (int selectedItem) {
                  setState(() {
                    _protein = selectedItem / 2.0;
                  });
                },
                children: List<Widget>.generate(201, (int index) {
                  return Center(
                    child: Text('${(index / 2.0).toStringAsFixed(1)}g'),
                  );
                }),
              ),
            ),
          ),
    );
  }

  void _showCarbsPicker() {
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
                  initialItem: (_carbs * 2).round(),
                ),
                onSelectedItemChanged: (int selectedItem) {
                  setState(() {
                    _carbs = selectedItem / 2.0;
                  });
                },
                children: List<Widget>.generate(501, (int index) {
                  return Center(
                    child: Text('${(index / 2.0).toStringAsFixed(1)}g'),
                  );
                }),
              ),
            ),
          ),
    );
  }

  void _showFatPicker() {
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
                  initialItem: (_fat * 2).round(),
                ),
                onSelectedItemChanged: (int selectedItem) {
                  setState(() {
                    _fat = selectedItem / 2.0;
                  });
                },
                children: List<Widget>.generate(201, (int index) {
                  return Center(
                    child: Text('${(index / 2.0).toStringAsFixed(1)}g'),
                  );
                }),
              ),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Food Entry',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _submit,
            child: Text(
              'Save',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Food Name
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Food Name',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: 'Enter food name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a food name';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Serving Information
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Serving Information',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Servings
                    InkWell(
                      onTap: _showServingPicker,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
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
                                    'Servings',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _formatServing(_servings),
                                    style: theme.textTheme.bodyLarge,
                                  ),
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
                    ),
                    const SizedBox(height: 12),

                    // Serving Unit
                    InkWell(
                      onTap: _showServingUnitPicker,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
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
                                    'Serving Unit',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _selectedServingUnit,
                                    style: theme.textTheme.bodyLarge,
                                  ),
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
                    ),

                    // Custom Unit Input (if needed)
                    if (_selectedServingUnit == 'Custom') ...[
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _customUnitController,
                        decoration: InputDecoration(
                          hintText: 'Enter custom unit',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Nutrition Information
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nutrition Per Serving',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Calories
                    TextFormField(
                      controller: _caloriesController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Calories',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter calories';
                        }
                        final calories = int.tryParse(value);
                        if (calories == null || calories <= 0) {
                          return 'Please enter valid calories';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    // Protein
                    InkWell(
                      onTap: _showProteinPicker,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
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
                                    'Protein',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${_protein.toStringAsFixed(1)}g',
                                    style: theme.textTheme.bodyLarge,
                                  ),
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
                    ),
                    const SizedBox(height: 12),

                    // Carbohydrates
                    InkWell(
                      onTap: _showCarbsPicker,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
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
                                    'Carbohydrates',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${_carbs.toStringAsFixed(1)}g',
                                    style: theme.textTheme.bodyLarge,
                                  ),
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
                    ),
                    const SizedBox(height: 12),

                    // Fat
                    InkWell(
                      onTap: _showFatPicker,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
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
                                    'Fat',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${_fat.toStringAsFixed(1)}g',
                                    style: theme.textTheme.bodyLarge,
                                  ),
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
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: const Size(0, 52),
                ),
                child: Text(
                  'Save Food Entry',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
