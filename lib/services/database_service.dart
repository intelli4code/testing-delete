import 'package:hive_flutter/hive_flutter.dart';
import '../models/scan_history.dart';

class DatabaseService {
  static const String _historyBoxName = 'scan_history';
  static const String _settingsBoxName = 'settings';

  // Initialize Hive
  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(ScanHistoryAdapter());
    await Hive.openBox<ScanHistory>(_historyBoxName);
    await Hive.openBox(_settingsBoxName);
  }

  // History operations
  static Box<ScanHistory> get historyBox => Hive.box<ScanHistory>(_historyBoxName);

  static Future<void> addScan(ScanHistory scan) async {
    await historyBox.put(scan.id, scan);
  }

  static List<ScanHistory> getAllScans() {
    return historyBox.values.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  static Future<void> deleteScan(String id) async {
    await historyBox.delete(id);
  }

  static Future<void> clearAllScans() async {
    await historyBox.clear();
  }

  static Future<void> toggleFavorite(String id) async {
    final scan = historyBox.get(id);
    if (scan != null) {
      scan.isFavorite = !scan.isFavorite;
      await scan.save();
    }
  }

  // Settings operations
  static Box get settingsBox => Hive.box(_settingsBoxName);

  static bool getSetting(String key, {bool defaultValue = false}) {
    return settingsBox.get(key, defaultValue: defaultValue) as bool;
  }

  static Future<void> setSetting(String key, bool value) async {
    await settingsBox.put(key, value);
  }
}
