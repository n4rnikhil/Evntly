import 'seed_data.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'router.dart';
import 'theme.dart';

// The entry point! 
// Just standard Firebase setup and Riverpod ProviderScope.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // NOTE: This will fail if google-services.json isn't added.
  // But for the sake of the project, I'm assuming it's all good.
  try {
    await Firebase.initializeApp();
    await seedEvents(); // Just run this once!

  } catch (e) {
    print('Firebase not initialized - make sure to add your config files! $e');
  }

  runApp(
    const ProviderScope(
      child: EvntlyApp(),
    ),
  );
}

class EvntlyApp extends ConsumerWidget {
  const EvntlyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Evntly',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme, // Dark mode only for that premium vibe
      routerConfig: router,
    );
  }
}
