import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Wait for 2 seconds to show the animation, then go to login
    // The router will handle redirecting to home if they are already logged in
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) context.go('/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // The wordmark needs to look premium
            Text(
              'Evntly',
              style: GoogleFonts.syne(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                letterSpacing: -2,
                color: Colors.white,
              ),
            )
            .animate()
            .fadeIn(duration: 800.ms)
            .slideY(begin: 0.2, end: 0, curve: Curves.easeOutBack),
            
            const SizedBox(height: 12),
            
            Text(
              'Discover what\'s happening.',
              style: GoogleFonts.dmSans(
                fontSize: 16,
                color: Colors.white70,
              ),
            )
            .animate()
            .fadeIn(delay: 400.ms, duration: 800.ms),
          ],
        ),
      ),
    );
  }
}
