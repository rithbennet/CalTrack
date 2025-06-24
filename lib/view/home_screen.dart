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
      // This call remains to support the existing `todayCalories` property
      foodLogViewModel.fetchTodayCalories(authViewModel.currentUser!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    // MODIFIED: Use Consumer3 to efficiently listen to all needed ViewModels
    return Consumer3<AuthViewModel, UserViewModel, FoodLogViewModel>(
      builder: (
        context,
        authViewModel,
        userViewModel,
        foodLogViewModel,
        child,
      ) {
        // Get user data with fallbacks (Unchanged)
        final currentUser = authViewModel.currentUser;
        final userProfile = userViewModel.userProfile;

        // Get username and ensure it's not too long (Unchanged)
        String userName =
            userProfile?.displayName ??
            currentUser?.displayName ??
            (currentUser != null && currentUser.email.isNotEmpty
                ? currentUser.email.split('@').first
                : 'User');

        const int maxUsernameLength = 15;
        if (userName.length > maxUsernameLength) {
          userName = '${userName.substring(0, maxUsernameLength)}...';
        }

        final greeting = userViewModel.getGreeting();

        // Get actual calorie target from user profile (Unchanged)
        final dailyTarget = userProfile?.effectiveDailyCalorieTarget ?? 2000;
        // Using the existing `todayCalories` property as requested (Unchanged)
        final currentCalories = foodLogViewModel.todayCalories;
        final percentage = ((currentCalories / dailyTarget) * 100).round();

        // ADDED: Get the new summary data from the FoodLogViewModel
        final todaySummary = foodLogViewModel.todaySummary;
        final weeklySummary = foodLogViewModel.weeklySummary;

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
                    // User greeting section with avatar (Unchanged)
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

                    // MODIFIED: Pass the new summary data to the carousel
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
                      // ADDED: Pass the new required parameters
                      todaySummary: todaySummary,
                      weeklySummary: weeklySummary,
                    ),

                    const SizedBox(height: 32),

                    // Food Tracking Section (Unchanged)
                    const FoodTrackingSection(),

                    const SizedBox(height: 32),

                    // User Profile Section (Unchanged)
                    const SectionHeader(title: 'Profile Information'),
                    const SizedBox(height: 16),

                    // User Info Card (Unchanged)
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

          // Bottom Navigation Bar (Unchanged)
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
