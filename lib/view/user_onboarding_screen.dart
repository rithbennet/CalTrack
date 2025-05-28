// ignore_for_file: deprecated_member_use

import 'package:flutter/cupertino.dart'; // Added for CupertinoPicker
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:caltrack/viewmodels/user_onboarding_viewmodel.dart';
import 'package:caltrack/viewmodels/auth_view_model.dart';

class UserOnboardingScreen extends StatefulWidget {
  const UserOnboardingScreen({super.key});

  @override
  State<UserOnboardingScreen> createState() => _UserOnboardingScreenState();
}

class _UserOnboardingScreenState extends State<UserOnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<String> _genderOptions = ['Male', 'Female', 'Other'];
  final List<String> _activityLevels = [
    'Sedentary',
    'Lightly Active',
    'Moderately Active',
    'Very Active',
    'Extremely Active',
  ];
  final List<String> _goals = ['Lose Weight', 'Maintain Weight', 'Gain Weight'];

  // Helper to show CupertinoPicker in a modal bottom sheet
  Future<void> _showNumberPicker({
    required BuildContext context, // Added context here
    required String title,
    required int min,
    required int max,
    required int current,
    required ValueChanged<int> onSelected,
  }) async {
    int tempSelected = current;
    await showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext modalContext) {
        // Use modalContext for elements inside the sheet
        return SizedBox(
          height: 280, // Adjusted height for title and button
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
                    initialItem: (current - min).clamp(
                      0,
                      max - min,
                    ), // Ensure initialItem is valid
                  ),
                  itemExtent: 40,
                  onSelectedItemChanged: (index) {
                    tempSelected = min + index;
                  },
                  children: List.generate(
                    max - min + 1,
                    (index) => Center(
                      child: Text(
                        '${min + index}',
                        style: Theme.of(modalContext).textTheme.bodyLarge,
                      ),
                    ),
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
                    onSelected(tempSelected);
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
    required String unit, // e.g., "years", "cm", "kg"
    required VoidCallback onTap,
    required ThemeData theme,
    required ColorScheme colorScheme,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.surfaceContainerHighest, // Default border
              ),
            ),
            child: Text(
              value.isEmpty ? 'Select $label' : '$value $unit',
              style: theme.textTheme.bodyLarge?.copyWith(
                color:
                    value.isEmpty
                        ? colorScheme.onSurface.withOpacity(0.5)
                        : colorScheme.onSurface,
              ),
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
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Consumer<UserOnboardingViewModel>(
            builder: (context, viewModel, child) {
              if (viewModel.isLoading) {
                return Center(
                  child: CircularProgressIndicator(color: colorScheme.primary),
                );
              }

              if (viewModel.isCompleted) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.pushReplacementNamed(context, '/home');
                });
              }

              return Column(
                children: [
                  // Progress indicator
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Text(
                          'Step ${_currentPage + 1} of 4', // Corrected this line
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.7),
                            fontSize: 16,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          width: 100,
                          height: 4,
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: (_currentPage + 1) / 4,
                            child: Container(
                              decoration: BoxDecoration(
                                color: colorScheme.primary,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Error message
                  if (viewModel.error.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorScheme.error.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: colorScheme.error),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error, color: colorScheme.error),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              viewModel.error,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.error,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: viewModel.clearError,
                            icon: Icon(Icons.close, color: colorScheme.error),
                          ),
                        ],
                      ),
                    ),

                  // Page view
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: (page) {
                        setState(() {
                          _currentPage = page;
                        });
                      },
                      children: [
                        _buildScrollablePage(
                          _buildBasicInfoPage(viewModel, theme, colorScheme),
                        ),
                        _buildScrollablePage(
                          _buildPhysicalInfoPage(viewModel, theme, colorScheme),
                        ),
                        _buildScrollablePage(
                          _buildActivityPage(viewModel, theme, colorScheme),
                        ),
                        _buildScrollablePage(
                          _buildGoalPage(viewModel, theme, colorScheme),
                        ),
                      ],
                    ),
                  ),

                  // Navigation buttons
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        if (_currentPage > 0)
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                _pageController.previousPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: colorScheme.primary),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                ),
                              ),
                              child: Text(
                                'Back',
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: colorScheme.primary,
                                ),
                              ),
                            ),
                          ),
                        if (_currentPage > 0) const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _nextPage(viewModel),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                            ),
                            child: Text(
                              _currentPage == 3 ? 'Complete Setup' : 'Next',
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildScrollablePage(Widget child) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight:
              MediaQuery.of(context).size.height *
              0.7, // Adjusted for potential picker height
        ),
        child: child,
      ),
    );
  }

  Widget _buildBasicInfoPage(
    UserOnboardingViewModel viewModel,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Let\'s get to know you!',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'We\'ll use this information to personalize your experience.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 40),
          _buildTextField(
            // Display Name remains a TextField
            label: 'Display Name',
            value: viewModel.displayName,
            onChanged: viewModel.setDisplayName,
            hint: 'How should we call you?',
            theme: theme,
            colorScheme: colorScheme,
          ),
          const SizedBox(height: 20),
          _buildPickerField(
            // Age uses the picker
            label: 'Age',
            value: viewModel.age,
            unit: 'years',
            onTap: () async {
              await _showNumberPicker(
                context: context,
                title: 'Select Your Age',
                min: 10,
                max: 100,
                current: int.tryParse(viewModel.age) ?? 25,
                onSelected: (val) => viewModel.setAge(val.toString()),
              );
            },
            theme: theme,
            colorScheme: colorScheme,
          ),
          const SizedBox(height: 20),
          _buildDropdownField(
            label: 'Gender',
            value: viewModel.gender,
            options: _genderOptions,
            onChanged: viewModel.setGender,
            theme: theme,
            colorScheme: colorScheme,
          ),
        ],
      ),
    );
  }

  Widget _buildPhysicalInfoPage(
    UserOnboardingViewModel viewModel,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Physical Information',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This helps us calculate your daily calorie needs.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 40),
          _buildPickerField(
            // Height uses the picker
            label: 'Height',
            value: viewModel.height,
            unit: 'cm',
            onTap: () async {
              await _showNumberPicker(
                context: context,
                title: 'Select Your Height',
                min: 100,
                max: 250,
                current: int.tryParse(viewModel.height) ?? 170,
                onSelected: (val) => viewModel.setHeight(val.toString()),
              );
            },
            theme: theme,
            colorScheme: colorScheme,
          ),
          const SizedBox(height: 20),
          _buildPickerField(
            // Weight uses the picker
            label: 'Weight',
            value: viewModel.weight,
            unit: 'kg',
            onTap: () async {
              await _showNumberPicker(
                context: context,
                title: 'Select Your Weight',
                min: 30,
                max: 200,
                current: int.tryParse(viewModel.weight) ?? 70,
                onSelected: (val) => viewModel.setWeight(val.toString()),
              );
            },
            theme: theme,
            colorScheme: colorScheme,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityPage(
    UserOnboardingViewModel viewModel,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Activity Level',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'How active are you on a typical day?',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 40),
          ..._activityLevels.map(
            (level) => _buildRadioOption(
              title: level,
              subtitle: _getActivityDescription(level),
              value: level,
              groupValue: viewModel.activityLevel,
              onChanged: viewModel.setActivityLevel,
              theme: theme,
              colorScheme: colorScheme,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalPage(
    UserOnboardingViewModel viewModel,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Goal',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'What\'s your primary fitness goal?',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 40),
          ..._goals.map(
            (goal) => _buildRadioOption(
              title: goal,
              subtitle: _getGoalDescription(goal),
              value: goal,
              groupValue: viewModel.goal,
              onChanged: viewModel.setGoal,
              theme: theme,
              colorScheme: colorScheme,
            ),
          ),
        ],
      ),
    );
  }

  // Kept _buildTextField for Display Name
  Widget _buildTextField({
    required String label,
    required String value,
    required Function(String) onChanged,
    String? hint,
    TextInputType? keyboardType,
    required ThemeData theme,
    required ColorScheme colorScheme,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: TextEditingController(text: value)
            ..selection = TextSelection.fromPosition(
              TextPosition(offset: value.length),
            ),
          onChanged: onChanged,
          keyboardType: keyboardType,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.5),
            ),
            filled: true,
            fillColor: colorScheme.surfaceVariant,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.primary),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> options,
    required Function(String) onChanged,
    required ThemeData theme,
    required ColorScheme colorScheme,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            // Hides the default underline
            child: DropdownButton<String>(
              value: value.isEmpty ? null : value,
              hint: Text(
                'Select $label',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
              onChanged: (newValue) => onChanged(newValue ?? ''),
              isExpanded: true,
              dropdownColor: colorScheme.surfaceContainerHighest,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface,
              ),
              items:
                  options.map((option) {
                    return DropdownMenuItem(value: option, child: Text(option));
                  }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRadioOption({
    required String title,
    required String subtitle,
    required String value,
    required String groupValue,
    required Function(String) onChanged,
    required ThemeData theme,
    required ColorScheme colorScheme,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: RadioListTile<String>(
        title: Text(
          title,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        value: value,
        groupValue: groupValue,
        onChanged: (newValue) => onChanged(newValue ?? ''),
        activeColor: colorScheme.primary,
        tileColor: colorScheme.surfaceContainerHighest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  String _getActivityDescription(String level) {
    switch (level) {
      case 'Sedentary':
        return 'Little or no exercise';
      case 'Lightly Active':
        return 'Light exercise 1-3 days/week';
      case 'Moderately Active':
        return 'Moderate exercise 3-5 days/week';
      case 'Very Active':
        return 'Hard exercise 6-7 days/week';
      case 'Extremely Active':
        return 'Very hard exercise, physical job';
      default:
        return '';
    }
  }

  String _getGoalDescription(String goal) {
    switch (goal) {
      case 'Lose Weight':
        return 'Create a calorie deficit';
      case 'Maintain Weight':
        return 'Balance calories in and out';
      case 'Gain Weight':
        return 'Create a calorie surplus';
      default:
        return '';
    }
  }

  void _nextPage(UserOnboardingViewModel viewModel) {
    FocusScope.of(context).unfocus(); // Dismiss keyboard before navigating
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
      final currentUser = authViewModel.currentUser;

      if (currentUser != null) {
        viewModel.saveUserProfile(
          currentUser.id,
          currentUser.email,
        ); // Handle nullable email
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
