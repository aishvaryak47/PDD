class MoodLogModel {
  final String id;
  final String clientId;
  final int moodScore; // 1 to 5
  final List<String> emotionTags;
  final String? note;
  final DateTime loggedAt;

  MoodLogModel({
    required this.id,
    required this.clientId,
    required this.moodScore,
    required this.emotionTags,
    this.note,
    required this.loggedAt,
  });

  factory MoodLogModel.fromJson(Map<String, dynamic> json) {
    return MoodLogModel(
      id: json['id'] ?? '',
      clientId: json['client_id'] ?? '',
      moodScore: json['mood_score'] ?? 3,
      emotionTags: List<String>.from(json['emotion_tags'] ?? []),
      note: json['note'],
      loggedAt: DateTime.tryParse(json['logged_at'] ?? '') ?? DateTime.now(),
    );
  }
}
