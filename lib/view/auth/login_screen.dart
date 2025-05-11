import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:caltrack/view/auth/register_screen.dart';
import 'package:caltrack/viewmodels/auth_view_model.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn(AuthViewModel authViewModel) async {
    // Check rate limiting first
    if (authViewModel.isRateLimited) {
      return; // ViewModel will handle showing the rate limit message
    }

    if (_formKey.currentState!.validate()) {
      await authViewModel.signInWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      // No need to navigate - the app will handle state changes through the AuthViewModel
    }
  }

  Future<void> _signInWithGoogle(AuthViewModel authViewModel) async {
    await authViewModel.signInWithGoogle();
    // No need to navigate - the app will handle state changes through the AuthViewModel
  }

  Future<void> _resetPassword(AuthViewModel authViewModel) async {
    // Check if email is provided
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      // Use the clearMessages method first to clear any existing messages
      authViewModel.clearMessages();
      // Then set an error message through the ViewModel
      authViewModel.setErrorMessage(
        'Please enter your email address to reset password',
      );
      return;
    }

    await authViewModel.resetPassword(email);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, authViewModel, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('Login')),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'CalTrack',
                    style: TextStyle(
                      fontSize: 32.0,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48.0),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed:
                          authViewModel.isResettingPassword
                              ? null
                              : () => _resetPassword(authViewModel),
                      child:
                          authViewModel.isResettingPassword
                              ? const SizedBox(
                                height: 15,
                                width: 15,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.0,
                                ),
                              )
                              : const Text('Forgot Password?'),
                    ),
                  ),
                  if (authViewModel.errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        authViewModel.errorMessage,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  if (authViewModel.successMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        authViewModel.successMessage,
                        style: const TextStyle(color: Colors.green),
                      ),
                    ),
                  ElevatedButton(
                    onPressed:
                        authViewModel.isSigningIn
                            ? null
                            : () => _signIn(authViewModel),
                    child:
                        authViewModel.isSigningIn
                            ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.0,
                              ),
                            )
                            : const Text('Login'),
                  ),
                  const SizedBox(height: 16.0),
                  const Row(
                    children: [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text("OR"),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton.icon(
                    onPressed:
                        authViewModel.isSigningInWithGoogle
                            ? null
                            : () => _signInWithGoogle(authViewModel),
                    icon:
                        authViewModel.isSigningInWithGoogle
                            ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.0,
                              ),
                            )
                            : Image.network(
                              'https://developers.google.com/identity/images/g-logo.png',
                              height: 18.0,
                              width: 18.0,
                            ),
                    label: const Text('Sign in with Google'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterScreen(),
                        ),
                      );
                    },
                    child: const Text('Don\'t have an account? Register'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
