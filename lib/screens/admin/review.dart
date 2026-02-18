import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/events_provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme.dart';

class ReviewQueueScreen extends ConsumerWidget {
  const ReviewQueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingAsync = ref.watch(pendingEventsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Review Queue')),
      body: pendingAsync.when(
        data: (events) {
          if (events.isEmpty) {
            return const Center(child: Text('No events to review! 🎉'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Column(
                  children: [
                    ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(imageUrl: event.imageUrl, width: 60, height: 60, fit: BoxFit.cover),
                      ),
                      title: Text(event.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('By ${event.organizerName}'),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => _showRejectDialog(context, ref, event.id),
                            child: const Text('Reject', style: TextStyle(color: AppColors.deadlineRed)),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () => ref.read(eventServiceProvider).approveEvent(event.id, ref.read(currentUserProvider)!.uid),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.successGreen,
                              minimumSize: const Size(100, 40),
                            ),
                            child: const Text('Approve'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().slideX(begin: 0.1, end: 0).fadeIn();
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }

  void _showRejectDialog(BuildContext context, WidgetRef ref, String eventId) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Event'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(hintText: 'Enter reason...'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              ref.read(eventServiceProvider).rejectEvent(eventId, reasonController.text);
              Navigator.pop(context);
            },
            child: const Text('Confirm Reject'),
          ),
        ],
      ),
    );
  }
}
