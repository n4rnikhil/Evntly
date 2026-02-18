import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Notifications', style: GoogleFonts.syne(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildNotificationItem(
            'Welcome to Evntly! 🎉',
            'Start exploring premium campus events happening around you.',
            'Just now',
            true,
          ),
          _buildNotificationItem(
            'HackSRM Registration 🚀',
            'Registration for HackSRM 5.0 is now live! Don\'t miss out.',
            '2 hours ago',
            true,
          ),
          _buildNotificationItem(
            'Event Approved! ✅',
            'Your submission "AI Ethics Workshop" has been approved by admins.',
            'Yesterday',
            false,
          ),
        ].animate(interval: 100.ms).fadeIn(duration: 500.ms).slideX(begin: 0.1, end: 0),
      ),
    );
  }

  Widget _buildNotificationItem(String title, String body, String time, bool isNew) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isNew ? AppColors.accent.withOpacity(0.05) : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isNew ? AppColors.accent.withOpacity(0.2) : Colors.transparent),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              if (isNew) Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle)),
            ],
          ),
          const SizedBox(height: 8),
          Text(body, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.4)),
          const SizedBox(height: 12),
          Text(time, style: TextStyle(color: AppColors.textSecondary.withOpacity(0.5), fontSize: 12)),
        ],
      ),
    );
  }
}
