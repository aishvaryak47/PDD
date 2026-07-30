import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/custom_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _pages = [
    {
      'title': 'AI-Powered Emotional Support',
      'subtitle':
          'Chat 24/7 with Groq-powered AI for immediate coping strategies, guided meditation, and emotional check-ins.',
      'icon': 'psychology',
    },
    {
      'title': 'Connect with Licensed Therapists',
      'subtitle':
          'Discover top-rated therapists nearby, view availability, book sessions, and join HD WebRTC video consultations.',
      'icon': 'video_call',
    },
    {
      'title': 'Track Mood & Journal Progress',
      'subtitle':
          'Log daily moods, keep personal voice & text journals, and view AI-generated wellness analytics over time.',
      'icon': 'insights',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('PSYNOVA AI',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryIndigo,
                          fontSize: 20)),
                  TextButton(
                    onPressed: () => context.go('/welcome'),
                    child: const Text('Skip',
                        style: TextStyle(color: AppColors.textSecondaryLight)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  IconData iconData = Icons.psychology;
                  if (page['icon'] == 'video_call') {
                    iconData = Icons.video_camera_front_rounded;
                  }
                  if (page['icon'] == 'insights') {
                    iconData = Icons.show_chart_rounded;
                  }

                  return Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(36),
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                  color: AppColors.primaryIndigo
                                      .withValues(alpha: 0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10))
                            ],
                          ),
                          child: Icon(iconData, size: 90, color: Colors.white),
                        ),
                        const SizedBox(height: 40),
                        Text(
                          page['title']!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 26, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          page['subtitle']!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 16,
                              color: AppColors.textSecondaryLight,
                              height: 1.5),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 8,
                  width: _currentPage == index ? 24 : 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? AppColors.primaryIndigo
                        : AppColors.cardBorderLight,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: CustomButton(
                text:
                    _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
                onPressed: () {
                  if (_currentPage < _pages.length - 1) {
                    _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut);
                  } else {
                    context.go('/welcome');
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
