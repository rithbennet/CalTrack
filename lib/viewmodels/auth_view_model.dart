import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:caltrack/models/user_model.dart';
import 'package:caltrack/services/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _currentUser;
  bool _isLoading = false;
  bool _isSigningIn = false;
  bool _isSigningInWithGoogle = false;
  bool _isResettingPassword = false;
  bool _isRegistering = false;
  String _errorMessage = '';
  String _successMessage = '';

  // Login attempts tracking for rate limiting
  int _loginAttempts = 0;
  bool _isRateLimited = false;
  DateTime? _rateLimitEndTime;

  // Maximum failed login attempts before rate limiting
  static const int _maxLoginAttempts = 5;
  // Time in minutes to lock account after too many failed attempts
  static const int _rateLimitDurationMinutes = 15;

  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isSigningIn => _isSigningIn;
  bool get isSigningInWithGoogle => _isSigningInWithGoogle;
  bool get isResettingPassword => _isResettingPassword;
  bool get isRegistering => _isRegistering;
  String get errorMessage => _errorMessage;
  String get successMessage => _successMessage;
  bool get isRateLimited => _isRateLimited;
  DateTime? get rateLimitEndTime => _rateLimitEndTime;
  int get remainingAttempts => _maxLoginAttempts - _loginAttempts;

  // Constructor - initialize stream subscription
  AuthViewModel() {
    _authService.authStateChanges.listen((user) {
      _currentUser = UserModel.fromFirebaseUser(user);
      notifyListeners();
    });
  }

  // Method to handle error messages with specific Firebase error codes
  String _getErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found with this email. Please register first.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many unsuccessful login attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return 'Authentication failed: $code';
    }
  }

  // Check rate limiting status
  bool _checkRateLimit() {
    if (_isRateLimited) {
      final now = DateTime.now();
      if (_rateLimitEndTime != null && now.isBefore(_rateLimitEndTime!)) {
        final remainingMinutes =
            _rateLimitEndTime!.difference(now).inMinutes + 1;
        _errorMessage =
            'Too many failed login attempts. Please try again in $remainingMinutes minutes.';
        notifyListeners();
        return true;
      } else {
        // Reset rate limiting if the time has passed
        _isRateLimited = false;
        _loginAttempts = 0;
      }
    }
    return false;
  }

  // Sign in with email and password
  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    // Check if user is rate limited
    if (_checkRateLimit()) return false;

    _isSigningIn = true;
    _errorMessage = '';
    _successMessage = '';
    notifyListeners();

    try {
      await _authService.signInWithEmailAndPassword(email, password);
      // Reset login attempts on successful login
      _loginAttempts = 0;
      _isSigningIn = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      // Increment login attempts
      _loginAttempts++;

      // Check if rate limiting should be applied
      if (_loginAttempts >= _maxLoginAttempts) {
        _isRateLimited = true;
        _rateLimitEndTime = DateTime.now().add(
          Duration(minutes: _rateLimitDurationMinutes),
        );
        _errorMessage =
            'Too many failed login attempts. Your account is locked for $_rateLimitDurationMinutes minutes.';
      } else {
        _errorMessage = _getErrorMessage(e.code);
      }

      _isSigningIn = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _isSigningIn = false;
      notifyListeners();
      return false;
    }
  }

  // Register with email and password
  Future<bool> registerWithEmailAndPassword(
    String email,
    String password,
  ) async {
    _isRegistering = true;
    _errorMessage = '';
    _successMessage = '';
    notifyListeners();

    try {
      await _authService.registerWithEmailAndPassword(email, password);
      _isRegistering = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getErrorMessage(e.code);
      _isRegistering = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _isRegistering = false;
      notifyListeners();
      return false;
    }
  }

  // Sign in with Google
  Future<bool> signInWithGoogle() async {
    _isSigningInWithGoogle = true;
    _errorMessage = '';
    notifyListeners();

    try {
      await _authService.signInWithGoogle();
      _isSigningInWithGoogle = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isSigningInWithGoogle = false;
      notifyListeners();
      return false;
    }
  }

  // Reset password
  Future<bool> resetPassword(String email) async {
    _isResettingPassword = true;
    _errorMessage = '';
    _successMessage = '';
    notifyListeners();

    try {
      await _authService.resetPassword(email);
      _successMessage = 'Password reset email sent to $email';
      _isResettingPassword = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getErrorMessage(e.code);
      _isResettingPassword = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _isResettingPassword = false;
      notifyListeners();
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.signOut();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear messages
  void clearMessages() {
    _errorMessage = '';
    _successMessage = '';
    notifyListeners();
  }

  // Set error message
  void setErrorMessage(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  // Set success message
  void setSuccessMessage(String message) {
    _successMessage = message;
    notifyListeners();
  }
}
