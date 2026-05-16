import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ConnectivityStatus { online, offline }

class OfflineService {
  OfflineService._();
  static final OfflineService _instance = OfflineService._();
  static OfflineService get instance => _instance;

  final Connectivity _connectivity = Connectivity();
  final StreamController<ConnectivityStatus> _statusController =
      StreamController<ConnectivityStatus>.broadcast();

  Stream<ConnectivityStatus> get statusStream => _statusController.stream;
  ConnectivityStatus _currentStatus = ConnectivityStatus.online;
  ConnectivityStatus get currentStatus => _currentStatus;

  static const String _queueKey = 'offline_action_queue';

  StreamSubscription? _connectivitySub;

  Future<void> init() async {
    final results = await _connectivity.checkConnectivity();
    _updateStatus(results);

    _connectivitySub = _connectivity.onConnectivityChanged.listen(_updateStatus);
  }

  void _updateStatus(List<ConnectivityResult> results) {
    final isOnline = results.any((r) =>
        r == ConnectivityResult.mobile ||
        r == ConnectivityResult.wifi ||
        r == ConnectivityResult.ethernet);

    final newStatus = isOnline ? ConnectivityStatus.online : ConnectivityStatus.offline;

    if (newStatus != _currentStatus) {
      _currentStatus = newStatus;
      _statusController.add(newStatus);
    }
  }

  Future<void> enqueueAction(Map<String, dynamic> action) async {
    final prefs = await SharedPreferences.getInstance();
    final queue = await _getQueue();
    queue.add(action);
    await prefs.setString(_queueKey, jsonEncode(queue));
  }

  Future<List<Map<String, dynamic>>> _getQueue() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_queueKey);
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List;
    return list.cast<Map<String, dynamic>>();
  }

  Future<void> flushQueue(Future<void> Function(Map<String, dynamic> action) executor) async {
    final queue = await _getQueue();
    if (queue.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_queueKey);

    for (final action in queue) {
      try {
        await executor(action);
      } catch (_) {}
    }
  }

  Future<void> clearQueue() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_queueKey);
  }

  void dispose() {
    _connectivitySub?.cancel();
    _statusController.close();
  }
}
