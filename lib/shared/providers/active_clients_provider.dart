import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/psynova_sync_service.dart';

class ActiveClient {
  final String id;
  final String name;
  final String distance;
  final String location;
  final String requestedTopic;
  final bool isUrgent;
  final String preferredTime;
  final bool isOnline;

  ActiveClient({
    required this.id,
    required this.name,
    required this.distance,
    required this.location,
    required this.requestedTopic,
    this.isUrgent = false,
    required this.preferredTime,
    this.isOnline = true,
  });
}

class ActiveClientsNotifier extends StateNotifier<List<ActiveClient>> {
  Timer? _syncTimer;

  ActiveClientsNotifier() : super([]) {
    _initAndStartSync();
  }

  void _initAndStartSync() async {
    final loaded = await PsynovaSyncService.loadClients();
    state = loaded;

    _syncTimer = Timer.periodic(const Duration(seconds: 1), (_) async {
      final updated = await PsynovaSyncService.loadClients();
      if (updated.length != state.length || _hasDiff(updated)) {
        state = updated;
      }
    });
  }

  bool _hasDiff(List<ActiveClient> newList) {
    if (newList.length != state.length) return true;
    for (int i = 0; i < newList.length; i++) {
      if (newList[i].id != state[i].id || newList[i].name != state[i].name) return true;
    }
    return false;
  }

  void addActiveClient(ActiveClient client) {
    final filtered = state.where((c) => c.id != client.id && c.name.toLowerCase() != client.name.toLowerCase()).toList();
    state = [client, ...filtered];
    PsynovaSyncService.saveClients(state);
  }

  void removeActiveClient(String id) {
    state = state.where((c) => c.id != id).toList();
    PsynovaSyncService.saveClients(state);
  }

  @override
  void dispose() {
    _syncTimer?.cancel();
    super.dispose();
  }
}

final activeClientsProvider =
    StateNotifierProvider<ActiveClientsNotifier, List<ActiveClient>>((ref) {
  return ActiveClientsNotifier();
});
