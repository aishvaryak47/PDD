import 'user_model.dart';

class TherapistModel {
  final String id;
  final String userId;
  final String title;
  final String biography;
  final String locationAddress;
  final double latitude;
  final double longitude;
  final double hourlyRate;
  final int experienceYears;
  final List<String> languages;
  final List<String> qualifications;
  final List<String> certificates;
  final double ratingAvg;
  final int totalReviews;
  final UserModel? user;

  TherapistModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.biography,
    required this.locationAddress,
    required this.latitude,
    required this.longitude,
    required this.hourlyRate,
    required this.experienceYears,
    required this.languages,
    required this.qualifications,
    required this.certificates,
    required this.ratingAvg,
    required this.totalReviews,
    this.user,
  });

  factory TherapistModel.fromJson(Map<String, dynamic> json) {
    return TherapistModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      title: json['title'] ?? 'Licensed Therapist',
      biography: json['biography'] ?? '',
      locationAddress: json['location_address'] ?? 'Clinic Location',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 40.7128,
      longitude: (json['longitude'] as num?)?.toDouble() ?? -74.0060,
      hourlyRate: (json['hourly_rate'] as num?)?.toDouble() ?? 120.0,
      experienceYears: json['experience_years'] ?? 5,
      languages: List<String>.from(json['languages'] ?? ['English']),
      qualifications: List<String>.from(json['qualifications'] ?? ['Psy.D Clinical Psychology']),
      certificates: List<String>.from(json['certificates'] ?? ['Licensed Practitioner']),
      ratingAvg: (json['rating_avg'] as num?)?.toDouble() ?? 4.9,
      totalReviews: json['total_reviews'] ?? 24,
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
    );
  }
}
