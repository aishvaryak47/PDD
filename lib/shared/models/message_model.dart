class MessageModel {
  final String id;
  final String senderId;
  final String receiverId;
  final String content;
  final String? attachmentUrl;
  final String messageType; // "text", "image", "file", "audio"
  final bool isRead;
  final DateTime timestamp;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    this.attachmentUrl,
    this.messageType = 'text',
    this.isRead = false,
    required this.timestamp,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] ?? '',
      senderId: json['sender_id'] ?? '',
      receiverId: json['receiver_id'] ?? '',
      content: json['content'] ?? '',
      attachmentUrl: json['attachment_url'],
      messageType: json['message_type'] ?? 'text',
      isRead: json['is_read'] ?? false,
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
    );
  }
}
