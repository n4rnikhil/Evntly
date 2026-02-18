import 'package:flutter_riverpod/flutter_riverpod.dart';

// This controls which tab the user is currently looking at
final bottomNavIndexProvider = StateProvider<int>((ref) => 0);
