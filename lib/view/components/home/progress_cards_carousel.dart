import 'package:flutter/material.dart';
import 'package:caltrack/models/user_model.dart';

class ProgressCardsCarousel extends StatelessWidget {
  final UserModel? userProfile;
  final int percentage;
  final int currentCalories;
  final int dailyTarget;
  final VoidCallback onSetupTap;

  const ProgressCardsCarousel({
    super.key,
    this.userProfile,
    required this.percentage,
    required this.currentCalories,
    required this.dailyTarget,
    required this.onSetupTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 185,
      child: PageView(
        controller: PageController(viewportFraction: 0.92),
        children: [_buildPlanCard(), _buildCaloriesCard()],
      ),
    );
  }

  Widget _buildPlanCard() {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.deepOrange,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Left side - text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'My Plan\nFor Today',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  userProfile?.effectiveDailyCalorieTarget != null
                      ? 'Target: ${userProfile!.effectiveDailyCalorieTarget} cal'
                      : 'Complete profile to set target',
                  style: const TextStyle(color: Colors.white, fontSize: 14),
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
                      backgroundColor: Colors.deepOrange.shade800,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
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
                onTap: onSetupTap,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
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
    );
  }

  Widget _buildCaloriesCard() {
    return Container(
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
              crossAxisAlignment: CrossAxisAlignment.start,
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
                  value: (currentCalories / dailyTarget).clamp(0.0, 1.0),
                  backgroundColor: Colors.grey[800],
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Colors.deepOrange,
                  ),
                  minHeight: 10,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const Icon(
            Icons.local_fire_department,
            color: Colors.deepOrange,
            size: 48,
          ),
        ],
      ),
    );
  }
}
