import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:caltrack/viewmodels/auth_view_model.dart';
import 'package:caltrack/viewmodels/user_view_model.dart';
import 'package:caltrack/viewmodels/food_log_view_model.dart';
import 'package:caltrack/view/profile_screen.dart';
import 'food_log/food_log_screen.dart';
import 'food_log/add_food_screen.dart';
import 'package:caltrack/models/food_entry.dart';
import 'barcode/barcode_scanner_screen.dart';

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
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User greeting section with avatar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                greeting,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                              Text(
                                userName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 50,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ProfileScreen(),
                                ),
                              );
                            },
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.grey[800],
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.deepOrange.withOpacity(0.3),
                                  width: 2,
                                ),
                              ),
                              child:
                                  userProfile?.photoURL != null
                                      ? ClipOval(
                                        child: Image.network(
                                          userProfile!.photoURL!,
                                          width: 50,
                                          height: 50,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  const Icon(
                                                    Icons.person,
                                                    color: Colors.white,
                                                  ),
                                        ),
                                      )
                                      : const Icon(
                                        Icons.person,
                                        color: Colors.white,
                                      ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Swipable cards: My Plan for Today & Calories Progress
                    SizedBox(
                      height: 185, // Increased height to fix overflow
                      child: PageView(
                        controller: PageController(viewportFraction: 0.92),
                        children: [
                          // My Plan for Today Card
                          Container(
                            margin: const EdgeInsets.only(right: 12),
                            padding: const EdgeInsets.all(
                              20,
                            ), // Reduced padding for better fit
                            decoration: BoxDecoration(
                              color: Colors.deepOrange,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                // Left side - text
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        'My Plan\nFor Today',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        userProfile?.effectiveDailyCalorieTarget !=
                                                null
                                            ? 'Daily Target: $dailyTarget cal'
                                            : 'Complete profile to set target',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontStyle:
                                              userProfile?.effectiveDailyCalorieTarget ==
                                                      null
                                                  ? FontStyle.italic
                                                  : FontStyle.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Right side - progress circle or setup prompt
                                userProfile?.effectiveDailyCalorieTarget != null
                                    ? Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        SizedBox(
                                          width: 100,
                                          height: 100,
                                          child: CircularProgressIndicator(
                                            value: percentage / 100,
                                            strokeWidth: 12,
                                            backgroundColor:
                                                Colors.deepOrange.shade800,
                                            valueColor:
                                                const AlwaysStoppedAnimation<
                                                  Color
                                                >(Colors.white),
                                          ),
                                        ),
                                        Text(
                                          '$percentage%',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 32,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    )
                                    : GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) =>
                                                    const ProfileScreen(),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        width: 100,
                                        height: 100,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 2,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.settings,
                                          color: Colors.white,
                                          size: 40,
                                        ),
                                      ),
                                    ),
                              ],
                            ),
                          ),
                          // Calories Eaten / Goal Card
                          Container(
                            margin: const EdgeInsets.only(left: 12),
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.grey[900],
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Calories Eaten',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        '$currentCalories / $dailyTarget cal',
                                        style: const TextStyle(
                                          color: Colors.deepOrange,
                                          fontSize: 22,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      LinearProgressIndicator(
                                        value: (currentCalories / dailyTarget)
                                            .clamp(0.0, 1.0),
                                        backgroundColor: Colors.grey[800],
                                        valueColor:
                                            const AlwaysStoppedAnimation<Color>(
                                              Colors.deepOrange,
                                            ),
                                        minHeight: 10,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Icon(
                                  Icons.local_fire_department,
                                  color: Colors.deepOrange,
                                  size: 48,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Food Tracking Coming Soon Section
                    const Text(
                      'Food Tracking',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Food tracking feature
                    TextButton.icon(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AddFoodScreen(),
                          ),
                        );
                        if (result is FoodEntry) {
                          // Add the entry to the food log
                          final foodLogViewModel =
                              Provider.of<FoodLogViewModel>(
                                context,
                                listen: false,
                              );
                          final authViewModel = Provider.of<AuthViewModel>(
                            context,
                            listen: false,
                          );
                          foodLogViewModel.addEntry(result);
                          if (authViewModel.currentUser != null) {
                            await foodLogViewModel.fetchTodayCalories(
                              authViewModel.currentUser!.id,
                            ); // Refresh calories
                          }
                        }
                      },
                      icon: const Icon(Icons.add, color: Colors.deepOrange),
                      label: const Text(
                        'Add Food', // Changed text to better reflect the action
                        style: TextStyle(color: Colors.deepOrange),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Recent Food Entries Carousel
                    Consumer<FoodLogViewModel>(
                      builder: (context, foodLogViewModel, child) {
                        print(
                          "Building carousel: ${foodLogViewModel.entries.length} entries",
                        ); // Debug log
                        final entries = foodLogViewModel.entries;
                        if (entries.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              'No recent entries. Add your first meal!',
                              style: TextStyle(color: Colors.grey[400]),
                            ),
                          );
                        }

                        return SizedBox(
                          height: 120,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount:
                                entries.length > 5
                                    ? 5
                                    : entries
                                        .length, // Show max 5 recent entries
                            itemBuilder: (context, index) {
                              final entry = entries[index];
                              return Container(
                                width: 160,
                                margin: const EdgeInsets.only(right: 16),
                                decoration: BoxDecoration(
                                  color: Colors.grey[850],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.deepOrange.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        entry.name,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        '${entry.calories} kcal',
                                        style: const TextStyle(
                                          color: Colors.deepOrange,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      if (entry.date != null)
                                        Text(
                                          '${entry.date!.day}/${entry.date!.month}',
                                          style: TextStyle(
                                            color: Colors.grey[400],
                                            fontSize: 12,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const FoodLogScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'View all entries →',
                          style: TextStyle(color: Colors.deepOrange),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // User Profile Section
                    const Text(
                      'Profile Information',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // User Info Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          _buildInfoRow(
                            'Email',
                            currentUser?.email ?? 'Not available',
                          ),
                          const SizedBox(height: 16),
                          _buildInfoRow(
                            'Display Name',
                            userProfile?.displayName ??
                                currentUser?.displayName ??
                                'Not set',
                          ),
                          const SizedBox(height: 16),
                          _buildInfoRow(
                            'Member Since',
                            userProfile?.createdAt != null
                                ? _formatDate(userProfile!.createdAt!)
                                : 'Recently joined',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),

          // Bottom Navigation Bar
          bottomNavigationBar: BottomNavigationBar(
            backgroundColor: Colors.black,
            unselectedItemColor: Colors.grey,
            selectedItemColor: Colors.white,
            type: BottomNavigationBarType.fixed,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            items: [
              BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  'assets/icons/House Blank.svg',
                  height: 24,
                  width: 24,
                  colorFilter: const ColorFilter.mode(
                    Colors.grey,
                    BlendMode.srcIn,
                  ),
                ),
                activeIcon: SvgPicture.asset(
                  'assets/icons/House Blank.svg',
                  height: 24,
                  width: 24,
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  'assets/icons/search.svg',
                  height: 24,
                  width: 24,
                  colorFilter: const ColorFilter.mode(
                    Colors.grey,
                    BlendMode.srcIn,
                  ),
                ),
                activeIcon: SvgPicture.asset(
                  'assets/icons/search.svg',
                  height: 24,
                  width: 24,
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
                label: 'Search',
              ),
              BottomNavigationBarItem(
                icon: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BarcodeScannerScreen(),
                      ),
                    );
                  },
                  child: SvgPicture.asset(
                    'assets/icons/QR Scan.svg',
                    height: 24,
                    width: 24,
                    colorFilter: const ColorFilter.mode(
                      Colors.grey,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                activeIcon: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BarcodeScannerScreen(),
                      ),
                    );
                  },
                  child: SvgPicture.asset(
                    'assets/icons/Qr Scan.svg',
                    height: 24,
                    width: 24,
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                label: 'Scan',
              ),
              BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  'assets/icons/folder.svg',
                  height: 24,
                  width: 24,
                  colorFilter: const ColorFilter.mode(
                    Colors.grey,
                    BlendMode.srcIn,
                  ),
                ),
                activeIcon: SvgPicture.asset(
                  'assets/icons/folder.svg',
                  height: 24,
                  width: 24,
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
                label: 'Files',
              ),
            ],
          ),
        );
      },
    );
  }

  // Helper widget to build information rows
  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ),
      ],
    );
  }

  // Helper method to format date
  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
