import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/glass_container.dart';

class TherapistAiCopilotScreen extends StatefulWidget {
  const TherapistAiCopilotScreen({super.key});

  @override
  State<TherapistAiCopilotScreen> createState() => _TherapistAiCopilotScreenState();
}

class _TherapistAiCopilotScreenState extends State<TherapistAiCopilotScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, String>> _messages = [
    {
      'sender': 'ai',
      'text': 'Hello Dr. Sarah! I am your PSYNOVA Clinical AI Copilot 🤖.\n\nI can analyze client mood trends, draft CBT homework exercises, predict relapse risks, or generate SOAP summaries. How can I assist your practice today?'
    },
  ];

  void _sendMessage([String? prefilled]) {
    final txt = prefilled ?? _messageController.text.trim();
    if (txt.isEmpty) return;

    setState(() {
      _messages.add({'sender': 'user', 'text': txt});
      if (prefilled == null) _messageController.clear();
    });

    // Simulate AI response
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() {
        _messages.add({
          'sender': 'ai',
          'text': _generateAiResponse(txt),
        });
      });
    });
  }

  String _generateAiResponse(String query) {
    final q = query.toLowerCase();
    if (q.contains('relapse') || q.contains('risk')) {
      return '📊 **Relapse Risk Analysis for Alex Morgan**:\n• GAD-7 trend: 14 → 11 (Steadily improving)\n• Trigger identified: Sleep deprivation (<6 hrs)\n• Relapse probability: **Low (18%)** provided bedtime relaxation protocols are maintained.';
    } else if (q.contains('homework') || q.contains('cbt')) {
      return '📝 **Recommended CBT Homework (Anxiety restructuring)**:\n1. **Thought Log**: Identify 3 automatic thoughts during social interactions.\n2. **Cognitive Reframing**: Replace "Everyone is judging me" with "I am capable and prepared".\n3. **Diaphragmatic Breathing**: 5 minutes twice daily.';
    } else if (q.contains('soap') || q.contains('summary')) {
      return '📄 **Generated Executive SOAP Summary**:\n• **Subjective**: Patient notes anxiety before presentations.\n• **Objective**: Affect congruent, heart rate 72 bpm.\n• **Assessment**: Mild GAD exacerbation secondary to work stress.\n• **Plan**: Weekly cognitive reframing + 10 min grounding.';
    }
    return '🤖 **Clinical Insight**: Based on recent diagnostic telemetry, client engagement is high (94%). I recommend continuing structured exposure therapy while monitoring sleep quality logs.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(Icons.auto_awesome_rounded, color: AppColors.primaryPurple, size: 28),
                  SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('PSYNOVA Clinical AI Copilot', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      Text('GPT-4o & Clinical Knowledge Trained', style: TextStyle(color: AppColors.textSecondaryLight, fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Quick Prompts
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  _buildPromptChip('Predict Alex Morgan Relapse Risk'),
                  _buildPromptChip('Generate CBT Homework Exercise'),
                  _buildPromptChip('Draft SOAP Note Summary'),
                  _buildPromptChip('Practitioner Burnout Checklist'),
                ],
              ),
            ),

            // Chat Messages List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  final isUser = msg['sender'] == 'user';
                  return Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isUser ? AppColors.primaryPurple : AppColors.cardBackgroundLight,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2)),
                        ],
                      ),
                      child: Text(
                        msg['text']!,
                        style: TextStyle(
                          color: isUser ? Colors.white : AppColors.textPrimaryLight,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Input Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: GlassContainer(
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: const InputDecoration(
                          hintText: 'Ask AI Copilot for clinical guidance, homework or SOAP synthesis...',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 12),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send_rounded, color: AppColors.primaryPurple),
                      onPressed: () => _sendMessage(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromptChip(String text) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ActionChip(
        label: Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primaryPurple)),
        backgroundColor: AppColors.primaryPurple.withValues(alpha: 0.08),
        onPressed: () => _sendMessage(text),
      ),
    );
  }
}
