import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/auth_provider.dart';
import 'screens/splash.dart';
import 'screens/login.dart';
import 'screens/register.dart';
import 'screens/main_shell.dart';
import 'screens/admin/dashboard.dart';

// Routing can get complicated, so I'm trying to keep the logic clear.
// Basically: if not logged in -> login, if admin -> admin panel, else -> student app.
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      // If we're on splash, we stay there until auth determines state
      if (state.matchedLocation == '/') return null;

      final user = authState.value;
      final loggingIn = state.matchedLocation == '/login' || state.matchedLocation == '/register';

      if (authState.isLoading) return null;

      if (user == null) {
        return loggingIn ? null : '/login';
      }

      if (loggingIn) {
        return (user.role == 'admin') ? '/admin' : '/home';
      }

      // Role guards
      if (state.matchedLocation.startsWith('/admin') && user.role != 'admin') {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      
      // Student Routes - Handled by MainShell
      GoRoute(
        path: '/home',
        builder: (context, state) => const MainShell(),
      ),

      // Admin Routes
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminDashboard(),
      ),
    ],
  );
});
