import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/active_therapists_provider.dart';
import '../providers/active_clients_provider.dart';

class PsynovaSyncService {
  static const String _therapistsKey = 'psynova_active_therapists_v3';
  static const String _clientsKey = 'psynova_active_clients_v3';
  static const String _appointmentsKey = 'psynova_appointments_v3';
  static const String _conversationsKey = 'psynova_conversations_v3';
  static const String _moodLogsKey = 'psynova_mood_logs_v3';
  static const String _journalsKey = 'psynova_journals_v3';
  static const String _soapNotesKey = 'psynova_soap_notes_v3';

  // --- RAW STORAGE ACCESS ---
  static void _writeRaw(String key, String value) {
    // SharedPreferences handles web and native storage safely
  }

  static String? _readRaw(String key) {
    // SharedPreferences handles web and native storage safely
    return null;
  }

  // --- THERAPISTS ---
  static Future<void> saveTherapists(List<ActiveTherapist> therapists) async {
    final listJson = therapists.map((t) => {
      'id': t.id,
      'name': t.name,
      'title': t.title,
      'rate': t.rate,
      'rating': t.rating,
      'reviews': t.reviews,
      'address': t.address,
      'biography': t.biography,
      'qualifications': t.qualifications,
      'experienceYears': t.experienceYears,
      'languages': t.languages,
      'isOnline': t.isOnline,
    }).toList();
    final jsonStr = jsonEncode(listJson);
    _writeRaw(_therapistsKey, jsonStr);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_therapistsKey, jsonStr);
    } catch (_) {}
  }

  static Future<List<ActiveTherapist>> loadTherapists() async {
    String? raw = _readRaw(_therapistsKey);
    if (raw == null || raw.isEmpty) {
      try {
        final prefs = await SharedPreferences.getInstance();
        raw = prefs.getString(_therapistsKey);
      } catch (_) {}
    }

    if (raw != null && raw.isNotEmpty) {
      try {
        final List<dynamic> listJson = jsonDecode(raw);
        return listJson.map((item) => ActiveTherapist(
          id: item['id'] ?? '',
          name: item['name'] ?? 'Dr. Specialist',
          title: item['title'] ?? 'Licensed Specialist',
          rate: item['rate'] ?? '\$140 / hr',
          rating: (item['rating'] as num?)?.toDouble() ?? 5.0,
          reviews: (item['reviews'] as num?)?.toInt() ?? 12,
          address: item['address'] ?? 'Online Clinical Suite',
          biography: item['biography'] ?? 'Licensed clinical therapist offering Cognitive Behavioral Therapy, anxiety resilience, and mental wellness consultations.',
          qualifications: item['qualifications'] != null
              ? List<String>.from(item['qualifications'])
              : const ['Psy.D in Clinical Psychology', 'Licensed CBT Specialist'],
          experienceYears: (item['experienceYears'] as num?)?.toInt() ?? 8,
          languages: item['languages'] != null
              ? List<String>.from(item['languages'])
              : const ['English', 'Spanish'],
          isOnline: item['isOnline'] ?? true,
        )).toList();
      } catch (_) {}
    }
    return [];
  }

  // --- CLIENTS ---
  static Future<void> saveClients(List<ActiveClient> clients) async {
    final listJson = clients.map((c) => {
      'id': c.id,
      'name': c.name,
      'location': c.location,
      'requestedTopic': c.requestedTopic,
      'isUrgent': c.isUrgent,
      'preferredTime': c.preferredTime,
      'isOnline': c.isOnline,
    }).toList();
    final jsonStr = jsonEncode(listJson);
    _writeRaw(_clientsKey, jsonStr);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_clientsKey, jsonStr);
    } catch (_) {}
  }

  static Future<List<ActiveClient>> loadClients() async {
    String? raw = _readRaw(_clientsKey);
    if (raw == null || raw.isEmpty) {
      try {
        final prefs = await SharedPreferences.getInstance();
        raw = prefs.getString(_clientsKey);
      } catch (_) {}
    }

    if (raw != null && raw.isNotEmpty) {
      try {
        final List<dynamic> listJson = jsonDecode(raw);
        return listJson.map((item) => ActiveClient(
          id: item['id'] ?? '',
          name: item['name'] ?? 'Active Client',
          location: item['location'] ?? 'Active Location',
          requestedTopic: item['requestedTopic'] ?? 'CBT Consultation',
          isUrgent: item['isUrgent'] ?? false,
          preferredTime: item['preferredTime'] ?? 'Flexible',
          isOnline: item['isOnline'] ?? true,
        )).toList();
      } catch (_) {}
    }
    return [];
  }

  // --- APPOINTMENTS ---
  static Future<void> saveAppointments(List<Map<String, dynamic>> appointments) async {
    final jsonStr = jsonEncode(appointments);
    _writeRaw(_appointmentsKey, jsonStr);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_appointmentsKey, jsonStr);
    } catch (_) {}
  }

  static Future<List<Map<String, dynamic>>> loadAppointments() async {
    String? raw = _readRaw(_appointmentsKey);
    if (raw == null || raw.isEmpty) {
      try {
        final prefs = await SharedPreferences.getInstance();
        raw = prefs.getString(_appointmentsKey);
      } catch (_) {}
    }

    if (raw != null && raw.isNotEmpty) {
      try {
        final List<dynamic> listJson = jsonDecode(raw);
        return listJson.cast<Map<String, dynamic>>();
      } catch (_) {}
    }
    return [];
  }

  // --- CONVERSATIONS / MESSAGES ---
  static Future<void> saveConversations(List<Map<String, dynamic>> conversations) async {
    final jsonStr = jsonEncode(conversations);
    _writeRaw(_conversationsKey, jsonStr);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_conversationsKey, jsonStr);
    } catch (_) {}
  }

  static Future<List<Map<String, dynamic>>> loadConversations() async {
    String? raw = _readRaw(_conversationsKey);
    if (raw == null || raw.isEmpty) {
      try {
        final prefs = await SharedPreferences.getInstance();
        raw = prefs.getString(_conversationsKey);
      } catch (_) {}
    }

    if (raw != null && raw.isNotEmpty) {
      try {
        final List<dynamic> listJson = jsonDecode(raw);
        return listJson.cast<Map<String, dynamic>>();
      } catch (_) {}
    }
    return [];
  }

  // --- MOOD LOGS ---
  static Future<void> saveMoodLogs(List<Map<String, dynamic>> moodLogs) async {
    final jsonStr = jsonEncode(moodLogs);
    _writeRaw(_moodLogsKey, jsonStr);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_moodLogsKey, jsonStr);
    } catch (_) {}
  }

  static Future<List<Map<String, dynamic>>> loadMoodLogs() async {
    String? raw = _readRaw(_moodLogsKey);
    if (raw == null || raw.isEmpty) {
      try {
        final prefs = await SharedPreferences.getInstance();
        raw = prefs.getString(_moodLogsKey);
      } catch (_) {}
    }

    if (raw != null && raw.isNotEmpty) {
      try {
        final List<dynamic> listJson = jsonDecode(raw);
        return listJson.cast<Map<String, dynamic>>();
      } catch (_) {}
    }
    return [];
  }

  // --- JOURNALS ---
  static Future<void> saveJournals(List<Map<String, dynamic>> journals) async {
    final jsonStr = jsonEncode(journals);
    _writeRaw(_journalsKey, jsonStr);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_journalsKey, jsonStr);
    } catch (_) {}
  }

  static Future<List<Map<String, dynamic>>> loadJournals() async {
    String? raw = _readRaw(_journalsKey);
    if (raw == null || raw.isEmpty) {
      try {
        final prefs = await SharedPreferences.getInstance();
        raw = prefs.getString(_journalsKey);
      } catch (_) {}
    }

    if (raw != null && raw.isNotEmpty) {
      try {
        final List<dynamic> listJson = jsonDecode(raw);
        return listJson.cast<Map<String, dynamic>>();
      } catch (_) {}
    }
    return [];
  }

  // --- SOAP NOTES ---
  static Future<void> saveSoapNotes(List<Map<String, dynamic>> soapNotes) async {
    final jsonStr = jsonEncode(soapNotes);
    _writeRaw(_soapNotesKey, jsonStr);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_soapNotesKey, jsonStr);
    } catch (_) {}
  }

  static Future<List<Map<String, dynamic>>> loadSoapNotes() async {
    String? raw = _readRaw(_soapNotesKey);
    if (raw == null || raw.isEmpty) {
      try {
        final prefs = await SharedPreferences.getInstance();
        raw = prefs.getString(_soapNotesKey);
      } catch (_) {}
    }

    if (raw != null && raw.isNotEmpty) {
      try {
        final List<dynamic> listJson = jsonDecode(raw);
        return listJson.cast<Map<String, dynamic>>();
      } catch (_) {}
    }
    return [];
  }
}


