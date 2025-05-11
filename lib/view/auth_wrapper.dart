import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:caltrack/view/auth/login_screen.dart';
import 'package:caltrack/view/home_screen.dart';
import 'package:caltrack/viewmodels/auth_view_model.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);

    // If the current user is null, show the login screen
    // Otherwise show the home screen
    if (authViewModel.currentUser == null ||
        !authViewModel.currentUser!.isAuthenticated) {
      return const LoginScreen();
    }

    return const HomeScreen();
  }
}
