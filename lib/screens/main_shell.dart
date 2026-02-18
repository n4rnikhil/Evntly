import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'home.dart';
import 'explore.dart';
import 'post_event.dart';
import 'profile.dart';
import '../theme.dart';

import '../providers/navigation_provider.dart';

class MainShell extends ConsumerWidget {
  const MainShell({super.key});

  final List<Widget> _screens = const [
    HomeScreen(),
    ExploreScreen(),
    PostEventScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(bottomNavIndexProvider);

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: _screens,
      ),
      extendBody: true,
      bottomNavigationBar: _buildBottomNav(ref, currentIndex),
    );
  }

  Widget _buildBottomNav(WidgetRef ref, int currentIndex) {
    return Container(
      padding: const EdgeInsets.only(bottom: 24, left: 24, right: 24, top: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            AppColors.background.withOpacity(0.8),
          ],
        ),
      ),
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(35),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 1,
            ),
          ],
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navIcon(ref, Icons.home_filled, 0, currentIndex),
            _navIcon(ref, Icons.search_rounded, 1, currentIndex),
            _navIcon(ref, Icons.add_box_outlined, 2, currentIndex),
            _navIcon(ref, Icons.person_outline_rounded, 3, currentIndex),
          ],
        ),
      ),
    );
  }

  Widget _navIcon(WidgetRef ref, IconData icon, int index, int currentIndex) {
    final active = currentIndex == index;
    return GestureDetector(
      onTap: () => ref.read(bottomNavIndexProvider.notifier).state = index,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        child: Icon(
          icon,
          color: active ? AppColors.accent : AppColors.textSecondary,
          size: 28,
        ),
      ),
    );
  }
}
