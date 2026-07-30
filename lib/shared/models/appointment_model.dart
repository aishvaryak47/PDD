import 'therapist_model.dart';
import 'user_model.dart';

class AppointmentModel {
  final String id;
  final String clientId;
  final String therapistId;
  final DateTime scheduledAt;
  final int durationMinutes;
  final String status; // "pending", "accepted", "rejected", "completed", "cancelled"
  final double price;
  final String? notes;
  final TherapistModel? therapist;
  final UserModel? clientUser;

  AppointmentModel({
    required this.id,
    required this.clientId,
    required this.therapistId,
    required this.scheduledAt,
    required this.durationMinutes,
    required this.status,
    required this.price,
    this.notes,
    this.therapist,
    this.clientUser,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'] ?? '',
      clientId: json['client_id'] ?? '',
      therapistId: json['therapist_id'] ?? '',
      scheduledAt: DateTime.tryParse(json['scheduled_at'] ?? '') ?? DateTime.now(),
      durationMinutes: json['duration_minutes'] ?? 50,
      status: json['status'] ?? 'pending',
      price: (json['price'] as num?)?.toDouble() ?? 120.0,
      notes: json['notes'],
      therapist: json['therapist'] != null ? TherapistModel.fromJson(json['therapist']) : null,
      clientUser: json['client']?['user'] != null ? UserModel.fromJson(json['client']['user']) : null,
    );
  }
}
