import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../core/network/api_client.dart';

class AIChatScreen extends StatefulWidget {
  const AIChatScreen({super.key});

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final TextEditingController _msgController = TextEditingController();
  final List<Map<String, String>> _messages = [
    {
      'sender': 'ai',
      'text':
          'Hello! I am your PSYNOVA AI Assistant. How are you feeling right now? I am here to listen, offer mindfulness exercises, and provide coping strategies.'
    }
  ];
  bool _isLoading = false;

  void _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add({'sender': 'user', 'text': text});
      _isLoading = true;
    });
    _msgController.clear();

    try {
      final res =
          await ApiClient().dio.post('/ai/chat', data: {'message': text});
      final reply = res.data['reply'];
      setState(() {
        _messages.add({'sender': 'ai', 'text': reply});
        _isLoading = false;
      });
    } catch (e) {
      // Mock Fallback Response
      await Future.delayed(const Duration(seconds: 1));
      String fallback =
          "I hear you. Remember to take a deep breath. Try focusing on the present moment and grounding yourself.";
      if (text.toLowerCase().contains("anxious") ||
          text.toLowerCase().contains("stress")) {
        fallback =
            "Anxiety can feel very heavy. Let's try a quick 4-7-8 breathing exercise together: Inhale for 4 seconds, hold for 7 seconds, and exhale slowly for 8 seconds.";
      }
      setState(() {
        _messages.add({'sender': 'ai', 'text': fallback});
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.auto_awesome, color: AppColors.accentTeal),
            SizedBox(width: 8),
            Text('PSYNOVA AI Assistant'),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Medical Disclaimer Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: AppColors.primaryIndigo.withValues(alpha: 0.1),
              child: const Row(
                children: [
                  Icon(Icons.info_outline_rounded,
                      size: 18, color: AppColors.primaryIndigo),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'AI provides supportive emotional guidance. It is not a medical diagnosis tool.',
                      style: TextStyle(
                          fontSize: 11,
                          color: AppColors.primaryIndigo,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  final isUser = msg['sender'] == 'user';
                  return Align(
                    alignment:
                        isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.78),
                      decoration: BoxDecoration(
                        gradient: isUser ? AppColors.primaryGradient : null,
                        color: isUser
                            ? null
                            : (Theme.of(context).brightness == Brightness.dark
                                ? AppColors.darkSurface
                                : Colors.white),
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(16),
                          topRight: const Radius.circular(16),
                          bottomLeft: Radius.circular(isUser ? 16 : 4),
                          bottomRight: Radius.circular(isUser ? 4 : 16),
                        ),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 4))
                        ],
                      ),
                      child: Text(
                        msg['text']!,
                        style: TextStyle(
                          color: isUser
                              ? Colors.white
                              : (Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white
                                  : AppColors.textPrimaryLight),
                          height: 1.4,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    SizedBox(width: 16),
                    SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2)),
                    SizedBox(width: 8),
                    Text('PSYNOVA AI is thinking...',
                        style: TextStyle(
                            fontSize: 12, color: AppColors.textSecondaryLight)),
                  ],
                ),
              ),

            // Quick Coping Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                children: [
                  ActionChip(
                    avatar: const Icon(Icons.air, size: 16),
                    label: const Text('4-7-8 Breathing'),
                    onPressed: () => _sendMessage(
                        'Can you guide me through a 4-7-8 breathing exercise?'),
                  ),
                  const SizedBox(width: 8),
                  ActionChip(
                    avatar: const Icon(Icons.shield_outlined, size: 16),
                    label: const Text('Anxiety Relief'),
                    onPressed: () => _sendMessage(
                        'I am feeling anxious right now, how can I ground myself?'),
                  ),
                  const SizedBox(width: 8),
                  ActionChip(
                    avatar: const Icon(Icons.bedtime_outlined, size: 16),
                    label: const Text('Sleep Tips'),
                    onPressed: () => _sendMessage(
                        'What are some tips to sleep better tonight?'),
                  ),
                ],
              ),
            ),

            // Input Bar
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _msgController,
                      labelText: 'Talk to PSYNOVA AI...',
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    icon: const Icon(Icons.send_rounded),
                    style: IconButton.styleFrom(
                        backgroundColor: AppColors.primaryIndigo),
                    onPressed: () => _sendMessage(_msgController.text),
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
