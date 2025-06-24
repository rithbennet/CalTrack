import 'package:flutter/material.dart';
import 'package:caltrack/models/user_model.dart';
import 'package:caltrack/models/nutritional_summary.dart'; // ADDED
import 'package:caltrack/view/reports/daily_report_screen.dart'; // ADDED
import 'package:caltrack/view/reports/weekly_report_screen.dart';

// Note: You will need to create this screen for the weekly report
// import 'package:caltrack/view/reports/weekly_report_screen.dart';

class ProgressCardsCarousel extends StatefulWidget {
  // --- EXISTING PROPERTIES (UNCHANGED) ---
  final UserModel? userProfile;
  final int percentage;
  final int currentCalories;
  final int dailyTarget;
  final VoidCallback onSetupTap;

  // --- NEW PROPERTIES FOR REPORTS ---
  final DailyNutritionalSummary todaySummary;
  final List<DailyNutritionalSummary> weeklySummary;

  const ProgressCardsCarousel({
    super.key,
    this.userProfile,
    required this.percentage,
    required this.currentCalories,
    required this.dailyTarget,
    required this.onSetupTap,
    // ADDED: Require the new summary data
    required this.todaySummary,
    required this.weeklySummary,
  });

  @override
  State<ProgressCardsCarousel> createState() => _ProgressCardsCarouselState();
}

class _ProgressCardsCarouselState extends State<ProgressCardsCarousel> {
  // --- EXISTING STATE AND LIFECYCLE (UNCHANGED) ---
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

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {});
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
    // ADDED: A list of all cards to be displayed
    final List<Widget> cards = [
      _buildPlanCard(),
      _buildCaloriesCard(),
      _buildDailyReportCard(),
      _buildWeeklyReportCard(),
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 195,
          child: PageView.builder(
            physics: const BouncingScrollPhysics(),
            controller: _pageController,
            // MODIFIED: Use the length of the cards list
            itemCount: cards.length,
            itemBuilder: (context, index) {
              final double pageOffset =
                  _pageController.hasClients
                      ? (_pageController.page ?? 0) - index
                      : 0.0;
              final double scale =
                  0.9 + (1 - (pageOffset.abs() * 0.1)).clamp(0.0, 0.1);

              return Transform.scale(
                scale: scale,
                // MODIFIED: Use the card from the list
                child: cards[index],
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 8,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            // MODIFIED: Generate indicators based on the number of cards
            children: List.generate(cards.length, (index) {
              return _buildPageIndicator(_currentPage == index);
            }),
          ),
        ),
      ],
    );
  }

  // --- EXISTING WIDGETS (UNCHANGED) ---
  Widget _buildPageIndicator(bool isActive) {
    // ... (This widget is unchanged)
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
    // ... (This entire widget is unchanged)
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
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
    // ... (This entire widget is unchanged)
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

  // --- NEW WIDGETS FOR REPORTS ---

  Widget _buildDailyReportCard() {
    return Container(
      margin: const EdgeInsets.only(left: 12), // Added this margin
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) =>
                        DailyReportScreen(summary: widget.todaySummary),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Ink(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.deepOrange, Colors.deepOrange.shade800],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.teal.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.pie_chart, color: Colors.white, size: 28),
                    SizedBox(width: 8),
                    Text(
                      'Daily Report',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  '${widget.todaySummary.totalCalories.toStringAsFixed(0)} kcal consumed',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tap to see macro details',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeeklyReportCard() {
    final summariesWithEntries = widget.weeklySummary.where(
      (s) => s.foodEntries.isNotEmpty,
    );
    final double averageCalories =
        summariesWithEntries.isEmpty
            ? 0
            : summariesWithEntries
                    .map((s) => s.totalCalories)
                    .reduce((a, b) => a + b) /
                summariesWithEntries.length;

    return Container(
      margin: const EdgeInsets.only(left: 12), // Added this margin
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) =>
                        WeeklyReportScreen(weeklySummary: widget.weeklySummary),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Ink(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.grey[800]!, Colors.grey[900]!],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.indigo.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.bar_chart, color: Colors.white, size: 28),
                    SizedBox(width: 8),
                    Text(
                      'Weekly Report',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  '${averageCalories.toStringAsFixed(0)} avg daily kcal',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tap for weekly trends',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
