import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/providers/active_clients_provider.dart';

class TherapistNearbyMapScreen extends ConsumerStatefulWidget {
  const TherapistNearbyMapScreen({super.key});

  @override
  ConsumerState<TherapistNearbyMapScreen> createState() => _TherapistNearbyMapScreenState();
}

class _TherapistNearbyMapScreenState extends ConsumerState<TherapistNearbyMapScreen> {
  @override
  Widget build(BuildContext context) {
    final activeClients = ref.watch(activeClientsProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Map / Radar Top Banner
            Container(
              height: 220,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFF1E293B),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.radar_rounded, color: AppColors.primaryPurple, size: 64),
                        const SizedBox(height: 8),
                        const Text('Live Practitioner Radar Active', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(
                          activeClients.isEmpty
                              ? 'Waiting for real clients to log in via Psynova AI...'
                              : '${activeClients.length} Real Active Client(s) logged in nearby',
                          style: const TextStyle(color: Colors.white60, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: AppColors.moodEcstatic.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                      child: const Text('GPS Live', style: TextStyle(color: AppColors.moodEcstatic, fontWeight: FontWeight.bold, fontSize: 11)),
                    ),
                  ),
                ],
              ),
            ),

            // Nearby Clients List
            Expanded(
              child: activeClients.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.person_pin_circle_outlined, size: 64, color: AppColors.textSecondaryLight),
                            SizedBox(height: 16),
                            Text('No Real Active Clients Logged In', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                            SizedBox(height: 8),
                            Text(
                              'When a client logs in or registers via Psynova AI, they will automatically appear here in real-time.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: AppColors.textSecondaryLight, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: activeClients.length,
                      itemBuilder: (context, index) {
                        final client = activeClients[index];
                        final isUrgent = client.isUrgent;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          child: GlassContainer(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundColor: AppColors.primaryPurple.withValues(alpha: 0.15),
                                      child: Text(
                                        client.name.isNotEmpty ? client.name[0].toUpperCase() : 'C',
                                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryPurple),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(client.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                              if (isUrgent) ...[
                                                const SizedBox(width: 8),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                  decoration: BoxDecoration(color: AppColors.accentCoral.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
                                                  child: const Text('⚡ Urgent', style: TextStyle(color: AppColors.accentCoral, fontSize: 10, fontWeight: FontWeight.bold)),
                                                ),
                                              ],
                                            ],
                                          ),
                                          const SizedBox(height: 2),
                                          Text('${client.location} • ${client.distance}', style: const TextStyle(color: AppColors.textSecondaryLight, fontSize: 12)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text('Requested Topic: ${client.requestedTopic}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 14),
                                Row(
                                  children: [
                                    Expanded(
                                      child: CustomButton(
                                        text: 'Accept Consultation',
                                        height: 38,
                                        fontSize: 12,
                                        onPressed: () {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Accepted consultation for ${client.name}!'), backgroundColor: AppColors.moodEcstatic),
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    OutlinedButton.icon(
                                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12)),
                                      onPressed: () {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Opening Google Maps Directions...')),
                                        );
                                      },
                                      icon: const Icon(Icons.navigation_rounded, size: 16),
                                      label: const Text('Directions', style: TextStyle(fontSize: 12)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
