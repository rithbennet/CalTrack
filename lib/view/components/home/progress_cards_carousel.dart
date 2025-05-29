import 'package:flutter/material.dart';
import 'package:caltrack/models/user_model.dart';

class ProgressCardsCarousel extends StatefulWidget {
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
  State<ProgressCardsCarousel> createState() => _ProgressCardsCarouselState();
}

class _ProgressCardsCarouselState extends State<ProgressCardsCarousel> {
  final PageController _pageController = PageController(viewportFraction: 0.92);
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      int next = _pageController.page?.round() ?? 0;
      if (_currentPage != next) {
        setState(() {
          _currentPage = next;
        });
      }
    });

    // Add a small delay before animating to draw user attention
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {}); // Trigger rebuild for animation
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 195,
          child: PageView.builder(
            physics: const BouncingScrollPhysics(),
            controller: _pageController,
            itemCount: 2,
            itemBuilder: (context, index) {
              // Calculate the relative position for the current page
              final double pageOffset =
                  _pageController.hasClients
                      ? (_pageController.page ?? 0) - index
                      : 0.0;

              // Apply a subtle scale and rotation effect
              final double scale =
                  0.9 + (1 - (pageOffset.abs() * 0.1)).clamp(0.0, 0.1);

              return Transform.scale(
                scale: scale,
                child: Hero(
                  tag: index == 0 ? 'plan-card' : 'calories-card',
                  child: index == 0 ? _buildPlanCard() : _buildCaloriesCard(),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        // Simple page indicator
        SizedBox(
          height: 8,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildPageIndicator(_currentPage == 0),
              _buildPageIndicator(_currentPage == 1),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPageIndicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 5),
      height: 8,
      width: isActive ? 24 : 8,
      decoration: BoxDecoration(
        color:
            isActive ? Colors.deepOrange : Colors.grey.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(4),
        boxShadow:
            isActive
                ? [
                  BoxShadow(
                    color: Colors.deepOrange.withValues(alpha: 0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
                : null,
      ),
    );
  }

  Widget _buildPlanCard() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {}, // Allow tapping for future feature expansion
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.deepOrange, Colors.deepOrange.shade800],
              stops: const [0.1, 0.9],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.deepOrange.withValues(alpha: .3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
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
                      'Today\'s \n Goal',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                        shadows: [
                          Shadow(
                            blurRadius: 3.0,
                            color: Color.fromARGB(50, 0, 0, 0),
                            offset: Offset(1.0, 1.0),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.userProfile?.effectiveDailyCalorieTarget != null
                          ? 'Target: ${widget.userProfile!.effectiveDailyCalorieTarget} cal'
                          : 'Complete profile to set target',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              // Right side - progress circle or setup prompt
              widget.userProfile?.effectiveDailyCalorieTarget != null
                  ? TweenAnimationBuilder<double>(
                    tween: Tween<double>(
                      begin: 0,
                      end: widget.percentage / 100,
                    ),
                    duration: const Duration(milliseconds: 1500),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 110,
                            height: 110,
                            child: CircularProgressIndicator(
                              value: value,
                              strokeWidth: 12,
                              backgroundColor: Colors.white.withValues(
                                alpha: .2,
                              ),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                              strokeCap: StrokeCap.round,
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${(value * 100).toInt()}%',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 34,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text(
                                'complete',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  )
                  : GestureDetector(
                    onTap: widget.onSetupTap,
                    child: Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .15),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: .1),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.add_circle_outline,
                              color: Colors.white,
                              size: 36,
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Setup',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCaloriesCard() {
    return Container(
      margin: const EdgeInsets.only(left: 12),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.grey[800]!, Colors.grey[900]!],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
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
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    shadows: [
                      Shadow(
                        blurRadius: 3.0,
                        color: Color.fromARGB(50, 0, 0, 0),
                        offset: Offset(1.0, 1.0),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '${widget.currentCalories}',
                        style: const TextStyle(
                          color: Colors.deepOrange,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: ' / ${widget.dailyTarget} cal',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(
                    begin: 0,
                    end: (widget.currentCalories / widget.dailyTarget).clamp(
                      0.0,
                      1.0,
                    ),
                  ),
                  duration: const Duration(milliseconds: 1500),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: value,
                            backgroundColor: Colors.grey[800],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              value >= 1.0
                                  ? Colors.redAccent
                                  : Colors.deepOrange,
                            ),
                            minHeight: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          value >= 1.0
                              ? 'Calorie limit reached!'
                              : '${(value * 100).toInt()}% of daily goal',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.deepOrange.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.local_fire_department,
                color: Colors.deepOrange,
                size: 36,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
