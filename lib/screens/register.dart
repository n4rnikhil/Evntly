import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/auth_provider.dart';
import '../theme.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  int _currentStep = 0;
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  
  final List<String> _allInterests = [
    'AI & ML', 'Hackathons', 'Web Development', 'Cybersecurity',
    'Design & UI/UX', 'Robotics', 'Data Science', 'Entrepreneurship',
    'Gaming', 'Workshops', 'Cultural', 'Sports'
  ];
  final List<String> _selectedInterests = [];
  bool _isLoading = false;

  void _toggleInterest(String interest) {
    setState(() {
      if (_selectedInterests.contains(interest)) {
        _selectedInterests.remove(interest);
      } else {
        _selectedInterests.add(interest);
      }
    });
  }

  Future<void> _handleRegister() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(authServiceProvider).register(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        name: _nameController.text.trim(),
        interests: _selectedInterests,
      );
      setState(() => _currentStep = 2); // Show success step
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _currentStep < 2 ? IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () {
            if (_currentStep > 0) {
              setState(() => _currentStep--);
            } else {
              context.pop();
            }
          },
        ) : null,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_currentStep == 0) ..._buildStep1(),
            if (_currentStep == 1) ..._buildStep2(),
            if (_currentStep == 2) ..._buildStep3(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildStep1() {
    return [
      Text('Create Account', style: Theme.of(context).textTheme.displayLarge),
      const SizedBox(height: 8),
      Text('Let\'s get you started on your journey.', style: Theme.of(context).textTheme.bodyLarge),
      const SizedBox(height: 40),
      TextField(controller: _nameController, decoration: const InputDecoration(hintText: 'Full Name')),
      const SizedBox(height: 16),
      TextField(controller: _emailController, decoration: const InputDecoration(hintText: 'Email')),
      const SizedBox(height: 16),
      TextField(controller: _passwordController, decoration: const InputDecoration(hintText: 'Password'), obscureText: true),
      const SizedBox(height: 32),
      ElevatedButton(
        onPressed: () => setState(() => _currentStep = 1),
        child: const Text('Continue'),
      ),
    ].animate(interval: 100.ms).fadeIn().slideX(begin: 0.1, end: 0);
  }

  List<Widget> _buildStep2() {
    return [
      Text('Interests', style: Theme.of(context).textTheme.displayLarge),
      const SizedBox(height: 8),
      Text('Pick at least one to personalize your feed.', style: Theme.of(context).textTheme.bodyLarge),
      const SizedBox(height: 32),
      Expanded(
        child: SingleChildScrollView(
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _allInterests.map((interest) {
              final isSelected = _selectedInterests.contains(interest);
              return GestureDetector(
                onTap: () => _toggleInterest(interest),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.accent : AppColors.surface,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: isSelected ? AppColors.accent : AppColors.textSecondary.withOpacity(0.3),
                    ),
                    boxShadow: isSelected ? [
                      BoxShadow(color: AppColors.accent.withOpacity(0.3), blurRadius: 10, spreadRadius: 1)
                    ] : null,
                  ),
                  child: Text(
                    interest,
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ).animate(target: isSelected ? 1 : 0).scale(begin: const Offset(1, 1), end: const Offset(1.05, 1.05)),
              );
            }).toList(),
          ),
        ),
      ),
      const SizedBox(height: 20),
      ElevatedButton(
        onPressed: _selectedInterests.isEmpty || _isLoading ? null : _handleRegister,
        child: _isLoading 
          ? const CircularProgressIndicator(color: Colors.white)
          : const Text('Finish'),
      ),
      const SizedBox(height: 40),
    ];
  }

  List<Widget> _buildStep3() {
    return [
      const Spacer(),
      const Center(
        child: Icon(Icons.check_circle_rounded, color: AppColors.successGreen, size: 100),
      ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
      const SizedBox(height: 32),
      Center(child: Text('You\'re in!', style: Theme.of(context).textTheme.displayLarge)),
      const SizedBox(height: 8),
      Center(child: Text('Welcome to the community.', style: Theme.of(context).textTheme.bodyLarge)),
      const Spacer(),
      ElevatedButton(
        onPressed: () => context.go('/home'),
        child: const Text('Get Started'),
      ),
      const SizedBox(height: 40),
    ];
  }
}
