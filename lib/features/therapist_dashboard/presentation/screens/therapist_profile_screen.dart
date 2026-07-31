import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../../../shared/providers/active_therapists_provider.dart';
import '../../../auth/providers/auth_provider.dart';

class TherapistProfileScreen extends ConsumerWidget {
  const TherapistProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final activeTherapists = ref.watch(activeTherapistsProvider);

    ActiveTherapist? currentTherapist;
    for (final t in activeTherapists) {
      if (t.id == user?.id || t.name.contains(user?.fullName ?? '')) {
        currentTherapist = t;
        break;
      }
    }

    final displayName = user?.fullName != null && user!.fullName.isNotEmpty
        ? (user.fullName.toLowerCase().startsWith('dr') ? user.fullName : 'Dr. ${user.fullName}')
        : 'Dr. Practitioner';

    final title = currentTherapist?.title ?? 'Licensed Clinical Specialist';
    final experienceYears = currentTherapist?.experienceYears ?? 8;
    final qualifications = currentTherapist?.qualifications ?? ['Psy.D in Clinical Psychology', 'Licensed CBT Specialist'];
    final rate = currentTherapist?.rate ?? '\$140.00 / session';

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
                      child: Icon(Icons.medical_services_rounded, size: 50, color: Colors.white),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      displayName,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      style: const TextStyle(color: AppColors.textSecondaryLight, fontSize: 14),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryPurple.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$experienceYears Years Professional Experience',
                        style: const TextStyle(color: AppColors.primaryPurple, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              GlassContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Hourly Fee Rate', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(
                          rate,
                          style: const TextStyle(color: AppColors.primaryPurple, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Weekly Availability', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('Mon - Fri (09:00 - 17:00)', style: TextStyle(color: AppColors.textSecondaryLight)),
                      ],
                    ),
                    const Divider(height: 24),
                    const Text('Qualifications & Certifications', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ...qualifications.map(
                      (q) => Padding(
                        padding: const EdgeInsets.only(bottom: 6.0),
                        child: Row(
                          children: [
                            const Icon(Icons.verified, color: AppColors.primaryPurple, size: 18),
                            const SizedBox(width: 8),
                            Expanded(child: Text(q, style: const TextStyle(fontSize: 13))),
                          ],
                        ),
                      ),
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

