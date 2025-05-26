import 'package:flutter/foundation.dart';
import 'package:caltrack/repositories/user_repository.dart';
import 'package:caltrack/models/user_model.dart';

class UserOnboardingViewModel extends ChangeNotifier {
  final UserRepository _userRepository;

  UserOnboardingViewModel({UserRepository? userRepository})
    : _userRepository = userRepository ?? UserRepository();

  bool _isLoading = false;
  String _error = '';
  bool _isCompleted = false;

  // Form fields
  String _displayName = '';
  String _age = '';
  String _gender = '';
  String _height = '';
  String _weight = '';
  String _activityLevel = '';
  String _goal = '';

  // Getters
  bool get isLoading => _isLoading;
  String get error => _error;
  bool get isCompleted => _isCompleted;
  String get displayName => _displayName;
  String get age => _age;
  String get gender => _gender;
  String get height => _height;
  String get weight => _weight;
  String get activityLevel => _activityLevel;
  String get goal => _goal;

  // Setters
  void setDisplayName(String value) {
    _displayName = value;
    notifyListeners();
  }

  void setAge(String value) {
    _age = value;
    notifyListeners();
  }

  void setGender(String value) {
    _gender = value;
    notifyListeners();
  }

  void setHeight(String value) {
    _height = value;
    notifyListeners();
  }

  void setWeight(String value) {
    _weight = value;
    notifyListeners();
  }

  void setActivityLevel(String value) {
    _activityLevel = value;
    notifyListeners();
  }

  void setGoal(String value) {
    _goal = value;
    notifyListeners();
  }

  // Validation
  bool get isFormValid {
    return _displayName.trim().isNotEmpty &&
        _age.trim().isNotEmpty &&
        _gender.isNotEmpty &&
        _height.trim().isNotEmpty &&
        _weight.trim().isNotEmpty &&
        _activityLevel.isNotEmpty &&
        _goal.isNotEmpty;
  }

  // Calculate daily calorie target based on user data
  int calculateDailyCalorieTarget() {
    try {
      double weightNum = double.parse(_weight);
      double heightNum = double.parse(_height);
      int ageNum = int.parse(_age);

      // BMR calculation using Mifflin-St Jeor Equation
      double bmr;
      if (_gender.toLowerCase() == 'male') {
        bmr = 10 * weightNum + 6.25 * heightNum - 5 * ageNum + 5;
      } else {
        bmr = 10 * weightNum + 6.25 * heightNum - 5 * ageNum - 161;
      }

      // Activity level multiplier
      double activityMultiplier;
      switch (_activityLevel) {
        case 'Sedentary':
          activityMultiplier = 1.2;
          break;
        case 'Lightly Active':
          activityMultiplier = 1.375;
          break;
        case 'Moderately Active':
          activityMultiplier = 1.55;
          break;
        case 'Very Active':
          activityMultiplier = 1.725;
          break;
        case 'Extremely Active':
          activityMultiplier = 1.9;
          break;
        default:
          activityMultiplier = 1.2;
      }

      double tdee = bmr * activityMultiplier;

      // Goal adjustment
      switch (_goal) {
        case 'Lose Weight':
          tdee -= 500; // 500 calorie deficit
          break;
        case 'Gain Weight':
          tdee += 500; // 500 calorie surplus
          break;
        case 'Maintain Weight':
        default:
          break;
      }

      return tdee.round();
    } catch (e) {
      return 2000; // Default fallback
    }
  }

  // Save user profile
  Future<void> saveUserProfile(String userId, String email) async {
    if (!isFormValid) {
      _error = 'Please fill in all required fields';
      notifyListeners();
      return;
    }

    _setLoading(true);
    try {
      final dailyCalorieTarget = calculateDailyCalorieTarget();

      final user = UserModel(
        id: userId,
        email: email,
        displayName: _displayName,
      );

      // Create user profile with additional onboarding data
      await _userRepository.createUser(user);

      // Update with additional fields
      await _userRepository.updateUserFields(userId, {
        'age': int.tryParse(_age),
        'gender': _gender,
        'height': double.tryParse(_height),
        'weight': double.tryParse(_weight),
        'activityLevel': _activityLevel,
        'goal': _goal,
        'dailyCalorieTarget': dailyCalorieTarget,
        'isOnboardingCompleted': true,
      });

      _isCompleted = true;
      _error = '';
    } catch (e) {
      _error = 'Failed to save profile: $e';
    } finally {
      _setLoading(false);
    }
  }

  // Check if user needs onboarding
  Future<bool> needsOnboarding(String userId) async {
    try {
      final user = await _userRepository.getUser(userId);
      if (user == null) return true;

      final userData = await _userRepository.getUser(userId);
      // Check if onboarding is completed (you'll need to add this field to UserModel)
      return userData == null;
    } catch (e) {
      return true;
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }
}
