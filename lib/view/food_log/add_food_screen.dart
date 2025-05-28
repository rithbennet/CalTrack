import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../models/food_entry.dart';

class AddFoodScreen extends StatefulWidget {
  const AddFoodScreen({super.key});

  @override
  State<AddFoodScreen> createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends State<AddFoodScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _caloriesController = TextEditingController();

  // Number values for pickers
  double _servings = 1.0;
  double _protein = 0.0;
  double _carbs = 0.0;
  double _fat = 0.0;

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

  String _selectedServingUnit = '100g';
  final TextEditingController _customUnitController = TextEditingController();

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

  void _showServingsPicker() {
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

  void _showNumberPicker({
    required String title,
    required double currentValue,
    required Function(double) onChanged,
    double min = 0,
    double max = 9999,
    double step = 0.1,
    bool isInteger = false,
  }) async {
    double tempSelected = currentValue;
    await showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext modalContext) {
        return SizedBox(
          height: 280,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 20,
                ),
                child: Text(
                  title,
                  style: Theme.of(
                    modalContext,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: CupertinoPicker(
                  scrollController: FixedExtentScrollController(
                    initialItem:
                        isInteger
                            ? (currentValue - min).round().clamp(
                              0,
                              (max - min).round(),
                            )
                            : ((currentValue - min) / step).round().clamp(
                              0,
                              ((max - min) / step).round(),
                            ),
                  ),
                  itemExtent: 40,
                  onSelectedItemChanged: (index) {
                    tempSelected =
                        isInteger
                            ? min + index.toDouble()
                            : min + (index * step);
                  },
                  children: List.generate(
                    isInteger
                        ? (max - min).round() + 1
                        : ((max - min) / step).round() + 1,
                    (index) {
                      double value =
                          isInteger
                              ? min + index.toDouble()
                              : min + (index * step);
                      return Center(
                        child: Text(
                          isInteger
                              ? value.round().toString()
                              : value.toStringAsFixed(1),
                          style: Theme.of(modalContext).textTheme.bodyLarge,
                        ),
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(modalContext).colorScheme.primary,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  onPressed: () {
                    onChanged(tempSelected);
                    Navigator.pop(modalContext);
                  },
                  child: Text(
                    'Done',
                    style: Theme.of(
                      modalContext,
                    ).textTheme.labelLarge?.copyWith(
                      color: Theme.of(modalContext).colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Widget for the tappable field that triggers the picker
  Widget _buildPickerField({
    required String label,
    required String value,
    required String unit,
    required VoidCallback onTap,
    required ThemeData theme,
    required ColorScheme colorScheme,
  }) {
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Add Food')),
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
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: _buildPickerField(
                            label: 'Servings',
                            value: _formatServing(_servings),
                            unit: '',
                            onTap: _showServingsPicker,
                            theme: theme,
                            colorScheme: colorScheme,
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
                                onTap: _showServingUnitPicker,
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
                                      color:
                                          colorScheme.surfaceContainerHighest,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _selectedServingUnit,
                                        style: theme.textTheme.bodyLarge
                                            ?.copyWith(
                                              color: colorScheme.onSurface,
                                            ),
                                      ),
                                      Icon(
                                        Icons.arrow_drop_down,
                                        color: colorScheme.onSurface.withValues(
                                          alpha: 0.7,
                                        ),
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
                    const SizedBox(height: 16),
                    if (_selectedServingUnit == 'Custom')
                      Column(
                        children: [
                          TextFormField(
                            controller: _customUnitController,
                            decoration: const InputDecoration(
                              labelText: 'Custom Unit (e.g., medium apple)',
                              border: OutlineInputBorder(),
                            ),
                            validator:
                                (value) =>
                                    _selectedServingUnit == 'Custom' &&
                                            (value == null ||
                                                value.trim().isEmpty)
                                        ? 'Enter custom unit'
                                        : null,
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    // Calories text field with number pad
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
                    const SizedBox(height: 24),
                    Text(
                      'Macronutrients (per serving)',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),
                    IntrinsicHeight(
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildPickerField(
                              label: 'Protein',
                              value: _protein.toStringAsFixed(1),
                              unit: 'g',
                              onTap:
                                  () => _showNumberPicker(
                                    title: 'Protein (g)',
                                    currentValue: _protein,
                                    onChanged:
                                        (value) =>
                                            setState(() => _protein = value),
                                    min: 0,
                                    max: 200,
                                    step: 0.1,
                                  ),
                              theme: theme,
                              colorScheme: colorScheme,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildPickerField(
                              label: 'Carbs',
                              value: _carbs.toStringAsFixed(1),
                              unit: 'g',
                              onTap:
                                  () => _showNumberPicker(
                                    title: 'Carbs (g)',
                                    currentValue: _carbs,
                                    onChanged:
                                        (value) =>
                                            setState(() => _carbs = value),
                                    min: 0,
                                    max: 200,
                                    step: 0.1,
                                  ),
                              theme: theme,
                              colorScheme: colorScheme,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildPickerField(
                              label: 'Fat',
                              value: _fat.toStringAsFixed(1),
                              unit: 'g',
                              onTap:
                                  () => _showNumberPicker(
                                    title: 'Fat (g)',
                                    currentValue: _fat,
                                    onChanged:
                                        (value) => setState(() => _fat = value),
                                    min: 0,
                                    max: 200,
                                    step: 0.1,
                                  ),
                              theme: theme,
                              colorScheme: colorScheme,
                            ),
                          ),
                        ],
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
                          'Add Food',
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
