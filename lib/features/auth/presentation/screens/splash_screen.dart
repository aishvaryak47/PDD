import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        context.go('/onboarding');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.heroGradient,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
                border: Border.all(
                    color: Colors.white.withValues(alpha: 0.4), width: 2),
              ),
              child: const Icon(Icons.psychology_alt_rounded,
                  size: 80, color: Colors.white),
            )
                .animate()
                .scale(duration: 800.ms, curve: Curves.elasticOut)
                .fadeIn(duration: 600.ms),
            const SizedBox(height: 24),
            Text(
              'PSYNOVA AI',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: Colors.white,
                    letterSpacing: 3,
                    fontWeight: FontWeight.bold,
                  ),
            ).animate().slideY(begin: 0.3, end: 0, duration: 600.ms).fadeIn(),
            const SizedBox(height: 8),
            Text(
              'Intelligent Mental Health & Therapy Ecosystem',
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9), fontSize: 16),
            ).animate().fadeIn(delay: 400.ms),
            const SizedBox(height: 48),
            const CircularProgressIndicator(
                color: Colors.white, strokeWidth: 3),
          ],
        ),
      ),
    );
  }
}
