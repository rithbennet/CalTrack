import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'food_form_constants.dart';

/// Utility class for showing various pickers used in food forms
class FoodFormPickers {
  /// Shows a Cupertino picker for serving units
  static void showServingUnitPicker({
    required BuildContext context,
    required String selectedUnit,
    required Function(String) onUnitChanged,
  }) {
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
                  initialItem: FoodFormConstants.servingUnits.indexOf(
                    selectedUnit,
                  ),
                ),
                onSelectedItemChanged: (int selectedItem) {
                  onUnitChanged(FoodFormConstants.servingUnits[selectedItem]);
                },
                children: List<Widget>.generate(
                  FoodFormConstants.servingUnits.length,
                  (int index) {
                    return Center(
                      child: Text(FoodFormConstants.servingUnits[index]),
                    );
                  },
                ),
              ),
            ),
          ),
    );
  }

  /// Shows a Cupertino picker for serving amounts
  static void showServingsPicker({
    required BuildContext context,
    required double selectedServings,
    required Function(double) onServingsChanged,
  }) {
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
                  initialItem: FoodFormConstants.servingOptions.indexOf(
                    selectedServings,
                  ),
                ),
                onSelectedItemChanged: (int selectedItem) {
                  onServingsChanged(
                    FoodFormConstants.servingOptions[selectedItem],
                  );
                },
                children: List<Widget>.generate(
                  FoodFormConstants.servingOptions.length,
                  (int index) {
                    return Center(
                      child: Text(
                        FoodFormConstants.formatServing(
                          FoodFormConstants.servingOptions[index],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
    );
  }

  /// Shows a number picker modal for macronutrients
  static Future<void> showNumberPicker({
    required BuildContext context,
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

  /// Shows a Cupertino picker for macronutrients (protein, carbs, fat)
  static void showMacronutrientPicker({
    required BuildContext context,
    required String nutrientName,
    required double currentValue,
    required Function(double) onChanged,
    int maxItems = 201,
  }) {
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
                  initialItem: (currentValue * 2).round(),
                ),
                onSelectedItemChanged: (int selectedItem) {
                  onChanged(selectedItem / 2.0);
                },
                children: List<Widget>.generate(maxItems, (int index) {
                  return Center(
                    child: Text('${(index / 2.0).toStringAsFixed(1)}g'),
                  );
                }),
              ),
            ),
          ),
    );
  }
}
