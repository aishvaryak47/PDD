import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/models/nearby_client_model.dart';
import '../../../../shared/services/psynova_sync_service.dart';

class TherapistState {
  final bool isAcceptingClients;
  final String selectedFilter;
  final String searchQuery;
  final List<NearbyClientModel> clients;
  final List<Map<String, dynamic>> appointments;
  final List<Map<String, dynamic>> aiInsights;
  final List<Map<String, dynamic>> soapNotes;

  TherapistState({
    this.isAcceptingClients = true,
    this.selectedFilter = 'All',
    this.searchQuery = '',
    required this.clients,
    required this.appointments,
    required this.aiInsights,
    required this.soapNotes,
  });

  TherapistState copyWith({
    bool? isAcceptingClients,
    String? selectedFilter,
    String? searchQuery,
    List<NearbyClientModel>? clients,
    List<Map<String, dynamic>>? appointments,
    List<Map<String, dynamic>>? aiInsights,
    List<Map<String, dynamic>>? soapNotes,
  }) {
    return TherapistState(
      isAcceptingClients: isAcceptingClients ?? this.isAcceptingClients,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      clients: clients ?? this.clients,
      appointments: appointments ?? this.appointments,
      aiInsights: aiInsights ?? this.aiInsights,
      soapNotes: soapNotes ?? this.soapNotes,
    );
  }
}

class TherapistNotifier extends StateNotifier<TherapistState> {
  Timer? _syncTimer;

  TherapistNotifier()
      : super(TherapistState(
          clients: [],
          appointments: [],
          aiInsights: [],
          soapNotes: [],
        )) {
    _initAndStartSync();
  }

  void _initAndStartSync() async {
    final loaded = await PsynovaSyncService.loadAppointments();
    if (loaded.isNotEmpty) {
      state = state.copyWith(appointments: loaded);
    }

    _syncTimer = Timer.periodic(const Duration(seconds: 1), (_) async {
      final updated = await PsynovaSyncService.loadAppointments();
      if (updated.length != state.appointments.length) {
        state = state.copyWith(appointments: updated);
      }
    });
  }

  void toggleAcceptingClients(bool value) {
    state = state.copyWith(isAcceptingClients: value);
  }

  void setFilter(String filter) {
    state = state.copyWith(selectedFilter: filter);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void addAppointment(Map<String, dynamic> appointment) {
    final newApts = [...state.appointments, appointment];
    state = state.copyWith(appointments: newApts);
    PsynovaSyncService.saveAppointments(newApts);
  }

  void addClient(NearbyClientModel client) {
    state = state.copyWith(clients: [...state.clients, client]);
  }

  void acceptClient(String clientId) {
    final updated = state.clients.where((c) => c.id != clientId).toList();
    state = state.copyWith(clients: updated);
  }

  void addSoapNote(Map<String, dynamic> note) {
    state = state.copyWith(soapNotes: [note, ...state.soapNotes]);
  }

  void dismissInsight(String id) {
    final updated = state.aiInsights.where((i) => i['id'] != id).toList();
    state = state.copyWith(aiInsights: updated);
  }

  @override
  void dispose() {
    _syncTimer?.cancel();
    super.dispose();
  }
}

final therapistProvider =
    StateNotifierProvider<TherapistNotifier, TherapistState>((ref) {
  return TherapistNotifier();
});
