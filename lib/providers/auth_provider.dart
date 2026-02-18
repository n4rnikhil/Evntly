import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth.dart';
import '../models/user.dart';

// The global auth state. 
// I love Riverpod, it makes this so much easier than Provider.
final authServiceProvider = Provider((ref) => AuthService());

final authStateProvider = StreamProvider<AppUser?>((ref) {
  return ref.watch(authServiceProvider).userStream;
});

final currentUserProvider = Provider<AppUser?>((ref) {
  return ref.watch(authStateProvider).value;
});
