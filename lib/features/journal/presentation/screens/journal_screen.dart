import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../../../shared/services/psynova_sync_service.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  List<Map<String, String>> _journals = [];

  final List<Map<String, String>> _defaultJournals = [
    {
      'title': 'Overcoming Work Anxiety',
      'date': 'July 28, 2026',
      'content':
          'Felt much calmer after practicing the 4-7-8 breathing technique before my presentation today.',
      'summary':
          'AI Summary: Strong progress in applying cognitive coping strategies under high-pressure work settings.',
    },
    {
      'title': 'Evening Reflection & Gratitude',
      'date': 'July 25, 2026',
      'content':
          'Went for a peaceful walk in the park. Grateful for supportive family and good health.',
      'summary':
          'AI Summary: Focus on mindfulness, nature immersion, and positive social connections.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadJournals();
  }

  Future<void> _loadJournals() async {
    final loaded = await PsynovaSyncService.loadJournals();
    if (mounted) {
      setState(() {
        if (loaded.isNotEmpty) {
          _journals = loaded.map((e) => Map<String, String>.from(e)).toList();
        } else {
          _journals = List.from(_defaultJournals);
        }
      });
    }
  }

  void _showNewJournalDialog() {
    final titleCtrl = TextEditingController();
    final contentCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('New Journal Entry',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            CustomTextField(controller: titleCtrl, labelText: 'Entry Title'),
            const SizedBox(height: 16),
            CustomTextField(
                controller: contentCtrl,
                labelText: 'Write your thoughts...',
                maxLines: 4),
            const SizedBox(height: 20),
            CustomButton(
              text: 'Save & Generate AI Summary',
              onPressed: () async {
                if (titleCtrl.text.isNotEmpty && contentCtrl.text.isNotEmpty) {
                  final newEntry = {
                    'title': titleCtrl.text,
                    'date': 'Today',
                    'content': contentCtrl.text,
                    'summary':
                        'AI Summary: Reflection on "${titleCtrl.text}". Key emotional theme of self-awareness.',
                  };

                  final updated = [newEntry, ..._journals];
                  await PsynovaSyncService.saveJournals(updated);

                  setState(() {
                    _journals = updated;
                  });

                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personal Mental Health Journal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.mic_rounded, color: AppColors.primaryIndigo),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content:
                        Text('Voice Journal Recording Started... Speak now.')),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Entry'),
        backgroundColor: AppColors.primaryIndigo,
        onPressed: _showNewJournalDialog,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _journals.length,
        itemBuilder: (context, index) {
          final item = _journals[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: GlassContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(item['title'] ?? 'Journal Entry',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(item['date'] ?? 'Today',
                          style: const TextStyle(
                              color: AppColors.textSecondaryLight,
                              fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(item['content'] ?? '', style: const TextStyle(height: 1.4)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryPurple.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.auto_awesome,
                            color: AppColors.primaryPurple, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            item['summary'] ?? 'AI Summary Available',
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryPurple),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

