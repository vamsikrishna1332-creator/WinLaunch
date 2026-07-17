import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import '../models/settings_model.dart';
import '../database/database_helper.dart';

class SettingsService {
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  AppSettings? _cached;
  File? _settingsFile;

  Future<void> init() async {
    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory('${appDir.path}/LaunchDesk');
    if (!await dir.exists()) await dir.create(recursive: true);
    _settingsFile = File(join(dir.path, 'settings.json'));
  }

  Future<AppSettings> loadSettings() async {
    if (_cached != null) return _cached!;
    try {
      // Try file first (faster)
      if (_settingsFile != null && await _settingsFile!.exists()) {
        final json = jsonDecode(await _settingsFile!.readAsString());
        _cached = AppSettings.fromJson(json);
        return _cached!;
      }
      // Fall back to DB
      final rows = await DatabaseHelper.instance.queryAll(
        'settings',
        where: "id = 'global'",
      );
      if (rows.isNotEmpty) {
        final data = jsonDecode(rows.first['data'] as String);
        _cached = AppSettings.fromJson(data);
        return _cached!;
      }
    } catch (_) {}
    _cached = const AppSettings();
    await saveSettings(_cached!);
    return _cached!;
  }

  Future<void> saveSettings(AppSettings settings) async {
    _cached = settings;
    final json = settings.toJson();
    // Write to file
    if (_settingsFile != null) {
      await _settingsFile!.writeAsString(jsonEncode(json));
    }
    // Write to DB
    await DatabaseHelper.instance.insert('settings', {
      'id': 'global',
      'profile_id': settings.activeProfileId,
      'data': jsonEncode(json),
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> updateSetting<T>(String key, T value) async {
    final current = await loadSettings();
    final json = current.toJson();
    json[key] = value;
    await saveSettings(AppSettings.fromJson(json));
  }

  Future<void> updateWindowSize(int width, int height) async {
    final current = await loadSettings();
    if (current.windowWidth == width && current.windowHeight == height) return;
    await saveSettings(current.copyWith(windowWidth: width, windowHeight: height));
  }

  Future<AppSettings> update(AppSettings Function(AppSettings) updater) async {
    final current = await loadSettings();
    final updated = updater(current);
    await saveSettings(updated);
    return updated;
  }

  Future<void> resetToDefaults() async {
    await saveSettings(const AppSettings());
  }

  Future<String> exportSettings() async {
    final settings = await loadSettings();
    return jsonEncode({'version': '1.0', 'settings': settings.toJson()});
  }

  Future<void> importSettings(String jsonString) async {
    final data = jsonDecode(jsonString);
    final settingsData = data['settings'] ?? data;
    await saveSettings(AppSettings.fromJson(settingsData));
  }
}
