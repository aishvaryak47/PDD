import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../providers/therapist_provider.dart';
import '../../../auth/providers/auth_provider.dart';

class TherapistDashboardScreen extends ConsumerStatefulWidget {
  const TherapistDashboardScreen({super.key});

  @override
  ConsumerState<TherapistDashboardScreen> createState() =>
      _TherapistDashboardScreenState();
}

class _TherapistDashboardScreenState
    extends ConsumerState<TherapistDashboardScreen> {

  void _showAddAppointmentDialog() {
    final nameController = TextEditingController();
    final typeController = TextEditingController(text: 'CBT Consultation');
    String riskLevel = 'Moderate';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Schedule New Session', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Client Name', hintText: 'e.g. Alex Morgan'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: typeController,
              decoration: const InputDecoration(labelText: 'Session Type', hintText: 'e.g. CBT Consultation'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: riskLevel,
              decoration: const InputDecoration(labelText: 'Risk Assessment'),
              items: const [
                DropdownMenuItem(value: 'Stable', child: Text('Stable')),
                DropdownMenuItem(value: 'Moderate', child: Text('Moderate')),
                DropdownMenuItem(value: 'High', child: Text('High Risk')),
              ],
              onChanged: (val) {
                if (val != null) riskLevel = val;
              },
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryPurple),
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                ref.read(therapistProvider.notifier).addAppointment({
                  'id': 'apt-${DateTime.now().millisecondsSinceEpoch}',
                  'clientName': nameController.text.trim(),
                  'avatar': 'https://i.pravatar.cc/150?img=${DateTime.now().second % 70}',
                  'time': '10:00 AM - 10:50 AM',
                  'type': typeController.text.trim(),
                  'status': 'Upcoming',
                  'risk': riskLevel,
                  'isUrgent': riskLevel == 'High',
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Scheduled session for ${nameController.text.trim()}!'), backgroundColor: AppColors.moodEcstatic),
                );
              }
            },
            child: const Text('Add Session', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final state = ref.watch(therapistProvider);
    final notifier = ref.read(therapistProvider.notifier);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Hero Briefing Banner
              _buildHeroHeader(user?.fullName, state, notifier),
              const SizedBox(height: 20),

              // 2. Simple Metrics Grid
              _buildMetricsGrid(state),
              const SizedBox(height: 24),

              // 3. Today's Appointment Timeline
              _buildScheduleTimeline(state),
              const SizedBox(height: 28),

              // 4. Client Caseload Data Table
              _buildClientsDataTable(state),
              const SizedBox(height: 28),

              // 5. Practice Baseline Analytics Chart
              _buildOutcomesChartSection(state),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // --- HERO HEADER ---
  Widget _buildHeroHeader(String? name, TherapistState state, TherapistNotifier notifier) {
    final displayName = (name != null && name.isNotEmpty)
        ? (name.toLowerCase().startsWith('dr') ? name : 'Dr. $name')
        : 'Dr. Specialist';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPurple.withValues(alpha: 0.25),
            blurRadius: 14,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome, $displayName 🩺',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Wednesday, July 29, 2026 • Live Clinical Portal',
                    style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: state.isAcceptingClients ? AppColors.moodEcstatic : Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          state.isAcceptingClients ? 'Accepting Clients' : 'Offline',
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 6),
                        Switch(
                          value: state.isAcceptingClients,
                          activeThumbColor: Colors.white,
                          onChanged: (val) => notifier.toggleAcceptingClients(val),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- STATS METRICS GRID ---
  Widget _buildMetricsGrid(TherapistState state) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = (constraints.maxWidth - 36) / 4;
        final cardWidth = w < 160 ? (constraints.maxWidth - 12) / 2 : w;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildStatCard('Active Caseload', '${state.appointments.length} Clients', Icons.groups_rounded, AppColors.primaryPurple, cardWidth),
            _buildStatCard('Today\'s Sessions', '${state.appointments.length} Scheduled', Icons.event_available_rounded, const Color(0xFF3B82F6), cardWidth),
            _buildStatCard('SOAP Notes', '${state.soapNotes.length} Saved', Icons.edit_note_rounded, AppColors.moodEcstatic, cardWidth),
            _buildStatCard('Recovery Base', '0.0%', Icons.analytics_rounded, AppColors.accentTeal, cardWidth),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(String title, String val, IconData icon, Color color, double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackgroundLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(val, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(title, style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight)),
        ],
      ),
    );
  }

  // --- TODAY'S SCHEDULE TIMELINE ---
  Widget _buildScheduleTimeline(TherapistState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Icon(Icons.calendar_month_rounded, color: AppColors.primaryPurple, size: 22),
                SizedBox(width: 8),
                Text(
                  'Today\'s Sessions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryPurple,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.add_rounded, color: Colors.white, size: 18),
              label: const Text('+ Schedule Session', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              onPressed: _showAddAppointmentDialog,
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (state.appointments.isEmpty)
          GlassContainer(
            child: Padding(
              padding: const EdgeInsets.all(28.0),
              child: Center(
                child: Column(
                  children: [
                    const Icon(Icons.event_note_rounded, size: 44, color: AppColors.primaryPurple),
                    const SizedBox(height: 12),
                    const Text('No sessions scheduled yet', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 4),
                    const Text('Click "+ Schedule Session" to add a client consultation.', style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight), textAlign: TextAlign.center),
                    const SizedBox(height: 14),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryPurple),
                      onPressed: _showAddAppointmentDialog,
                      child: const Text('Schedule First Session', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          Column(
            children: state.appointments.map((apt) {
              final isUrgent = apt['isUrgent'] as bool;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: GlassContainer(
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: NetworkImage(apt['avatar'] as String),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(apt['clientName'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                if (isUrgent) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(color: AppColors.accentCoral.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
                                    child: const Text('⚡ High Risk', style: TextStyle(color: AppColors.accentCoral, fontSize: 10, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text('${apt['time']} • ${apt['type']}', style: const TextStyle(color: AppColors.textSecondaryLight, fontSize: 12)),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryPurple,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            icon: const Icon(Icons.chat_bubble_rounded, color: Colors.white, size: 16),
                            label: const Text('Message', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                            onPressed: () => context.push('/therapist-messages'),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                            onPressed: () => context.push('/therapist-notes'),
                            child: const Text('SOAP Note', style: TextStyle(fontSize: 12)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  // --- RECENT CLIENTS DATA TABLE ---
  Widget _buildClientsDataTable(TherapistState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Client Caseload', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextButton(
              onPressed: () => context.push('/client-management'),
              child: const Text('Manage CRM →', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryPurple)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (state.appointments.isEmpty)
          const GlassContainer(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Center(
                child: Text(
                  'No active client records. Click "+ Schedule Session" to create your first client session.',
                  style: TextStyle(color: AppColors.textSecondaryLight, fontSize: 13),
                ),
              ),
            ),
          )
        else
          GlassContainer(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Client Name', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Session Type', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Time', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Risk Level', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                ],
                rows: state.appointments.map((apt) {
                  final riskColor = apt['risk'] == 'High'
                      ? AppColors.accentCoral
                      : apt['risk'] == 'Moderate'
                          ? Colors.amber.shade700
                          : AppColors.moodEcstatic;
                  return DataRow(
                    cells: [
                      DataCell(Text(apt['clientName'] as String, style: const TextStyle(fontWeight: FontWeight.bold))),
                      DataCell(Text(apt['type'] as String, style: const TextStyle(fontSize: 12))),
                      DataCell(Text(apt['time'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: riskColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                          child: Text(apt['risk'] as String, style: TextStyle(color: riskColor, fontWeight: FontWeight.bold, fontSize: 11)),
                        ),
                      ),
                      DataCell(
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 10)),
                          onPressed: () => context.push('/client-management'),
                          child: const Text('View Record', style: TextStyle(fontSize: 11)),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
      ],
    );
  }

  // --- PRACTICE OUTCOMES CHART ---
  Widget _buildOutcomesChartSection(TherapistState state) {
    return GlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Weekly Recovery Baseline', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text('Fresh Start (0.0)', style: TextStyle(color: AppColors.moodEcstatic, fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 140,
            child: BarChart(
              BarChartData(
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (val, meta) {
                        const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                        if (val.toInt() >= 0 && val.toInt() < days.length) {
                          return Text(days[val.toInt()], style: const TextStyle(fontSize: 11));
                        }
                        return const Text('');
                      },
                    ),
                  ),
                ),
                barGroups: List.generate(7, (i) => BarChartGroupData(x: i, barRods: [BarChartRodData(toY: 0, color: AppColors.primaryPurple, width: 16, borderRadius: BorderRadius.circular(4))])),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
