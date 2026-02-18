import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/events.dart';
import '../models/event.dart';
import 'auth_provider.dart';

final eventServiceProvider = Provider((ref) => EventService());

final liveEventsProvider = StreamProvider<List<Event>>((ref) {
  return ref.watch(eventServiceProvider).liveEvents;
});

final pendingEventsProvider = StreamProvider<List<Event>>((ref) {
  return ref.watch(eventServiceProvider).pendingEvents;
});

// User's own submissions (both pending and approved)
final mySubmissionsProvider = StreamProvider<List<Event>>((ref) {
  return ref.watch(eventServiceProvider).mySubmissions(ref.watch(currentUserProvider)?.uid ?? '');
});

// Admin: Total users count
final totalUsersProvider = StreamProvider<int>((ref) {
  return ref.watch(eventServiceProvider).totalUsersCount;
});

// Filter events by interests
final personalizedEventsProvider = Provider<List<Event>>((ref) {
  final allEvents = ref.watch(liveEventsProvider).value ?? [];
  return allEvents;
});
