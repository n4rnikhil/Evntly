import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/events_provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme.dart';
import 'review.dart';
import 'manage_events.dart';
import 'manage_users.dart';

class AdminDashboard extends ConsumerStatefulWidget {
  const AdminDashboard({super.key});

  @override
  ConsumerState<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends ConsumerState<AdminDashboard> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      _buildStatsOverview(context, ref),
      const ReviewQueueScreen(),
      const ManageEventsScreen(),
      const ManageUsersScreen(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0C0C14),
      appBar: AppBar(
        title: Text('Admin Panel', style: GoogleFonts.syne(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => ref.read(authServiceProvider).signOut(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.accent,
        unselectedItemColor: AppColors.textSecondary,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Stats'),
          BottomNavigationBarItem(icon: Icon(Icons.pending_actions_rounded), label: 'Review'),
          BottomNavigationBarItem(icon: Icon(Icons.event_note_rounded), label: 'Events'),
          BottomNavigationBarItem(icon: Icon(Icons.people_alt_rounded), label: 'Users'),
        ],
      ),
    );
  }

  Widget _buildStatsOverview(BuildContext context, WidgetRef ref) {
    final pendingAsync = ref.watch(pendingEventsProvider);
    final liveAsync = ref.watch(liveEventsProvider);
    final totalUsersAsync = ref.watch(totalUsersProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Dashboard Overview', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 24),
          
          Row(
            children: [
              Expanded(child: _buildStatCard('Pending', pendingAsync.value?.length.toString() ?? '0', AppColors.accent)),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard('Live', liveAsync.value?.length.toString() ?? '0', AppColors.successGreen)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildStatCard('Total Users', totalUsersAsync.value?.toString() ?? '0', AppColors.textSecondary)),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard('Growth', '+5%', AppColors.organizerGold)),
            ],
          ),
          
          const SizedBox(height: 40),
          Text('Recent Activity', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          
          _buildActivityItem('User submitted a new event', 'Just now'),
          _buildActivityItem('Event was approved by Admin', '15 mins ago'),
          _buildActivityItem('New student registered', '1 hour ago'),
          
          const SizedBox(height: 40),
          ElevatedButton.icon(
            onPressed: () => setState(() => _currentIndex = 1), // Go to Review Queue
            icon: const Icon(Icons.rate_review_outlined),
            label: const Text('Enter Review Queue'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 8),
          Text(value, style: GoogleFonts.syne(fontSize: 28, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildActivityItem(String title, String time) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle)),
          const SizedBox(width: 16),
          Expanded(child: Text(title, style: const TextStyle(fontSize: 14))),
          Text(time, style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }
}
