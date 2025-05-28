import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:caltrack/viewmodels/auth_view_model.dart';
import 'package:caltrack/viewmodels/user_view_model.dart';
import 'package:caltrack/models/user_model.dart';
import 'package:caltrack/utils/calorie_calculator.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _ageController = TextEditingController();
  final _dailyCalorieTargetController = TextEditingController();

  String _selectedGender = 'Male';
  String _selectedActivityLevel = 'Moderately Active';
  String _selectedGoal = 'Maintain Weight';

  // Activity level options
  final List<String> _activityLevels = [
    'Sedentary',
    'Lightly Active',
    'Moderately Active',
    'Very Active',
    'Extremely Active',
  ];

  // Goal options
  final List<String> _goals = ['Lose Weight', 'Maintain Weight', 'Gain Weight'];

  // Gender options
  final List<String> _genders = ['Male', 'Female', 'Other'];

  bool _isEditing = false;
  bool _isSaving = false;
  bool _useAutomaticCalories = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }

  void _loadUserData() {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);

    if (authViewModel.currentUser != null) {
      userViewModel.loadUserProfile(authViewModel.currentUser!.id);
      // Set the initial values from user profile
      final userProfile = userViewModel.userProfile;
      final currentUser = authViewModel.currentUser;

      _displayNameController.text =
          userProfile?.displayName ?? currentUser?.displayName ?? '';
      _weightController.text = userProfile?.weight?.toString() ?? '';
      _heightController.text = userProfile?.height?.toString() ?? '';
      _ageController.text = userProfile?.age?.toString() ?? '';

      // Determine if user is using automatic calories
      // If they have no manual target but can calculate automatic, default to automatic
      if (userProfile?.dailyCalorieTarget == null &&
          userProfile?.canCalculateCalories == true) {
        _useAutomaticCalories = true;
        _dailyCalorieTargetController.text =
            userProfile?.recommendedDailyCalorieTarget?.toString() ?? '';
      } else {
        _useAutomaticCalories = false;
        _dailyCalorieTargetController.text =
            userProfile?.dailyCalorieTarget?.toString() ?? '';
      }

      // Set dropdown values if available
      if (userProfile?.gender != null) {
        _selectedGender = userProfile!.gender!;
      }
      if (userProfile?.activityLevel != null) {
        _selectedActivityLevel = userProfile!.activityLevel!;
      }
      if (userProfile?.goal != null) {
        _selectedGoal = userProfile!.goal!;
      }
    }
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _ageController.dispose();
    _dailyCalorieTargetController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);
    final currentUser = authViewModel.currentUser;

    if (currentUser != null) {
      // Create updated user model
      final updatedUser = UserModel(
        id: currentUser.id,
        email: currentUser.email,
        displayName: _displayNameController.text.trim(),
        photoURL: userViewModel.userProfile?.photoURL ?? currentUser.photoURL,
        createdAt: userViewModel.userProfile?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        weight: double.tryParse(_weightController.text.trim()),
        height: double.tryParse(_heightController.text.trim()),
        age: int.tryParse(_ageController.text.trim()),
        gender: _selectedGender,
        activityLevel: _selectedActivityLevel,
        goal: _selectedGoal,
        dailyCalorieTarget:
            _useAutomaticCalories
                ? null
                : int.tryParse(_dailyCalorieTargetController.text.trim()),
        isOnboardingCompleted:
            userViewModel.userProfile?.isOnboardingCompleted ?? true,
      );

      final success = await userViewModel.createOrUpdateUserProfile(
        updatedUser,
      );

      if (success && mounted) {
        setState(() {
          _isEditing = false;
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (mounted) {
        setState(() {
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              userViewModel.errorMessage.isNotEmpty
                  ? userViewModel.errorMessage
                  : 'Failed to update profile',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _updateAutomaticCalories() {
    if (!_useAutomaticCalories) return;

    // Try to calculate calories based on current form data
    try {
      final weight = double.tryParse(_weightController.text);
      final height = double.tryParse(_heightController.text);
      final age = int.tryParse(_ageController.text);

      if (weight != null && height != null && age != null) {
        final calculatedCalories = CalorieCalculator.calculateCompleteTarget(
          weight: weight,
          height: height,
          age: age,
          gender: _selectedGender,
          activityLevel: _selectedActivityLevel,
          goal: _selectedGoal,
        );

        if (calculatedCalories != null) {
          _dailyCalorieTargetController.text = calculatedCalories.toString();
        }
      }
    } catch (e) {
      // If calculation fails, keep the current value
    }
  }

  // Helper methods for automatic calorie calculation
  bool _canShowCalculationDetails() {
    final weight = double.tryParse(_weightController.text);
    final height = double.tryParse(_heightController.text);
    final age = int.tryParse(_ageController.text);

    return weight != null && height != null && age != null;
  }

  String _getCalculatedBMR() {
    final weight = double.tryParse(_weightController.text);
    final height = double.tryParse(_heightController.text);
    final age = int.tryParse(_ageController.text);

    if (weight == null || height == null || age == null) {
      return 'N/A';
    }

    final bmr = CalorieCalculator.calculateBMR(
      weight: weight,
      height: height,
      age: age,
      gender: _selectedGender,
    );

    return bmr != null ? '${bmr.round()} cal' : 'N/A';
  }

  String _getCalculatedTDEE() {
    final weight = double.tryParse(_weightController.text);
    final height = double.tryParse(_heightController.text);
    final age = int.tryParse(_ageController.text);

    if (weight == null || height == null || age == null) {
      return 'N/A';
    }

    final bmr = CalorieCalculator.calculateBMR(
      weight: weight,
      height: height,
      age: age,
      gender: _selectedGender,
    );

    if (bmr == null) return 'N/A';

    final tdee = CalorieCalculator.calculateTDEE(
      bmr: bmr,
      activityLevel: _selectedActivityLevel,
    );

    return tdee != null ? '${tdee.round()} cal' : 'N/A';
  }

  String _getGoalAdjustmentText() {
    switch (_selectedGoal) {
      case 'Lose Weight':
        return '-500 cal/day';
      case 'Gain Weight':
        return '+500 cal/day';
      case 'Maintain Weight':
      default:
        return '0 cal/day';
    }
  }

  String _getCalculatedTarget() {
    final weight = double.tryParse(_weightController.text);
    final height = double.tryParse(_heightController.text);
    final age = int.tryParse(_ageController.text);

    if (weight == null || height == null || age == null) {
      return 'N/A';
    }

    final target = CalorieCalculator.calculateCompleteTarget(
      weight: weight,
      height: height,
      age: age,
      gender: _selectedGender,
      activityLevel: _selectedActivityLevel,
      goal: _selectedGoal,
    );

    return target != null ? '$target cal/day' : 'N/A';
  }

  Widget _buildCalculationDetail(
    String label,
    String value, {
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 13,
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: isTotal ? Colors.deepOrange : Colors.grey[300],
              fontSize: 13,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthViewModel, UserViewModel>(
      builder: (context, authViewModel, userViewModel, child) {
        final currentUser = authViewModel.currentUser;
        final userProfile = userViewModel.userProfile;

        final userName =
            userProfile?.displayName ??
            currentUser?.displayName ??
            (currentUser != null && currentUser.email.isNotEmpty
                ? currentUser.email.split('@').first
                : 'User');

        return Scaffold(
          backgroundColor: Colors.black87,
          appBar: AppBar(
            backgroundColor: Colors.black87,
            foregroundColor: Colors.white,
            title: const Text('Profile'),
            elevation: 0,
            actions: [
              if (!_isEditing)
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isEditing = true;
                    });
                  },
                  icon: const Icon(Icons.edit),
                ),
              if (_isEditing)
                IconButton(
                  onPressed: _isSaving ? null : _saveProfile,
                  icon:
                      _isSaving
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                          : const Icon(Icons.save),
                ),
              if (_isEditing)
                IconButton(
                  onPressed:
                      _isSaving
                          ? null
                          : () {
                            setState(() {
                              _isEditing = false;
                              // Reset controllers to original values
                              _loadUserData();
                            });
                          },
                  icon: const Icon(Icons.cancel),
                ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),

                    // Profile Avatar
                    Stack(
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.grey[800],
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.deepOrange,
                              width: 3,
                            ),
                          ),
                          child:
                              userProfile?.photoURL != null
                                  ? ClipOval(
                                    child: Image.network(
                                      userProfile!.photoURL!,
                                      width: 120,
                                      height: 120,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const Icon(
                                                Icons.person,
                                                color: Colors.white,
                                                size: 60,
                                              ),
                                    ),
                                  )
                                  : const Icon(
                                    Icons.person,
                                    color: Colors.white,
                                    size: 60,
                                  ),
                        ),
                        if (_isEditing)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Colors.deepOrange,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // User Name Display
                    Text(
                      userName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      currentUser?.email ?? 'No email',
                      style: TextStyle(color: Colors.grey[400], fontSize: 16),
                    ),

                    // Display BMI if available
                    if (userProfile?.bmi != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'BMI: ${userProfile!.bmi!.toStringAsFixed(1)} - ${userProfile.bmiCategory}',
                        style: TextStyle(
                          color: _getBmiColor(userProfile.bmi!),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],

                    const SizedBox(height: 40),

                    // Profile Form
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Personal Info Section
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.grey[900],
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Personal Information',
                                  style: TextStyle(
                                    color: Colors.grey[300],
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // Display Name Field
                                _buildTextField(
                                  label: 'Display Name',
                                  controller: _displayNameController,
                                  hint: 'Enter your display name',
                                ),

                                // Age Field
                                _buildTextField(
                                  label: 'Age',
                                  controller: _ageController,
                                  hint: 'Enter your age',
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) {
                                    if (_useAutomaticCalories && _isEditing) {
                                      _updateAutomaticCalories();
                                    }
                                  },
                                ),

                                // Gender Field
                                _buildDropdownField(
                                  label: 'Gender',
                                  value: _selectedGender,
                                  items:
                                      _genders
                                          .map(
                                            (gender) => DropdownMenuItem(
                                              value: gender,
                                              child: Text(gender),
                                            ),
                                          )
                                          .toList(),
                                  onChanged: (value) {
                                    if (value != null && _isEditing) {
                                      setState(() {
                                        _selectedGender = value;
                                      });
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Physical Info Section
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.grey[900],
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Physical Information',
                                  style: TextStyle(
                                    color: Colors.grey[300],
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // Weight Field
                                _buildTextField(
                                  label: 'Weight (kg)',
                                  controller: _weightController,
                                  hint: 'Enter your weight in kg',
                                  keyboardType: TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                                  onChanged: (value) {
                                    if (_useAutomaticCalories && _isEditing) {
                                      _updateAutomaticCalories();
                                    }
                                  },
                                ),

                                // Height Field
                                _buildTextField(
                                  label: 'Height (cm)',
                                  controller: _heightController,
                                  hint: 'Enter your height in cm',
                                  keyboardType: TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                                  onChanged: (value) {
                                    if (_useAutomaticCalories && _isEditing) {
                                      _updateAutomaticCalories();
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Fitness Goals Section
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.grey[900],
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Fitness Goals',
                                  style: TextStyle(
                                    color: Colors.grey[300],
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // Activity Level Field
                                _buildDropdownField(
                                  label: 'Activity Level',
                                  value: _selectedActivityLevel,
                                  items:
                                      _activityLevels
                                          .map(
                                            (level) => DropdownMenuItem(
                                              value: level,
                                              child: Text(level),
                                            ),
                                          )
                                          .toList(),
                                  onChanged: (value) {
                                    if (value != null && _isEditing) {
                                      setState(() {
                                        _selectedActivityLevel = value;
                                        if (_useAutomaticCalories) {
                                          _updateAutomaticCalories();
                                        }
                                      });
                                    }
                                  },
                                ),

                                // Goal Field
                                _buildDropdownField(
                                  label: 'Goal',
                                  value: _selectedGoal,
                                  items:
                                      _goals
                                          .map(
                                            (goal) => DropdownMenuItem(
                                              value: goal,
                                              child: Text(goal),
                                            ),
                                          )
                                          .toList(),
                                  onChanged: (value) {
                                    if (value != null && _isEditing) {
                                      setState(() {
                                        _selectedGoal = value;
                                        if (_useAutomaticCalories) {
                                          _updateAutomaticCalories();
                                        }
                                      });
                                    }
                                  },
                                ),

                                // Daily Calorie Target Section
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Automatic Toggle
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            'Daily Calorie Target',
                                            style: TextStyle(
                                              color: Colors.grey[300],
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        if (_isEditing) ...[
                                          const SizedBox(width: 10),
                                          Switch.adaptive(
                                            value: _useAutomaticCalories,
                                            onChanged: (value) {
                                              setState(() {
                                                _useAutomaticCalories = value;
                                                if (value) {
                                                  _updateAutomaticCalories();
                                                }
                                              });
                                            },
                                            activeColor: Colors.deepOrange,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Auto',
                                            style: TextStyle(
                                              color:
                                                  _useAutomaticCalories
                                                      ? Colors.deepOrange
                                                      : Colors.grey[500],
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 8),

                                    // Calorie Target Field
                                    TextFormField(
                                      controller: _dailyCalorieTargetController,
                                      enabled:
                                          _isEditing && !_useAutomaticCalories,
                                      keyboardType: TextInputType.number,
                                      style: TextStyle(
                                        color:
                                            (_isEditing &&
                                                    !_useAutomaticCalories)
                                                ? Colors.white
                                                : Colors.grey[400],
                                        fontSize: 16,
                                      ),
                                      decoration: InputDecoration(
                                        hintText:
                                            _useAutomaticCalories
                                                ? 'Automatically calculated'
                                                : 'Enter your daily calorie target',
                                        hintStyle: TextStyle(
                                          color: Colors.grey[500],
                                          fontSize: 14,
                                        ),
                                        filled: true,
                                        fillColor:
                                            _isEditing && !_useAutomaticCalories
                                                ? Colors.grey[800]
                                                : Colors.grey[850],
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 16,
                                            ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          borderSide: BorderSide.none,
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          borderSide: BorderSide.none,
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          borderSide: const BorderSide(
                                            color: Colors.deepOrange,
                                            width: 2,
                                          ),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          borderSide: const BorderSide(
                                            color: Colors.red,
                                            width: 2,
                                          ),
                                        ),
                                        focusedErrorBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          borderSide: const BorderSide(
                                            color: Colors.red,
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                      validator: (value) {
                                        if (!_useAutomaticCalories &&
                                            (value == null ||
                                                value.trim().isEmpty)) {
                                          return 'Please enter a daily calorie target';
                                        }
                                        if (!_useAutomaticCalories &&
                                            int.tryParse(value!.trim()) ==
                                                null) {
                                          return 'Please enter a valid number';
                                        }
                                        if (!_useAutomaticCalories &&
                                            int.tryParse(value!.trim())! <= 0) {
                                          return 'Calories must be greater than 0';
                                        }
                                        return null;
                                      },
                                    ),

                                    // Calculation Details
                                    if (_useAutomaticCalories &&
                                        _canShowCalculationDetails()) ...[
                                      const SizedBox(height: 12),
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[850],
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: Colors.deepOrange
                                                .withOpacity(0.3),
                                            width: 1,
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Calculation Breakdown',
                                              style: TextStyle(
                                                color: Colors.deepOrange,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            _buildCalculationDetail(
                                              'BMR (Base Metabolic Rate)',
                                              _getCalculatedBMR(),
                                            ),
                                            _buildCalculationDetail(
                                              'TDEE (Total Daily Energy)',
                                              _getCalculatedTDEE(),
                                            ),
                                            _buildCalculationDetail(
                                              'Goal Adjustment',
                                              _getGoalAdjustmentText(),
                                            ),
                                            const Divider(
                                              color: Colors.grey,
                                              height: 16,
                                            ),
                                            _buildCalculationDetail(
                                              'Daily Target',
                                              _getCalculatedTarget(),
                                              isTotal: true,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Account Information
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.grey[900],
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Account Information',
                                  style: TextStyle(
                                    color: Colors.grey[300],
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                _buildReadOnlyInfoRow(
                                  'Email',
                                  currentUser?.email ?? '',
                                ),
                                if (userProfile?.createdAt != null)
                                  _buildReadOnlyInfoRow(
                                    'Joined',
                                    _formatDate(userProfile!.createdAt!),
                                  ),
                                if (userProfile?.updatedAt != null)
                                  _buildReadOnlyInfoRow(
                                    'Last updated',
                                    _formatDate(userProfile!.updatedAt!),
                                  ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 40),

                          // Logout Button
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: ElevatedButton(
                              onPressed: () async {
                                // Show confirmation dialog
                                final shouldLogout =
                                    await showDialog<bool>(
                                      context: context,
                                      builder:
                                          (context) => AlertDialog(
                                            backgroundColor: Colors.grey[900],
                                            title: const Text(
                                              'Logout',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            content: const Text(
                                              'Are you sure you want to logout?',
                                              style: TextStyle(
                                                color: Colors.white70,
                                              ),
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed:
                                                    () => Navigator.of(
                                                      context,
                                                    ).pop(false),
                                                child: Text(
                                                  'Cancel',
                                                  style: TextStyle(
                                                    color: Colors.grey[400],
                                                  ),
                                                ),
                                              ),
                                              TextButton(
                                                onPressed:
                                                    () => Navigator.of(
                                                      context,
                                                    ).pop(true),
                                                child: const Text(
                                                  'Logout',
                                                  style: TextStyle(
                                                    color: Colors.deepOrange,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                    ) ??
                                    false;

                                if (shouldLogout && mounted) {
                                  await authViewModel.signOut();
                                  // Navigate to login screen or home after logout
                                  if (mounted) {
                                    Navigator.of(
                                      context,
                                    ).pushNamedAndRemoveUntil(
                                      '/',
                                      (route) => false,
                                    );
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepOrange,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Logout',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 40),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Calorie Calculation Details
                    if (_isEditing && _canShowCalculationDetails()) ...[
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Calorie Calculation Details',
                              style: TextStyle(
                                color: Colors.grey[300],
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 20),

                            // BMR
                            _buildCalculationDetail(
                              'Estimated BMR',
                              _getCalculatedBMR(),
                            ),

                            // TDEE
                            _buildCalculationDetail(
                              'Estimated TDEE',
                              _getCalculatedTDEE(),
                            ),

                            // Goal Adjustment
                            _buildCalculationDetail(
                              'Goal Adjustment',
                              _getGoalAdjustmentText(),
                            ),

                            // Calorie Target
                            _buildCalculationDetail(
                              'Calorie Target',
                              _getCalculatedTarget(),
                              isTotal: true,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Helper method to build text fields
  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? hint,
    TextInputType? keyboardType,
    void Function(String)? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: controller,
            enabled: _isEditing,
            keyboardType: keyboardType,
            onChanged: onChanged,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey[500]),
              fillColor: Colors.grey[850],
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            validator: (value) {
              if (label == 'Display Name' && (value == null || value.isEmpty)) {
                return 'Please enter your display name';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  // Helper method to build dropdown fields
  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<DropdownMenuItem<String>> items,
    required void Function(String?)? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey[850],
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonFormField<String>(
              value: value,
              items: items,
              onChanged: _isEditing ? onChanged : null,
              dropdownColor: Colors.grey[900],
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(border: InputBorder.none),
              iconEnabledColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadOnlyInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  // Helper method to get color based on BMI
  Color _getBmiColor(double bmi) {
    if (bmi < 18.5) {
      return Colors.blue;
    } else if (bmi < 25) {
      return Colors.green;
    } else if (bmi < 30) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}
