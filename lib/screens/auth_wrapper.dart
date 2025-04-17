import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:caltrack/screens/auth/login_screen.dart';
import 'package:caltrack/screens/home_screen.dart';
import 'package:caltrack/services/auth_service.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          User? user = snapshot.data;
          if (user == null) {
            return const LoginScreen();
          }
          return const HomeScreen();
        }

        // Show a loading indicator while waiting for authentication state
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}
