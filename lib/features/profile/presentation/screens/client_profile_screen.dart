import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../../auth/providers/auth_provider.dart';

class ClientProfileScreen extends ConsumerWidget {
  const ClientProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;

    return Scaffold(
      appBar: AppBar(title: const Text('Client Profile & Wellness')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 46,
                      backgroundColor: AppColors.primaryIndigo,
                      child: Icon(Icons.person, size: 55, color: Colors.white),
                    ),
                    const SizedBox(height: 14),
                    Text(user?.fullName ?? 'Alex Morgan',
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(user?.email ?? 'alex.morgan@client.com',
                        style: const TextStyle(
                            color: AppColors.textSecondaryLight)),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Emergency Contact & Crisis Helpline Banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        color: Colors.red, size: 32),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('24/7 Crisis Hotline',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                  fontSize: 15)),
                          SizedBox(height: 2),
                          Text(
                              'If in immediate danger, dial 988 or call Emergency Contact: +1 (800) 273-8255.',
                              style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              const GlassContainer(
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.shield_outlined,
                          color: AppColors.primaryIndigo),
                      title: Text('Therapy Preferences'),
                      subtitle: Text('CBT, Mindfulness, E2EE Encrypted Chat Sessions'),
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(Icons.contact_phone_outlined,
                          color: AppColors.primaryIndigo),
                      title: Text('Emergency Contact'),
                      subtitle: Text('Sarah Morgan (+1 555-0192)'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              CustomButton(
                text: 'Log Out',
                onPressed: () {
                  ref.read(authProvider.notifier).logout();
                  context.go('/welcome');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
