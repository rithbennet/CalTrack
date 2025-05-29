import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:caltrack/viewmodels/auth_view_model.dart';
import 'package:caltrack/viewmodels/user_view_model.dart';
import 'package:caltrack/viewmodels/food_log_view_model.dart';
import 'package:caltrack/view/profile_screen.dart';
// Import custom components
import 'components/home/user_greeting_header.dart';
import 'components/home/progress_cards_carousel.dart';
import 'components/home/food_tracking_section.dart';
import 'components/home/section_header.dart';
import 'components/home/user_info_card.dart';
import 'components/bottom_nav_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
    final foodLogViewModel = Provider.of<FoodLogViewModel>(
      context,
      listen: false,
    );

    if (authViewModel.currentUser != null) {
      userViewModel.loadUserProfile(authViewModel.currentUser!.id);
      // Initialize food entries stream for the current user
      foodLogViewModel.initializeForUser(authViewModel.currentUser!.id);
      foodLogViewModel.fetchTodayCalories(
        authViewModel.currentUser!.id,
      ); // Fetch today's calories
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthViewModel, UserViewModel>(
      builder: (context, authViewModel, userViewModel, child) {
        // Get user data with fallbacks
        final currentUser = authViewModel.currentUser;
        final userProfile = userViewModel.userProfile;

        // Get username and ensure it's not too long
        String userName =
            userProfile?.displayName ??
            currentUser?.displayName ??
            (currentUser != null && currentUser.email.isNotEmpty
                ? currentUser.email.split('@').first
                : 'User');

        // Limit username length to prevent layout issues
        const int maxUsernameLength = 15;
        if (userName.length > maxUsernameLength) {
          userName = '${userName.substring(0, maxUsernameLength)}...';
        }

        final greeting = userViewModel.getGreeting();

        // Get actual calorie target from user profile
        final dailyTarget = userProfile?.effectiveDailyCalorieTarget ?? 2000;
        final foodLogViewModel = Provider.of<FoodLogViewModel>(context);
        final currentCalories = foodLogViewModel.todayCalories;
        final percentage = ((currentCalories / dailyTarget) * 100).round();

        return Scaffold(
          backgroundColor: Colors.black87,
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User greeting section with avatar - Now using component
                    UserGreetingHeader(
                      greeting: greeting,
                      userName: userName,
                      userProfile: userProfile,
                      onAvatarTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ProfileScreen(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    // Swipable cards - Now using component
                    ProgressCardsCarousel(
                      userProfile: userProfile,
                      percentage: percentage,
                      currentCalories: currentCalories,
                      dailyTarget: dailyTarget,
                      onSetupTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ProfileScreen(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 32),

                    // Food Tracking Section - Using component
                    const FoodTrackingSection(),

                    const SizedBox(height: 32),

                    // User Profile Section - Using components
                    const SectionHeader(title: 'Profile Information'),
                    const SizedBox(height: 16),

                    // User Info Card - Using component
                    UserInfoCard(
                      currentUser: currentUser,
                      userProfile: userProfile,
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),

          // Bottom Navigation Bar
          bottomNavigationBar: BottomNavBar(
            currentIndex: 0, // Home screen is selected
            onTap: (index) {
              BottomNavBar.handleNavigation(context, index, currentIndex: 0);
            },
          ),
        );
      },
    );
  }
}
