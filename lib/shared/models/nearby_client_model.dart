class NearbyClientModel {
  final String id;
  final String name;
  final String distance;
  final String requestedTopic;
  final String preferredTime;
  final bool isUrgent;
  final String location;
  final String genderPreference;

  const NearbyClientModel({
    required this.id,
    required this.name,
    required this.distance,
    required this.requestedTopic,
    required this.preferredTime,
    this.isUrgent = false,
    required this.location,
    required this.genderPreference,
  });

  static List<NearbyClientModel> get mockClients => const [
        NearbyClientModel(
          id: 'nc-1',
          name: 'Marcus Vance',
          distance: '0.8 mi',
          requestedTopic: 'CBT for Acute Anxiety',
          preferredTime: 'Evenings (After 5 PM)',
          isUrgent: true,
          location: 'Downtown District',
          genderPreference: 'No Preference',
        ),
        NearbyClientModel(
          id: 'nc-2',
          name: 'Sophia Martinez',
          distance: '1.4 mi',
          requestedTopic: 'Postpartum Stress Support',
          preferredTime: 'Weekday Mornings',
          isUrgent: false,
          location: 'Westside Heights',
          genderPreference: 'Female Practitioner',
        ),
        NearbyClientModel(
          id: 'nc-3',
          name: 'David Chen',
          distance: '2.1 mi',
          requestedTopic: 'Workplace Burnout Coaching',
          preferredTime: 'Weekend Afternoons',
          isUrgent: false,
          location: 'Tech Corridor',
          genderPreference: 'No Preference',
        ),
        NearbyClientModel(
          id: 'nc-4',
          name: 'Elena Rostova',
          distance: '3.2 mi',
          requestedTopic: 'Trauma & PTSD Exposure',
          preferredTime: 'Flexible Schedule',
          isUrgent: true,
          location: 'Northside Center',
          genderPreference: 'Female Practitioner',
        ),
      ];
}
