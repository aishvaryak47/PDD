import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/providers/auth_provider.dart';

class TherapistShellScreen extends ConsumerStatefulWidget {
  final Widget child;
  const TherapistShellScreen({super.key, required this.child});

  @override
  ConsumerState<TherapistShellScreen> createState() => _TherapistShellScreenState();
}

class _TherapistShellScreenState extends ConsumerState<TherapistShellScreen> {
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> _navItems = const [
    {'route': '/therapist-dashboard', 'title': 'Dashboard', 'icon': Icons.dashboard_rounded},
    {'route': '/client-management', 'title': 'My Clients', 'icon': Icons.people_alt_rounded},
    {'route': '/therapist-appointments', 'title': 'Schedule', 'icon': Icons.calendar_month_rounded},
    {'route': '/therapist-messages', 'title': 'Messages', 'icon': Icons.chat_bubble_rounded},
    {'route': '/therapist-notes', 'title': 'SOAP Notes', 'icon': Icons.edit_note_rounded},
    {'route': '/therapist-analytics', 'title': 'Analytics', 'icon': Icons.analytics_rounded},
  ];

  void _onNavigate(int index) {
    setState(() => _selectedIndex = index);
    context.go(_navItems[index]['route'] as String);
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    final displayName = (user?.fullName.isNotEmpty == true)
        ? (user!.fullName.toLowerCase().startsWith('dr') ? user.fullName : 'Dr. ${user.fullName}')
        : 'Dr. Practitioner';
    final displayEmail = (user?.email.isNotEmpty == true) ? user!.email : 'therapist@psynova.com';

    if (isDesktop) {
      return Scaffold(
        body: Row(
          children: [
            // Glassmorphism Minimal Sidebar
            Container(
              width: 240,
              decoration: BoxDecoration(
                color: AppColors.darkSurface,
                border: Border(right: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  // App Brand Header
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.psychology_alt_rounded, color: AppColors.primaryPurple, size: 30),
                      SizedBox(width: 10),
                      Text(
                        'PSYNOVA AI',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 19,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primaryPurple.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text('Clinical Practitioner', style: TextStyle(color: AppColors.primaryPurple, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 20),
                  const Divider(color: Colors.white12, height: 1),

                  // Essential Navigation Items
                  Expanded(
                    child: ListView.builder(
                      itemCount: _navItems.length,
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                      itemBuilder: (context, index) {
                        final item = _navItems[index];
                        final isSelected = _selectedIndex == index;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 4),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primaryPurple.withValues(alpha: 0.2) : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            border: isSelected ? Border.all(color: AppColors.primaryPurple.withValues(alpha: 0.4)) : null,
                          ),
                          child: ListTile(
                            dense: true,
                            leading: Icon(
                              item['icon'] as IconData,
                              color: isSelected ? AppColors.primaryPurple : Colors.white60,
                              size: 20,
                            ),
                            title: Text(
                              item['title'] as String,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.white70,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                fontSize: 13,
                              ),
                            ),
                            onTap: () => _onNavigate(index),
                          ),
                        );
                      },
                    ),
                  ),

                  // Practitioner Quick Footer Profile
                  const Divider(color: Colors.white12, height: 1),
                  Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: AppColors.primaryPurple.withValues(alpha: 0.3),
                          child: Text(
                            displayName.isNotEmpty ? displayName[0] : 'D',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(displayName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12), overflow: TextOverflow.ellipsis),
                              Text(displayEmail, style: const TextStyle(color: Colors.white54, fontSize: 10), overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.logout_rounded, color: Colors.white54, size: 18),
                          onPressed: () {
                            ref.read(authProvider.notifier).logout();
                            context.go('/welcome');
                          },
                          tooltip: 'Logout',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Main Content Area
            Expanded(child: widget.child),
          ],
        ),
      );
    }

    // Mobile Navigation Bar
    return Scaffold(
      appBar: AppBar(
        title: Text(displayName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () {
              ref.read(authProvider.notifier).logout();
              context.go('/welcome');
            },
          ),
        ],
      ),
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex.clamp(0, 4),
        onDestinationSelected: _onNavigate,
        indicatorColor: AppColors.primaryPurple.withValues(alpha: 0.2),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard_rounded, color: AppColors.primaryPurple), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.people_alt_outlined), selectedIcon: Icon(Icons.people_alt_rounded, color: AppColors.primaryPurple), label: 'Clients'),
          NavigationDestination(icon: Icon(Icons.calendar_month_outlined), selectedIcon: Icon(Icons.calendar_month_rounded, color: AppColors.primaryPurple), label: 'Schedule'),
          NavigationDestination(icon: Icon(Icons.chat_bubble_outline_rounded), selectedIcon: Icon(Icons.chat_bubble_rounded, color: AppColors.primaryPurple), label: 'Messages'),
          NavigationDestination(icon: Icon(Icons.edit_note_outlined), selectedIcon: Icon(Icons.edit_note_rounded, color: AppColors.primaryPurple), label: 'SOAP Notes'),
        ],
      ),
    );
  }
}
