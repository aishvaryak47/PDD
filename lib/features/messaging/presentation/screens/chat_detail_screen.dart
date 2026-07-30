import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/services/psynova_sync_service.dart';

class ChatDetailScreen extends StatefulWidget {
  final String userId;
  const ChatDetailScreen({super.key, required this.userId});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _msgController = TextEditingController();
  Timer? _syncTimer;
  String _therapistName = 'Therapist';
  List<Map<String, dynamic>> _messages = [];
  List<Map<String, dynamic>> _allConversations = [];

  @override
  void initState() {
    super.initState();
    _loadData();
    _syncTimer = Timer.periodic(const Duration(milliseconds: 500), (_) => _loadData());
  }

  void _loadData() async {
    final convs = await PsynovaSyncService.loadConversations();
    _allConversations = convs;

    final targetId = widget.userId.toLowerCase();
    final match = convs.firstWhere(
      (c) {
        final tId = (c['therapistId'] as String? ?? '').toLowerCase();
        final cId = (c['id'] as String? ?? '').toLowerCase();
        final tName = (c['therapistName'] as String? ?? '').toLowerCase();
        return tId == targetId || cId == 'conv-$targetId' || cId == targetId || tName.contains(targetId);
      },
      orElse: () => convs.isNotEmpty ? convs.first : <String, dynamic>{},
    );

    if (match.isNotEmpty) {
      final name = match['therapistName'] as String? ?? 'Therapist';
      final rawMsgs = (match['messages'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      if (mounted) {
        setState(() {
          _therapistName = name;
          _messages = rawMsgs;
        });
      }
    }
  }

  void _sendMessage() async {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;

    final convId = 'conv-${widget.userId}';
    final existingIndex = _allConversations.indexWhere(
      (c) => c['therapistId'] == widget.userId || c['id'] == convId,
    );

    final newMsg = {
      'sender': 'client',
      'text': text,
      'time': 'Just now',
    };

    if (existingIndex >= 0) {
      final conv = _allConversations[existingIndex];
      final msgs = (conv['messages'] as List).cast<Map<String, dynamic>>();
      msgs.add(newMsg);
      conv['messages'] = msgs;
      conv['lastMsg'] = text;
      conv['time'] = 'Just now';
    } else {
      _allConversations.insert(0, {
        'id': convId,
        'therapistId': widget.userId,
        'therapistName': _therapistName,
        'clientName': 'Client User',
        'avatar': 'https://i.pravatar.cc/150?img=32',
        'lastMsg': text,
        'time': 'Just now',
        'isOnline': true,
        'messages': [newMsg],
      });
    }

    await PsynovaSyncService.saveConversations(_allConversations);
    _msgController.clear();
    _loadData();
  }

  @override
  void dispose() {
    _syncTimer?.cancel();
    _msgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primaryIndigo,
              child: Icon(Icons.person, size: 22, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_therapistName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const Text('Online • Licensed Therapist', style: TextStyle(fontSize: 11, color: AppColors.moodEcstatic)),
              ],
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // E2EE Encryption Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              color: Colors.green.withValues(alpha: 0.1),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_rounded, size: 14, color: Colors.green),
                  SizedBox(width: 6),
                  Text(
                    'End-to-End Encrypted (E2EE) HIPAA Compliant Direct Texting',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _messages.isEmpty
                  ? const Center(
                      child: Text('Start a secure conversation...', style: TextStyle(color: AppColors.textSecondaryLight)),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final msg = _messages[index];
                        final isMe = msg['sender'] == 'client' || msg['sender'] == 'me';
                        return Align(
                          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(14),
                            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                            decoration: BoxDecoration(
                              color: isMe
                                  ? AppColors.primaryIndigo
                                  : (Theme.of(context).brightness == Brightness.dark
                                      ? AppColors.darkSurface
                                      : Colors.white),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                              children: [
                                Text(
                                  msg['text'] as String? ?? '',
                                  style: TextStyle(color: isMe ? Colors.white : null, height: 1.4),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  msg['time'] as String? ?? 'Just now',
                                  style: TextStyle(fontSize: 10, color: isMe ? Colors.white70 : AppColors.textSecondaryLight),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.attach_file_rounded, color: AppColors.textSecondaryLight),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('File attachment selected')));
                    },
                  ),
                  Expanded(
                    child: CustomTextField(
                      controller: _msgController,
                      labelText: 'Type secure message...',
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    icon: const Icon(Icons.send_rounded),
                    style: IconButton.styleFrom(backgroundColor: AppColors.primaryIndigo),
                    onPressed: _sendMessage,
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
