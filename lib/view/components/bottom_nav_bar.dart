import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'scanner_selection.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int)? onTap;

  const BottomNavBar({super.key, required this.currentIndex, this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Colors.black,
      unselectedItemColor: Colors.grey,
      selectedItemColor: Colors.white,
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      currentIndex: currentIndex,
      onTap: onTap ?? (index) => _defaultOnTap(context, index),
      items: [
        BottomNavigationBarItem(
          icon: SvgPicture.asset(
            'assets/icons/House Blank.svg',
            height: 24,
            width: 24,
            colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.srcIn),
          ),
          activeIcon: SvgPicture.asset(
            'assets/icons/House Blank.svg',
            height: 24,
            width: 24,
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset(
            'assets/icons/search.svg',
            height: 24,
            width: 24,
            colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.srcIn),
          ),
          activeIcon: SvgPicture.asset(
            'assets/icons/search.svg',
            height: 24,
            width: 24,
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
          label: 'Search',
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset(
            'assets/icons/QR Scan.svg',
            height: 24,
            width: 24,
            colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.srcIn),
          ),
          activeIcon: SvgPicture.asset(
            'assets/icons/QR Scan.svg',
            height: 24,
            width: 24,
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
          label: 'Scan',
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset(
            'assets/icons/folder.svg',
            height: 24,
            width: 24,
            colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.srcIn),
          ),
          activeIcon: SvgPicture.asset(
            'assets/icons/folder.svg',
            height: 24,
            width: 24,
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
          label: 'Files',
        ),
      ],
    );
  }

  void _defaultOnTap(BuildContext context, int index) {
    handleNavigation(context, index, currentIndex: currentIndex);
  }

  // Static method for common navigation logic
  static void handleNavigation(
    BuildContext context,
    int index, {
    int? currentIndex,
  }) {
    // Don't navigate if user tapped on the current page
    if (currentIndex != null && index == currentIndex) {
      return;
    }

    switch (index) {
      case 0:
        // Home - Navigate to home if not already there
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
        break;
      case 1:
        // Search functionality - you can implement this later
        break;
      case 2:
        // Show scanner selection bottom sheet
        ScannerSelectionBottomSheet.show(context);
        break;
      case 3:
        // Files functionality - you can implement this later
        break;
    }
  }
}
