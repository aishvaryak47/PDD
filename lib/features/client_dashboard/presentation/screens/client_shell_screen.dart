import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';

class ClientShellScreen extends StatefulWidget {
  final Widget child;
  const ClientShellScreen({super.key, required this.child});

  @override
  State<ClientShellScreen> createState() => _ClientShellScreenState();
}

class _ClientShellScreenState extends State<ClientShellScreen> {
  int _currentIndex = 0;

  final List<String> _routes = [
    '/client-dashboard',
    '/nearby-therapists',
    '/ai-chat',
    '/mood-tracker',
    '/client-appointments',
  ];

  void _onTap(int index) {
    setState(() => _currentIndex = index);
    context.go(_routes[index]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onTap,
        indicatorColor: AppColors.primaryIndigo.withValues(alpha: 0.2),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon:
                  Icon(Icons.home_rounded, color: AppColors.primaryIndigo),
              label: 'Home'),
          NavigationDestination(
              icon: Icon(Icons.map_outlined),
              selectedIcon:
                  Icon(Icons.map_rounded, color: AppColors.primaryIndigo),
              label: 'Therapists'),
          NavigationDestination(
              icon: Icon(Icons.psychology_outlined),
              selectedIcon: Icon(Icons.psychology_rounded,
                  color: AppColors.primaryIndigo),
              label: 'AI Support'),
          NavigationDestination(
              icon: Icon(Icons.mood_outlined),
              selectedIcon:
                  Icon(Icons.mood_rounded, color: AppColors.primaryIndigo),
              label: 'Mood'),
          NavigationDestination(
              icon: Icon(Icons.calendar_month_outlined),
              selectedIcon: Icon(Icons.calendar_month_rounded,
                  color: AppColors.primaryIndigo),
              label: 'Sessions'),
        ],
      ),
    );
  }
}
