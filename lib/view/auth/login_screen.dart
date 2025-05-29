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
          appBar: AppBar(
            title: const Text('Login'),
            elevation: 0,
            backgroundColor: Colors.transparent,
          ),
          resizeToAvoidBottomInset: true,
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 20.0,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20.0),
                    const Text(
                      'CalTrack',
                      style: TextStyle(
                        fontSize: 36.0,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10.0),
                    const Text(
                      'Track your calories and meet your goals',
                      style: TextStyle(fontSize: 16.0, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48.0),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12.0)),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 16.0,
                          horizontal: 16.0,
                        ),
                        prefixIcon: Icon(Icons.email_outlined),
                        floatingLabelBehavior: FloatingLabelBehavior.auto,
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
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12.0)),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 16.0,
                          horizontal: 16.0,
                        ),
                        prefixIcon: Icon(Icons.lock_outline),
                        floatingLabelBehavior: FloatingLabelBehavior.auto,
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
                                : const Text(
                                  'Forgot Password?',
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                      ),
                    ),
                    if (authViewModel.errorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Container(
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Text(
                            authViewModel.errorMessage,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ),
                    if (authViewModel.successMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Container(
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Text(
                            authViewModel.successMessage,
                            style: const TextStyle(color: Colors.green),
                          ),
                        ),
                      ),
                    const SizedBox(height: 8.0),
                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed:
                            authViewModel.isSigningIn
                                ? null
                                : () => _signIn(authViewModel),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          elevation: 0,
                        ),
                        child:
                            authViewModel.isSigningIn
                                ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.0,
                                  ),
                                )
                                : const Text(
                                  'Login',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                      ),
                    ),
                    const SizedBox(height: 24.0),
                    Row(
                      children: const [
                        Expanded(
                          child: Divider(thickness: 1, color: Colors.grey),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            "OR",
                            style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(thickness: 1, color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24.0),
                    SizedBox(
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed:
                            authViewModel.isSigningInWithGoogle
                                ? null
                                : () => _signInWithGoogle(authViewModel),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black87,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            side: const BorderSide(
                              color: Colors.grey,
                              width: 1,
                            ),
                          ),
                          elevation: 0,
                        ),
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
                                  height: 24.0,
                                  width: 24.0,
                                ),
                        label: const Text(
                          'Sign in with Google',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Don\'t have an account? ',
                          style: TextStyle(color: Colors.grey),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const RegisterScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            'Register',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
