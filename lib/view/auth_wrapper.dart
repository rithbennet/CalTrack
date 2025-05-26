import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:caltrack/view/auth/login_screen.dart';
import 'package:caltrack/view/home_screen.dart';
import 'package:caltrack/view/user_onboarding_screen.dart';
import 'package:caltrack/viewmodels/auth_view_model.dart';
import 'package:caltrack/repositories/user_repository.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);

    // If the current user is null, show the login screen
    if (authViewModel.currentUser == null ||
        !authViewModel.currentUser!.isAuthenticated) {
      return const LoginScreen();
    }

    // If user is authenticated, check if they have completed onboarding
    return FutureBuilder<bool>(
      future: _hasCompletedOnboarding(authViewModel.currentUser!.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Colors.black87,
            body: Center(
              child: CircularProgressIndicator(color: Colors.deepOrange),
            ),
          );
        }

        if (snapshot.hasError) {
          return const Scaffold(
            backgroundColor: Colors.black87,
            body: Center(
              child: Text(
                'Error checking user profile',
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
        }

        final hasCompletedOnboarding = snapshot.data ?? false;

        if (!hasCompletedOnboarding) {
          return const UserOnboardingScreen();
        }

        return const HomeScreen();
      },
    );
  }

  Future<bool> _hasCompletedOnboarding(String userId) async {
    try {
      final userRepository = UserRepository();
      final userProfile = await userRepository.getUser(userId);
      // Check if user has essential profile data
      return userProfile != null &&
          userProfile.displayName != null &&
          userProfile.displayName!.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
