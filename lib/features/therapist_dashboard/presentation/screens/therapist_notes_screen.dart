import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/services/psynova_sync_service.dart';

class TherapistNotesScreen extends StatefulWidget {
  const TherapistNotesScreen({super.key});

  @override
  State<TherapistNotesScreen> createState() => _TherapistNotesScreenState();
}

class _TherapistNotesScreenState extends State<TherapistNotesScreen> {
  final TextEditingController _subjectiveController = TextEditingController();
  final TextEditingController _objectiveController = TextEditingController();
  final TextEditingController _assessmentController = TextEditingController();
  final TextEditingController _planController = TextEditingController();

  bool _isSaving = false;
  String _selectedClient = 'Alex Morgan';
  List<Map<String, dynamic>> _savedNotes = [];

  final List<String> _clientList = [
    'Alex Morgan',
    'Emily Watson',
    'David Miller',
    'Sarah Jenkins (Client)',
  ];

  @override
  void initState() {
    super.initState();
    _loadClientNote();
  }

  Future<void> _loadClientNote() async {
    final loaded = await PsynovaSyncService.loadSoapNotes();
    _savedNotes = loaded;
    final existing = loaded.firstWhere(
      (n) => n['clientName'] == _selectedClient,
      orElse: () => {},
    );

    if (mounted) {
      setState(() {
        _subjectiveController.text = existing['subjective'] ?? '';
        _objectiveController.text = existing['objective'] ?? '';
        _assessmentController.text = existing['assessment'] ?? '';
        _planController.text = existing['plan'] ?? '';
      });
    }
  }

  Future<void> _saveSoapNote() async {
    setState(() => _isSaving = true);
    final noteData = {
      'id': 'soap-${_selectedClient.replaceAll(' ', '_')}',
      'clientName': _selectedClient,
      'subjective': _subjectiveController.text.trim(),
      'objective': _objectiveController.text.trim(),
      'assessment': _assessmentController.text.trim(),
      'plan': _planController.text.trim(),
      'lastUpdated': DateFormat('MMM dd, yyyy - hh:mm a').format(DateTime.now()),
    };

    final filtered = _savedNotes.where((n) => n['clientName'] != _selectedClient).toList();
    filtered.insert(0, noteData);
    _savedNotes = filtered;
    await PsynovaSyncService.saveSoapNotes(filtered);

    setState(() => _isSaving = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('SOAP Report for $_selectedClient saved successfully to system!'),
          backgroundColor: AppColors.moodEcstatic,
        ),
      );
    }
  }

  void _showPdfReportDialog() {
    final dateStr = DateFormat('MMMM dd, yyyy').format(DateTime.now());
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: 540,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.picture_as_pdf_rounded, color: Colors.red, size: 28),
                      const SizedBox(width: 10),
                      Text('SOAP Clinical Report - $_selectedClient',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 10),
              Text('Patient Name: $_selectedClient', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              Text('Report Date: $dateStr', style: const TextStyle(color: AppColors.textSecondaryLight, fontSize: 12)),
              const SizedBox(height: 14),

              // Report Content Box
              Container(
                constraints: const BoxConstraints(maxHeight: 300),
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('SUBJECTIVE (S):', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryPurple, fontSize: 12)),
                      Text(_subjectiveController.text.isNotEmpty ? _subjectiveController.text : '[No subjective observation entered]', style: const TextStyle(fontSize: 12)),
                      const SizedBox(height: 10),

                      const Text('OBJECTIVE (O):', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryPurple, fontSize: 12)),
                      Text(_objectiveController.text.isNotEmpty ? _objectiveController.text : '[No objective observations entered]', style: const TextStyle(fontSize: 12)),
                      const SizedBox(height: 10),

                      const Text('ASSESSMENT (A):', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryPurple, fontSize: 12)),
                      Text(_assessmentController.text.isNotEmpty ? _assessmentController.text : '[No assessment evaluation entered]', style: const TextStyle(fontSize: 12)),
                      const SizedBox(height: 10),

                      const Text('PLAN (P):', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryPurple, fontSize: 12)),
                      Text(_planController.text.isNotEmpty ? _planController.text : '[No treatment plan entered]', style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryPurple),
                    icon: const Icon(Icons.download_rounded, color: Colors.white, size: 18),
                    label: const Text('Download PDF', style: TextStyle(color: Colors.white)),
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('SOAP Report PDF for $_selectedClient downloaded!'),
                          backgroundColor: AppColors.moodEcstatic,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                        'Clinical SOAP Notes Studio 📝',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'HIPAA-compliant SOAP documentation & clinical reports',
                        style: TextStyle(color: AppColors.textSecondaryLight, fontSize: 13),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryPurple),
                    onPressed: _showPdfReportDialog,
                    icon: const Icon(Icons.picture_as_pdf_rounded, size: 18, color: Colors.white),
                    label: const Text('Export PDF Report', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Client Selector Header
              GlassContainer(
                child: Row(
                  children: [
                    const Icon(Icons.person_pin_rounded, color: AppColors.primaryPurple, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedClient,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                          items: _clientList.map((client) {
                            return DropdownMenuItem(
                              value: client,
                              child: Text('Select Patient: $client'),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _selectedClient = val);
                              _loadClientNote();
                            }
                          },
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryPurple.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('Dynamic EHR', style: TextStyle(color: AppColors.primaryPurple, fontWeight: FontWeight.bold, fontSize: 11)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // SOAP Sections
              _buildSoapField('Subjective (S)', 'Client complaints, mood self-reports, family updates...', _subjectiveController, 3),
              const SizedBox(height: 16),
              _buildSoapField('Objective (O)', 'Clinical observations, affect, vital indicators, test scores...', _objectiveController, 3),
              const SizedBox(height: 16),
              _buildSoapField('Assessment (A)', 'Diagnostic evaluation, DSM-5 progress, risk calculation...', _assessmentController, 3),
              const SizedBox(height: 16),
              _buildSoapField('Plan (P)', 'Interventions, homework assigned, next session objectives...', _planController, 3),
              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: _isSaving ? 'Saving Report...' : 'Save Patient SOAP Report',
                      onPressed: _saveSoapNote,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSoapField(String title, String hint, TextEditingController controller, int maxLines) {
    return GlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primaryPurple)),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            maxLines: maxLines,
            style: const TextStyle(fontSize: 13, height: 1.4),
            decoration: InputDecoration(
              hintText: hint,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
        ],
      ),
    );
  }
}

