import 'package:caltrack/viewmodels/food_log_view_model.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:caltrack/view/auth_wrapper.dart';
import 'package:caltrack/view/home_screen.dart';
import 'package:caltrack/viewmodels/auth_view_model.dart';
import 'package:caltrack/viewmodels/user_view_model.dart';
import 'package:caltrack/theme/app_theme.dart';
import 'package:caltrack/viewmodels/user_onboarding_viewmodel.dart';
import 'package:caltrack/viewmodels/barcode_view_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables before initializing Firebase
  await dotenv.load(fileName: ".env");

  // Initialize Firebase with the options from environment variables
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => UserViewModel()),
        ChangeNotifierProvider(create: (_) => UserOnboardingViewModel()),
        ChangeNotifierProvider(create: (_) => FoodLogViewModel()),
        ChangeNotifierProvider(create: (_) => BarcodeViewModel()),
        // Add other providers here
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CalTrack',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode:
          ThemeMode.dark, // Use system theme or change to .light or .dark
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthWrapper(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
