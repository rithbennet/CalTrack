import 'package:flutter/foundation.dart';
import 'package:caltrack/models/user_model.dart';
import 'package:caltrack/repositories/user_repository.dart';

class UserViewModel extends ChangeNotifier {
  final UserRepository _userRepository = UserRepository();

  UserModel? _userProfile;
  bool _isLoading = false;
  String _errorMessage = '';

  // Getters
  UserModel? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  // Get user profile from Firestore
  Future<void> loadUserProfile(String userId) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _userProfile = await _userRepository.getUser(userId);
    } catch (e) {
      _errorMessage = 'Failed to load user profile: $e';
      _userProfile = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update user profile
  Future<bool> updateUserProfile(UserModel user) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      await _userRepository.updateUser(user);
      _userProfile = user;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update user profile: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Create or update user profile (upsert)
  Future<bool> createOrUpdateUserProfile(UserModel user) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      await _userRepository.createOrUpdateUser(user);
      _userProfile = user;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to save user profile: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Stream user profile for real-time updates
  Stream<UserModel?> streamUserProfile(String userId) {
    return _userRepository.streamUser(userId);
  }

  // Clear error message
  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  // Clear user profile
  void clearUserProfile() {
    _userProfile = null;
    _errorMessage = '';
    notifyListeners();
  }

  // Get display name with fallback
  String getDisplayName() {
    if (_userProfile?.displayName != null &&
        _userProfile!.displayName!.isNotEmpty) {
      return _userProfile!.displayName!;
    }
    if (_userProfile?.email != null) {
      return _userProfile!.email.split('@').first;
    }
    return 'User';
  }

  // Get greeting based on time of day
  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning!';
    } else if (hour < 17) {
      return 'Good Afternoon!';
    } else {
      return 'Good Evening!';
    }
  }
}
