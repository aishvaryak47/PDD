class JournalModel {
  final String id;
  final String clientId;
  final String title;
  final String content;
  final String? audioUrl;
  final String? aiSummary;
  final DateTime createdAt;

  JournalModel({
    required this.id,
    required this.clientId,
    required this.title,
    required this.content,
    this.audioUrl,
    this.aiSummary,
    required this.createdAt,
  });

  factory JournalModel.fromJson(Map<String, dynamic> json) {
    return JournalModel(
      id: json['id'] ?? '',
      clientId: json['client_id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      audioUrl: json['audio_url'],
      aiSummary: json['ai_summary'],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }
}
