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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: SafeArea(
        child: Consumer<UserOnboardingViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.green),
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
                        'Step ${_currentPage + 1} of 4',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        width: 100,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: (_currentPage + 1) / 4,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.green,
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
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error, color: Colors.red),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            viewModel.error,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                        IconButton(
                          onPressed: viewModel.clearError,
                          icon: const Icon(Icons.close, color: Colors.red),
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
                      _buildBasicInfoPage(viewModel),
                      _buildPhysicalInfoPage(viewModel),
                      _buildActivityPage(viewModel),
                      _buildGoalPage(viewModel),
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
                              side: const BorderSide(color: Colors.green),
                              padding: const EdgeInsets.symmetric(vertical: 15),
                            ),
                            child: const Text(
                              'Back',
                              style: TextStyle(color: Colors.green),
                            ),
                          ),
                        ),
                      if (_currentPage > 0) const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _nextPage(viewModel),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                          child: Text(
                            _currentPage == 3 ? 'Complete Setup' : 'Next',
                            style: const TextStyle(
                              color: Colors.white,
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
    );
  }

  Widget _buildBasicInfoPage(UserOnboardingViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Let\'s get to know you!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'We\'ll use this information to personalize your experience.',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 40),
          _buildTextField(
            label: 'Display Name',
            value: viewModel.displayName,
            onChanged: viewModel.setDisplayName,
            hint: 'How should we call you?',
          ),
          const SizedBox(height: 20),
          _buildTextField(
            label: 'Age',
            value: viewModel.age,
            onChanged: viewModel.setAge,
            hint: 'Your age in years',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 20),
          _buildDropdownField(
            label: 'Gender',
            value: viewModel.gender,
            options: _genderOptions,
            onChanged: viewModel.setGender,
          ),
        ],
      ),
    );
  }

  Widget _buildPhysicalInfoPage(UserOnboardingViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Physical Information',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'This helps us calculate your daily calorie needs.',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 40),
          _buildTextField(
            label: 'Height (cm)',
            value: viewModel.height,
            onChanged: viewModel.setHeight,
            hint: 'Your height in centimeters',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 20),
          _buildTextField(
            label: 'Weight (kg)',
            value: viewModel.weight,
            onChanged: viewModel.setWeight,
            hint: 'Your current weight in kilograms',
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityPage(UserOnboardingViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Activity Level',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'How active are you on a typical day?',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 40),
          ..._activityLevels.map(
            (level) => _buildRadioOption(
              title: level,
              subtitle: _getActivityDescription(level),
              value: level,
              groupValue: viewModel.activityLevel,
              onChanged: viewModel.setActivityLevel,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalPage(UserOnboardingViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Goal',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'What\'s your primary fitness goal?',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 40),
          ..._goals.map(
            (goal) => _buildRadioOption(
              title: goal,
              subtitle: _getGoalDescription(goal),
              value: goal,
              groupValue: viewModel.goal,
              onChanged: viewModel.setGoal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String value,
    required Function(String) onChanged,
    String? hint,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
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
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white54),
            filled: true,
            fillColor: Colors.grey[900],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.green),
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
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButton<String>(
            value: value.isEmpty ? null : value,
            onChanged: (newValue) => onChanged(newValue ?? ''),
            isExpanded: true,
            underline: Container(),
            dropdownColor: Colors.grey[900],
            style: const TextStyle(color: Colors.white),
            items:
                options.map((option) {
                  return DropdownMenuItem(value: option, child: Text(option));
                }).toList(),
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
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: RadioListTile<String>(
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.white70)),
        value: value,
        groupValue: groupValue,
        onChanged: (newValue) => onChanged(newValue ?? ''),
        activeColor: Colors.green,
        tileColor: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Complete onboarding
      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
      final currentUser = authViewModel.currentUser;

      if (currentUser != null) {
        viewModel.saveUserProfile(currentUser.id, currentUser.email);
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
