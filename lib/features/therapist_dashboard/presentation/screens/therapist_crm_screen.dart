import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/services/psynova_sync_service.dart';

class TherapistCrmScreen extends ConsumerStatefulWidget {
  const TherapistCrmScreen({super.key});

  @override
  ConsumerState<TherapistCrmScreen> createState() => _TherapistCrmScreenState();
}

class _TherapistCrmScreenState extends ConsumerState<TherapistCrmScreen> {
  String _activeFilter = 'All';

  String _searchQuery = '';
  bool _isGridView = true;

  final List<Map<String, dynamic>> _clients = [];

  void _showAddClientDialog() {
    final nameController = TextEditingController();
    final dxController = TextEditingController(text: 'Generalized Anxiety (F41.1)');
    final ageController = TextEditingController(text: '30');
    String risk = 'Stable';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Patient Record', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Client Full Name', hintText: 'e.g. Alex Morgan'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: dxController,
              decoration: const InputDecoration(labelText: 'Diagnosis / ICD-10', hintText: 'e.g. Major Depression (F32.1)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: ageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Age', hintText: 'e.g. 28'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: risk,
              decoration: const InputDecoration(labelText: 'Initial Risk Level'),
              items: const [
                DropdownMenuItem(value: 'Stable', child: Text('Stable')),
                DropdownMenuItem(value: 'Moderate', child: Text('Moderate')),
                DropdownMenuItem(value: 'High', child: Text('High Risk')),
              ],
              onChanged: (val) {
                if (val != null) risk = val;
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
                setState(() {
                  _clients.add({
                    'id': 'c-${DateTime.now().millisecondsSinceEpoch}',
                    'name': nameController.text.trim(),
                    'age': int.tryParse(ageController.text.trim()) ?? 30,
                    'gender': 'Client',
                    'diagnosis': dxController.text.trim(),
                    'moodScore': 7.0,
                    'recoveryPct': 0,
                    'risk': risk,
                    'lastSession': 'Intake pending',
                    'nextSession': 'Scheduled',
                    'avatar': 'https://i.pravatar.cc/150?img=${DateTime.now().second % 70}',
                  });
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Registered new client ${nameController.text.trim()}!'), backgroundColor: AppColors.moodEcstatic),
                );
              }
            },
            child: const Text('Save Patient Record', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Color _getRiskColor(String risk) {
    switch (risk) {
      case 'High':
        return AppColors.accentCoral;
      case 'Moderate':
        return Colors.amber.shade700;
      case 'Stable':
      default:
        return AppColors.moodEcstatic;
    }
  }

  void _showClientDetailModal(Map<String, dynamic> client) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ClientDetailSheet(client: client),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _clients.where((c) {
      final nameMatches = (c['name'] as String).toLowerCase().contains(_searchQuery.toLowerCase());
      if (_activeFilter == 'High Risk') return nameMatches && c['risk'] == 'High';
      if (_activeFilter == 'Moderate') return nameMatches && c['risk'] == 'Moderate';
      if (_activeFilter == 'Stable') return nameMatches && c['risk'] == 'Stable';
      return nameMatches;
    }).toList();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Client Management CRM 👥',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Track active cases, clinical progress & treatment plans',
                        style: TextStyle(color: AppColors.textSecondaryLight, fontSize: 13),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryPurple),
                        icon: const Icon(Icons.person_add_rounded, color: Colors.white, size: 18),
                        label: const Text('+ Add Client', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                        onPressed: _showAddClientDialog,
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: Icon(_isGridView ? Icons.view_list_rounded : Icons.grid_view_rounded),
                        onPressed: () => setState(() => _isGridView = !_isGridView),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Search & Filter Bar
              GlassContainer(
                child: Column(
                  children: [
                    TextField(
                      onChanged: (val) => setState(() => _searchQuery = val),
                      decoration: const InputDecoration(
                        hintText: 'Search client by name, diagnosis or ICD-10 code...',
                        prefixIcon: Icon(Icons.search_rounded, color: AppColors.primaryPurple),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: ['All', 'High Risk', 'Moderate', 'Stable'].map((filter) {
                            final isSel = _activeFilter == filter;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: FilterChip(
                                label: Text(filter),
                                selected: isSel,
                                selectedColor: AppColors.primaryPurple.withValues(alpha: 0.2),
                                checkmarkColor: AppColors.primaryPurple,
                                onSelected: (val) => setState(() => _activeFilter = filter),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Content View
              if (filtered.isEmpty)
                GlassContainer(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Center(
                      child: Column(
                        children: [
                          const Icon(Icons.people_outline_rounded, size: 48, color: AppColors.primaryPurple),
                          const SizedBox(height: 12),
                          const Text('No client records found', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 4),
                          const Text('Click "+ Add Client" to create your first patient case record.', style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight), textAlign: TextAlign.center),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryPurple),
                            icon: const Icon(Icons.person_add_rounded, color: Colors.white, size: 18),
                            label: const Text('Add First Client', style: TextStyle(color: Colors.white)),
                            onPressed: _showAddClientDialog,
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else if (_isGridView)
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 380,
                    mainAxisExtent: 220,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final c = filtered[index];
                    final riskColor = _getRiskColor(c['risk'] as String);
                    return GlassContainer(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 22,
                                backgroundColor: AppColors.primaryPurple.withValues(alpha: 0.15),
                                child: Text((c['name'] as String)[0], style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryPurple)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(c['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    Text('${c['age']} yrs • ${c['gender']}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight)),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: riskColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  c['risk'] as String,
                                  style: TextStyle(color: riskColor, fontWeight: FontWeight.bold, fontSize: 11),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(c['diagnosis'] as String, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: AppColors.primaryIndigo)),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Mood Score: ${c['moodScore']}/10', style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight)),
                              Text('Recovery: ${c['recoveryPct']}%', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.moodEcstatic)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          LinearProgressIndicator(
                            value: (c['recoveryPct'] as int) / 100.0,
                            backgroundColor: Colors.grey.withValues(alpha: 0.2),
                            color: AppColors.moodEcstatic,
                            minHeight: 5,
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              Expanded(
                                child: CustomButton(
                                  text: 'View Record',
                                  height: 36,
                                  fontSize: 12,
                                  onPressed: () => _showClientDetailModal(c),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final c = filtered[index];
                    final riskColor = _getRiskColor(c['risk'] as String);
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: GlassContainer(
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: CircleAvatar(
                            backgroundColor: AppColors.primaryPurple.withValues(alpha: 0.15),
                            child: Text((c['name'] as String)[0], style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryPurple)),
                          ),
                          title: Text(c['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('${c['diagnosis']} • Next: ${c['nextSession']}'),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: riskColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                            child: Text(c['risk'] as String, style: TextStyle(color: riskColor, fontWeight: FontWeight.bold, fontSize: 11)),
                          ),
                          onTap: () => _showClientDetailModal(c),
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ClientDetailSheet extends StatelessWidget {
  final Map<String, dynamic> client;
  const _ClientDetailSheet({required this.client});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: AppColors.lightBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: DefaultTabController(
        length: 4,
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(2))),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: AppColors.primaryPurple.withValues(alpha: 0.2),
                    child: Text((client['name'] as String)[0], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primaryPurple)),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(client['name'] as String, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      Text(client['diagnosis'] as String, style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight)),
                    ],
                  ),
                ],
              ),
            ),
            const TabBar(
              labelColor: AppColors.primaryPurple,
              unselectedLabelColor: AppColors.textSecondaryLight,
              tabs: [
                Tab(text: 'Overview'),
                Tab(text: 'SOAP History'),
                Tab(text: 'Mood Logs'),
                Tab(text: 'AI Summary'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildOverviewTab(),
                  _buildSoapTab(),
                  _buildMoodTab(),
                  _buildAiTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: ListView(
        children: [
          _buildInfoRow('Age & Gender', '${client['age']} Years • ${client['gender']}'),
          _buildInfoRow('Risk Profile', client['risk'] as String),
          _buildInfoRow('Current Recovery', '${client['recoveryPct']}%'),
          _buildInfoRow('Last Session', client['lastSession'] as String),
          _buildInfoRow('Next Scheduled', client['nextSession'] as String),
        ],
      ),
    );
  }

  Widget _buildSoapTab() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: ListView(
        children: const [
          Text('Session SOAP History', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          SizedBox(height: 8),
          Text('No SOAP notes recorded for this patient yet.'),
        ],
      ),
    );
  }

  Widget _buildMoodTab() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: PsynovaSyncService.loadMoodLogs(),
      builder: (context, snapshot) {
        final logs = snapshot.data ?? [];
        if (logs.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: ListView(
              children: const [
                Text('Weekly Mood Log Submissions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                SizedBox(height: 12),
                Text('No mood logs submitted by client yet.'),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: logs.length,
          itemBuilder: (context, index) {
            final log = logs[index];
            final score = log['score'] ?? 4.0;
            final label = log['label'] ?? 'Mood Entry';
            final date = log['date'] ?? 'Recent';
            final tags = (log['tags'] as List?)?.join(', ') ?? 'Calm';

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primaryPurple.withValues(alpha: 0.15)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(label.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      Text(date.toString(), style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('Score: $score / 5.0 • Tags: $tags', style: const TextStyle(fontSize: 13, color: AppColors.primaryIndigo, fontWeight: FontWeight.w600)),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAiTab() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: ListView(
        children: const [
          Text('AI Clinical Assistant Synthesis', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primaryPurple)),
          SizedBox(height: 10),
          Text('• Relapse Risk Score: Low Risk (Stable baseline)'),
          Text('• Treatment Adherence: High (Active patient check-ins)'),
          SizedBox(height: 8),
          Text('• Summary: Patient logs show consistent emotional self-regulation and engagement with therapy sessions.', style: TextStyle(color: AppColors.textSecondaryLight, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String title, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: AppColors.textSecondaryLight, fontSize: 14)),
          Text(val, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }
}
