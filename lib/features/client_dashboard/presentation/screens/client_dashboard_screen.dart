import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../../../shared/providers/active_therapists_provider.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../therapist_dashboard/presentation/providers/therapist_provider.dart';
import '../../../../shared/services/psynova_sync_service.dart';

class ClientDashboardScreen extends ConsumerWidget {
  const ClientDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final activeTherapists = ref.watch(activeTherapistsProvider);
    final displayName = (user?.fullName != null && user!.fullName.isNotEmpty)
        ? user.fullName
        : (user?.email != null ? user!.email.split('@')[0] : "Client User");

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar Profile Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello, $displayName 👋',
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'How are you feeling today?',
                        style: TextStyle(
                            color: AppColors.textSecondaryLight, fontSize: 14),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.person_pin_rounded,
                        size: 36, color: AppColors.primaryIndigo),
                    onPressed: () => context.push('/client-profile'),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Hero Wellness Score Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: AppColors.heroGradient,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                        color: AppColors.primaryIndigo.withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 8))
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Wellness Index',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 14)),
                          const SizedBox(height: 8),
                          const Text('84 / 100',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20)),
                            child: const Text('Positive Balance ✨',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.self_improvement_rounded,
                        size: 75, color: Colors.white),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Quick Actions Grid
              const Text('Quick Access',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: GlassContainer(
                      onTap: () => context.push('/mood-tracker'),
                      child: const Column(
                        children: [
                          Icon(Icons.mood_rounded,
                              color: AppColors.moodHappy, size: 32),
                          SizedBox(height: 8),
                          Text('Mood Log',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 13)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GlassContainer(
                      onTap: () => context.push('/journal'),
                      child: const Column(
                        children: [
                          Icon(Icons.book_rounded,
                              color: AppColors.primaryPurple, size: 32),
                          SizedBox(height: 8),
                          Text('Journal',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 13)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GlassContainer(
                      onTap: () => context.push('/ai-chat'),
                      child: const Column(
                        children: [
                          Icon(Icons.auto_awesome_rounded,
                              color: AppColors.accentTeal, size: 32),
                          SizedBox(height: 8),
                          Text('AI Support',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 13)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Real-Time Active Therapists Nearby Banner
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Active Therapists Nearby',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  TextButton(
                    onPressed: () => context.push('/nearby-therapists'),
                    child: const Text('View All'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (activeTherapists.isNotEmpty)
                ...activeTherapists.map((t) => Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: GlassContainer(
                        onTap: () async {
                          final convs = await PsynovaSyncService.loadConversations();
                          final convId = 'conv-${t.id}';
                          final existingIndex = convs.indexWhere((c) => c['id'] == convId);
                          final initialText = 'Hello ${t.name}, I would like to connect for a therapy consultation.';

                          if (existingIndex < 0) {
                            convs.insert(0, {
                              'id': convId,
                              'therapistId': t.id,
                              'therapistName': t.name,
                              'clientName': displayName,
                              'avatar': 'https://i.pravatar.cc/150?img=32',
                              'lastMsg': initialText,
                              'time': 'Just now',
                              'isOnline': true,
                              'messages': [
                                {
                                  'sender': 'client',
                                  'text': initialText,
                                  'time': 'Just now',
                                }
                              ],
                            });
                            await PsynovaSyncService.saveConversations(convs);
                          }

                          ref.read(therapistProvider.notifier).addAppointment({
                            'id': 'apt-${DateTime.now().millisecondsSinceEpoch}',
                            'clientName': displayName,
                            'avatar': 'https://i.pravatar.cc/150?img=12',
                            'time': 'Active Consultation',
                            'type': 'CBT Consultation',
                            'status': 'Active',
                            'risk': 'Stable',
                            'isUrgent': false,
                          });

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Connected with ${t.name}! Secure chat opened.'),
                                backgroundColor: AppColors.moodEcstatic,
                              ),
                            );
                            context.push('/chat-detail/${t.id}');
                          }
                        },
                        child: Row(
                          children: [
                            const CircleAvatar(
                              radius: 26,
                              backgroundColor: AppColors.primaryIndigo,
                              child: Icon(Icons.person, color: Colors.white, size: 30),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(t.name,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold, fontSize: 16)),
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.green.withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: const Text('Online',
                                            style: TextStyle(
                                                color: Colors.green,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text('${t.title} • 🔒 E2EE Messaging',
                                      style: const TextStyle(
                                          color: AppColors.textSecondaryLight,
                                          fontSize: 13)),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                  gradient: AppColors.primaryGradient,
                                  borderRadius: BorderRadius.circular(10)),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.lock_outline_rounded, color: Colors.white, size: 14),
                                  SizedBox(width: 4),
                                  Text('E2EE Text',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ))
              else
                const GlassContainer(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        Icon(Icons.no_accounts_rounded,
                            size: 40, color: AppColors.textSecondaryLight),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('No Active Therapists Online',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 15)),
                              SizedBox(height: 4),
                              Text(
                                  'When a licensed therapist logs in, they will appear here live.',
                                  style: TextStyle(
                                      color: AppColors.textSecondaryLight,
                                      fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 24),

              // AI Mental Health Suggestion
              const GlassContainer(
                child: Row(
                  children: [
                    Icon(Icons.tips_and_updates_rounded,
                        color: AppColors.accentTeal, size: 36),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('AI Daily Suggestion',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15)),
                          SizedBox(height: 4),
                          Text(
                              'Your mood logs indicate minor evening stress. Consider a 5-minute diaphragm breathing exercise before bed.',
                              style: TextStyle(
                                  color: AppColors.textSecondaryLight,
                                  fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
