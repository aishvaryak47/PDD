import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../../../shared/services/psynova_sync_service.dart';

class ClientAppointmentsScreen extends StatefulWidget {
  const ClientAppointmentsScreen({super.key});

  @override
  State<ClientAppointmentsScreen> createState() => _ClientAppointmentsScreenState();
}

class _ClientAppointmentsScreenState extends State<ClientAppointmentsScreen> {
  List<Map<String, dynamic>> _appointments = [];
  Timer? _syncTimer;

  @override
  void initState() {
    super.initState();
    _loadAppointments();
    _syncTimer = Timer.periodic(const Duration(seconds: 1), (_) => _loadAppointments());
  }

  Future<void> _loadAppointments() async {
    final loaded = await PsynovaSyncService.loadAppointments();
    if (mounted) {
      setState(() {
        _appointments = loaded;
      });
    }
  }

  @override
  void dispose() {
    _syncTimer?.cancel();
    super.dispose();
  }

  List<Map<String, dynamic>> _getFiltered(String status) {
    if (_appointments.isEmpty) {
      if (status == 'Upcoming') {
        return [
          {
            'id': 'default-1',
            'therapistName': 'Dr. Sarah Jenkins',
            'type': 'Cognitive Behavioral Therapy (50m)',
            'time': 'Today, 4:00 PM',
            'price': '\$120.00',
            'status': 'Upcoming',
          }
        ];
      } else if (status == 'Completed') {
        return [
          {
            'id': 'default-2',
            'therapistName': 'Dr. Michael Chen',
            'type': 'Mindfulness Consultation',
            'time': 'July 20, 2026',
            'price': '\$140.00',
            'status': 'Completed',
          }
        ];
      }
      return [];
    }

    return _appointments.where((a) {
      final st = (a['status'] as String? ?? 'Upcoming').toLowerCase();
      if (status == 'Upcoming') return st == 'upcoming' || st == 'active';
      if (status == 'Completed') return st == 'completed';
      if (status == 'Cancelled') return st == 'cancelled' || st == 'rejected';
      return false;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final upcomingList = _getFiltered('Upcoming');
    final completedList = _getFiltered('Completed');
    final cancelledList = _getFiltered('Cancelled');

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Therapy Sessions'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Upcoming'),
              Tab(text: 'Completed'),
              Tab(text: 'Cancelled'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Upcoming Sessions Tab
            _buildSessionList(context, upcomingList, isUpcoming: true),

            // Completed Tab
            _buildSessionList(context, completedList, isUpcoming: false),

            // Cancelled Tab
            cancelledList.isEmpty
                ? const Center(child: Text('No cancelled sessions'))
                : _buildSessionList(context, cancelledList, isUpcoming: false),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionList(BuildContext context, List<Map<String, dynamic>> sessions, {required bool isUpcoming}) {
    if (sessions.isEmpty) {
      return const Center(child: Text('No sessions found'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: sessions.length,
      itemBuilder: (context, index) {
        final apt = sessions[index];
        final therapist = apt['therapistName'] ?? 'Dr. Practitioner';
        final type = apt['type'] ?? 'CBT Consultation';
        final time = apt['time'] ?? 'Scheduled';
        final status = apt['status'] ?? 'Confirmed';

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: GlassContainer(
            onTap: isUpcoming ? () => context.push('/video-consultation') : null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isUpcoming ? AppColors.primaryIndigo.withValues(alpha: 0.15) : Colors.grey.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          color: isUpcoming ? AppColors.primaryIndigo : Colors.grey.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.primaryIndigo,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            therapist,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            type,
                            style: const TextStyle(color: AppColors.textSecondaryLight, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.textSecondaryLight),
                    const SizedBox(width: 6),
                    Text(
                      time,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                  ],
                ),
                if (isUpcoming) ...[
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.lock_outline_rounded),
                    label: const Text('Text Therapist (🔒 E2EE Encrypted)'),
                    onPressed: () => context.push('/chat-detail/t-1'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 44),
                      backgroundColor: AppColors.primaryIndigo,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

