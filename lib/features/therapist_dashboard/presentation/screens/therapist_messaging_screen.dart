import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../../../shared/services/psynova_sync_service.dart';

class TherapistMessagingScreen extends StatefulWidget {
  const TherapistMessagingScreen({super.key});

  @override
  State<TherapistMessagingScreen> createState() => _TherapistMessagingScreenState();
}

class _TherapistMessagingScreenState extends State<TherapistMessagingScreen> {
  String? _selectedChatId;
  final TextEditingController _messageController = TextEditingController();
  List<Map<String, dynamic>> _conversations = [];
  Timer? _syncTimer;

  @override
  void initState() {
    super.initState();
    _loadConversations();
    _syncTimer = Timer.periodic(const Duration(milliseconds: 500), (_) => _loadConversations());
  }

  void _loadConversations() async {
    final convs = await PsynovaSyncService.loadConversations();
    if (mounted) {
      setState(() {
        _conversations = convs;
        if (_selectedChatId == null && convs.isNotEmpty) {
          _selectedChatId = convs.first['id'] as String?;
        }
      });
    }
  }

  void _sendMessage() async {
    if (_selectedChatId == null) return;
    final txt = _messageController.text.trim();
    if (txt.isEmpty) return;

    final chatIndex = _conversations.indexWhere((c) => c['id'] == _selectedChatId);
    if (chatIndex >= 0) {
      final chat = _conversations[chatIndex];
      final msgs = (chat['messages'] as List).cast<Map<String, dynamic>>();
      msgs.add({
        'sender': 'therapist',
        'text': txt,
        'time': 'Just now',
      });
      chat['messages'] = msgs;
      chat['lastMsg'] = txt;
      chat['time'] = 'Just now';

      await PsynovaSyncService.saveConversations(_conversations);
      _messageController.clear();
      _loadConversations();
    }
  }

  @override
  void dispose() {
    _syncTimer?.cancel();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeChat = _conversations.firstWhere(
      (c) => c['id'] == _selectedChatId,
      orElse: () => <String, dynamic>{},
    );

    return Scaffold(
      body: SafeArea(
        child: _conversations.isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: GlassContainer(
                    child: Padding(
                      padding: EdgeInsets.all(28.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.chat_bubble_outline_rounded, size: 54, color: AppColors.primaryPurple),
                          SizedBox(height: 14),
                          Text('No Active Client Conversations', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          SizedBox(height: 6),
                          Text(
                            'When clients click "Connect" or send messages, their HIPAA-compliant chat threads will appear here in real time.',
                            style: TextStyle(fontSize: 13, color: AppColors.textSecondaryLight),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            : Row(
                children: [
                  // Conversations List Sidebar
                  Container(
                    width: 300,
                    decoration: BoxDecoration(
                      color: AppColors.cardBackgroundLight,
                      border: Border(right: BorderSide(color: Colors.grey.shade200)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Client Messages 💬', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                              SizedBox(height: 4),
                              Text('HIPAA-compliant client communication', style: TextStyle(color: AppColors.textSecondaryLight, fontSize: 12)),
                            ],
                          ),
                        ),
                        const Divider(height: 1),
                        Expanded(
                          child: ListView.builder(
                            itemCount: _conversations.length,
                            itemBuilder: (context, index) {
                              final conv = _conversations[index];
                              final isSel = conv['id'] == _selectedChatId;
                              final name = conv['clientName'] as String? ?? 'Client User';
                              final avatar = conv['avatar'] as String? ?? 'https://i.pravatar.cc/150?img=32';

                              return Container(
                                color: isSel ? AppColors.primaryPurple.withValues(alpha: 0.1) : Colors.transparent,
                                child: ListTile(
                                  leading: Stack(
                                    children: [
                                      CircleAvatar(
                                        radius: 20,
                                        backgroundImage: NetworkImage(avatar),
                                      ),
                                      Positioned(
                                        right: 0,
                                        bottom: 0,
                                        child: Container(
                                          width: 10,
                                          height: 10,
                                          decoration: BoxDecoration(color: AppColors.moodEcstatic, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                                        ),
                                      ),
                                    ],
                                  ),
                                  title: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(child: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), overflow: TextOverflow.ellipsis)),
                                      Text(conv['time'] as String? ?? '', style: const TextStyle(fontSize: 10, color: AppColors.textSecondaryLight)),
                                    ],
                                  ),
                                  subtitle: Text(
                                    conv['lastMsg'] as String? ?? '',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  onTap: () => setState(() => _selectedChatId = conv['id'] as String?),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Active Chat Conversation View
                  if (activeChat.isNotEmpty)
                    Expanded(
                      child: Column(
                        children: [
                          // Chat Header
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            decoration: BoxDecoration(color: AppColors.cardBackgroundLight, border: Border(bottom: BorderSide(color: Colors.grey.shade200))),
                            child: Row(
                              children: [
                                CircleAvatar(radius: 18, backgroundImage: NetworkImage(activeChat['avatar'] as String? ?? 'https://i.pravatar.cc/150?img=32')),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(activeChat['clientName'] as String? ?? 'Client User', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    const Text('Active Client • Online', style: TextStyle(color: AppColors.moodEcstatic, fontSize: 11, fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Messages Area
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.all(20),
                              itemCount: ((activeChat['messages'] as List?) ?? []).length,
                              itemBuilder: (context, index) {
                                final m = ((activeChat['messages'] as List)[index]) as Map<String, dynamic>;
                                final isTherapist = m['sender'] == 'therapist';
                                return Align(
                                  alignment: isTherapist ? Alignment.centerRight : Alignment.centerLeft,
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.5),
                                    decoration: BoxDecoration(
                                      color: isTherapist ? AppColors.primaryPurple : Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: isTherapist ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          m['text'] as String? ?? '',
                                          style: TextStyle(color: isTherapist ? Colors.white : Colors.black87, fontSize: 13),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          m['time'] as String? ?? 'Just now',
                                          style: TextStyle(color: isTherapist ? Colors.white70 : Colors.black45, fontSize: 10),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                          // Message Input
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: GlassContainer(
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _messageController,
                                      decoration: const InputDecoration(
                                        hintText: 'Type secure message to client...',
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.symmetric(horizontal: 12),
                                      ),
                                      onSubmitted: (_) => _sendMessage(),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.send_rounded, color: AppColors.primaryPurple),
                                    onPressed: _sendMessage,
                                  ),
                                ],
                              ),
                            ),
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
