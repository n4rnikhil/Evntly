import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/events_provider.dart';
import '../widgets/event_card.dart';
import '../theme.dart';
import 'event_detail.dart';
import 'notifications.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(liveEventsProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Evntly',
          style: GoogleFonts.syne(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: -1,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationsScreen()),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: eventsAsync.when(
        data: (events) {
          if (events.isEmpty) {
            return const Center(child: Text('No events found. Check back later!'));
          }

          return RefreshIndicator(
            onRefresh: () async => ref.refresh(liveEventsProvider),
            color: AppColors.accent,
            child: ListView.builder(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 120), // Added bottom padding
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                return EventCard(
                  event: event,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => EventDetailScreen(event: event)),
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
