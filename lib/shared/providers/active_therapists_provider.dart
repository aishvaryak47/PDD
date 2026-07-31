import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/psynova_sync_service.dart';

class ActiveTherapist {
  final String id;
  final String name;
  final String title;
  final String rate;
  final double rating;
  final int reviews;
  final String address;
  final String biography;
  final List<String> qualifications;
  final int experienceYears;
  final List<String> languages;
  final bool isOnline;

  ActiveTherapist({
    required this.id,
    required this.name,
    required this.title,
    required this.rate,
    required this.rating,
    required this.reviews,
    required this.address,
    this.biography = 'Licensed therapist providing professional Cognitive Behavioral Therapy (CBT), stress management, and emotional wellness consultations.',
    this.qualifications = const ['Psy.D in Clinical Psychology', 'Licensed CBT Specialist'],
    this.experienceYears = 8,
    this.languages = const ['English', 'Spanish'],
    this.isOnline = true,
  });
}

class ActiveTherapistsNotifier extends StateNotifier<List<ActiveTherapist>> {
  Timer? _syncTimer;

  ActiveTherapistsNotifier() : super([]) {
    _initAndStartSync();
  }

  void _initAndStartSync() async {
    final loaded = await PsynovaSyncService.loadTherapists();
    state = loaded;

    _syncTimer = Timer.periodic(const Duration(milliseconds: 500), (_) async {
      final updated = await PsynovaSyncService.loadTherapists();
      if (_hasDiff(updated)) {
        state = updated;
      }
    });
  }

  bool _hasDiff(List<ActiveTherapist> newList) {
    if (newList.length != state.length) return true;
    for (int i = 0; i < newList.length; i++) {
      if (newList[i].id != state[i].id || newList[i].name != state[i].name) return true;
    }
    return false;
  }

  void addActiveTherapist(ActiveTherapist therapist) {
    final filtered = state.where((t) => t.id != therapist.id && t.name.toLowerCase() != therapist.name.toLowerCase()).toList();
    state = [therapist, ...filtered];
    PsynovaSyncService.saveTherapists(state);
  }

  void removeActiveTherapist(String id) {
    state = state.where((t) => t.id != id).toList();
    PsynovaSyncService.saveTherapists(state);
  }

  @override
  void dispose() {
    _syncTimer?.cancel();
    super.dispose();
  }
}

final activeTherapistsProvider =
    StateNotifierProvider<ActiveTherapistsNotifier, List<ActiveTherapist>>((ref) {
  return ActiveTherapistsNotifier();
});

