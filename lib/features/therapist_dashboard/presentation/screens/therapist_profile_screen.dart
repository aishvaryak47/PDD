import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../../auth/providers/auth_provider.dart';

class TherapistProfileScreen extends ConsumerWidget {
  const TherapistProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;

    return Scaffold(
      appBar: AppBar(title: const Text('Therapist Professional Profile')),
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
                      backgroundColor: AppColors.primaryPurple,
                      child: Icon(Icons.medical_services_rounded,
                          size: 50, color: Colors.white),
                    ),
                    const SizedBox(height: 14),
                    Text(user?.fullName ?? 'Dr. Sarah Jenkins',
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    const Text('Licensed Clinical Psychologist',
                        style: TextStyle(color: AppColors.textSecondaryLight)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const GlassContainer(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Hourly Fee Rate',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('\$120.00 / session',
                            style: TextStyle(
                                color: AppColors.primaryPurple,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Weekly Availability',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('Mon - Fri (09:00 - 17:00)',
                            style:
                                TextStyle(color: AppColors.textSecondaryLight)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Edit Profile & Availability',
                isOutlined: true,
                onPressed: () {},
              ),
              const SizedBox(height: 16),
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
