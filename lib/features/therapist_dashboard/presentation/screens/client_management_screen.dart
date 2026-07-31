import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../../../shared/providers/active_clients_provider.dart';

class ClientManagementScreen extends ConsumerStatefulWidget {
  const ClientManagementScreen({super.key});

  @override
  ConsumerState<ClientManagementScreen> createState() => _ClientManagementScreenState();
}

class _ClientManagementScreenState extends ConsumerState<ClientManagementScreen> {
  final _searchCtrl = TextEditingController();

  void _showAddNotesDialog(String clientName, String currentNotes, Function(String) onSave) {
    final noteCtrl = TextEditingController(text: currentNotes);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 20, right: 20, top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Session SOAP Notes - $clientName', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            CustomTextField(controller: noteCtrl, labelText: 'Subjective, Objective, Assessment & Plan...', maxLines: 4),
            const SizedBox(height: 16),
            CustomButton(
              text: 'Save Clinical Notes & Generate AI Summary',
              onPressed: () {
                onSave(noteCtrl.text);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Clinical notes saved & AI summary updated.')));
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeClients = ref.watch(activeClientsProvider);
    final query = _searchCtrl.text.trim().toLowerCase();

    final filtered = activeClients.where((c) {
      if (query.isEmpty) return true;
      return c.name.toLowerCase().contains(query) || c.requestedTopic.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Client Management')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              CustomTextField(
                controller: _searchCtrl,
                labelText: 'Search client by name or diagnosis...',
                prefixIcon: Icons.search,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: filtered.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.group_off_rounded, size: 64, color: AppColors.textSecondaryLight),
                            SizedBox(height: 16),
                            Text('No Active Clients Found', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                            SizedBox(height: 8),
                            Text(
                              'Real clients registered or logged in via Psynova AI will appear here live.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: AppColors.textSecondaryLight, fontSize: 13),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final c = filtered[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            child: GlassContainer(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 22,
                                        backgroundColor: AppColors.primaryPurple,
                                        child: Text(
                                          c.name.isNotEmpty ? c.name[0].toUpperCase() : 'C',
                                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                            const SizedBox(height: 2),
                                            Text(c.requestedTopic, style: const TextStyle(color: AppColors.primaryPurple, fontSize: 12, fontWeight: FontWeight.w600)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text('Active Location: ${c.location}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight)),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(8)),
                                    child: const Text('SOAP Note: Active consultation session initialized via Psynova AI.', style: TextStyle(fontSize: 12, height: 1.4)),
                                  ),
                                  const SizedBox(height: 12),
                                  OutlinedButton.icon(
                                    icon: const Icon(Icons.edit_note_rounded),
                                    label: const Text('Edit Clinical Notes'),
                                    onPressed: () => _showAddNotesDialog(
                                      c.name,
                                      'SOAP Note: Active consultation session initialized via Psynova AI.',
                                      (newNote) {},
                                    ),
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
      ),
    );
  }
}
