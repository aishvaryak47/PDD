import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../../../shared/providers/active_therapists_provider.dart';
import '../../../auth/providers/auth_provider.dart';

class TherapistDetailScreen extends ConsumerWidget {
  final String therapistId;
  const TherapistDetailScreen({super.key, required this.therapistId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTherapists = ref.watch(activeTherapistsProvider);
    final user = ref.watch(authProvider).user;

    ActiveTherapist? foundTherapist;
    for (final t in activeTherapists) {
      if (t.id == therapistId || t.name.toLowerCase().contains(therapistId.toLowerCase())) {
        foundTherapist = t;
        break;
      }
    }

    // Fallback if looking up by active logged in therapist user
    if (foundTherapist == null && user != null && user.role == 'therapist') {
      foundTherapist = ActiveTherapist(
        id: user.id,
        name: user.fullName.isNotEmpty ? (user.fullName.toLowerCase().startsWith('dr') ? user.fullName : 'Dr. ${user.fullName}') : 'Dr. Practitioner',
        title: 'Licensed Clinical Specialist',
        rate: '\$140 / hr',
        rating: 5.0,
        reviews: 12,
        address: 'Active Online Clinical Suite',
        biography: 'Licensed clinical therapist offering Cognitive Behavioral Therapy, anxiety resilience, and mental wellness consultations.',
        qualifications: const ['Psy.D in Clinical Psychology', 'Licensed CBT Specialist'],
        experienceYears: 8,
        languages: const ['English', 'Spanish'],
      );
    }

    // Secondary fallback to first active therapist
    foundTherapist ??= activeTherapists.isNotEmpty
        ? activeTherapists.first
        : ActiveTherapist(
            id: 't-default',
            name: 'Dr. Licensed Specialist',
            title: 'Licensed Clinical Psychologist',
            rate: '\$140 / hr',
            rating: 5.0,
            reviews: 15,
            address: 'Psynova Clinical Center',
            biography: 'Licensed clinical therapist offering Cognitive Behavioral Therapy, anxiety resilience, and mental wellness consultations.',
            qualifications: const ['Psy.D in Clinical Psychology', 'Licensed CBT Specialist'],
            experienceYears: 8,
            languages: const ['English', 'Spanish'],
          );

    final t = foundTherapist;

    return Scaffold(
      appBar: AppBar(title: const Text('Therapist Profile')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: AppColors.primaryIndigo,
                            child: Text(
                              t.name.isNotEmpty ? t.name[0].toUpperCase() : 'D',
                              style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            t.name,
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            t.title,
                            style: const TextStyle(color: AppColors.textSecondaryLight, fontSize: 15),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                              Text(
                                ' ${t.rating} (${t.reviews} Reviews) • ${t.experienceYears} Years Exp.',
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    Row(
                      children: [
                        Expanded(
                          child: GlassContainer(
                            child: Column(
                              children: [
                                const Text('Session Rate', style: TextStyle(color: AppColors.textSecondaryLight, fontSize: 12)),
                                const SizedBox(height: 4),
                                Text(
                                  t.rate,
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryIndigo),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GlassContainer(
                            child: Column(
                              children: [
                                const Text('Languages', style: TextStyle(color: AppColors.textSecondaryLight, fontSize: 12)),
                                const SizedBox(height: 4),
                                Text(
                                  t.languages.join(', '),
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    const Text('About Therapist', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(
                      t.biography,
                      style: const TextStyle(height: 1.5, color: AppColors.textSecondaryLight),
                    ),
                    const SizedBox(height: 24),

                    const Text('Qualifications & Certificates', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    ...t.qualifications.map(
                      (q) => Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          children: [
                            const Icon(Icons.verified_rounded, color: AppColors.primaryIndigo, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                q,
                                style: const TextStyle(fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  IconButton.outlined(
                    icon: const Icon(Icons.chat_bubble_outline_rounded, color: AppColors.primaryIndigo),
                    onPressed: () => context.push('/chat-detail/${t.id}'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      text: 'Book Appointment',
                      onPressed: () => context.push('/book-appointment/${t.id}'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

