import 'dart:async';
import 'dart:io';

import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

/// On-device diagnostics only. Android does not allow ordinary apps to
/// "boost" other apps' FPS, kill their processes, or wipe their caches.
class MobileMetrics {
  final int? batteryPercent;
  final bool charging;
  final int? totalMemoryMB;
  final int? usedMemoryMB;
  final double? cpuPercent;
  final bool networkConnected;
  final int appCacheBytes;

  const MobileMetrics({
    required this.batteryPercent,
    required this.charging,
    required this.totalMemoryMB,
    required this.usedMemoryMB,
    required this.cpuPercent,
    required this.networkConnected,
    required this.appCacheBytes,
  });

  double? get memoryPercent => totalMemoryMB == null ||
          totalMemoryMB == 0 || usedMemoryMB == null
      ? null
      : (usedMemoryMB! / totalMemoryMB! * 100).clamp(0.0, 100.0);
}

class MobileOptimizationService {
  MobileOptimizationService._();
  static final instance = MobileOptimizationService._();

  static const _channel = MethodChannel('launchdesk/mobile');
  final Battery _battery = Battery();
  final Connectivity _connectivity = Connectivity();

  Future<MobileMetrics> measure() async {
    int? batteryPercent;
    bool charging = false;
    bool networkConnected = false;

    try {
      batteryPercent = await _battery.batteryLevel;
      charging = (await _battery.batteryState) == BatteryState.charging;
    } catch (_) {
      // Some emulators or devices do not expose battery data.
    }

    try {
      networkConnected =
          (await _connectivity.checkConnectivity()) != ConnectivityResult.none;
    } catch (_) {}

    final memory = await _readMemory();
    final cpu = await _readCpu();
    final cache = await measureOwnCache();

    return MobileMetrics(
      batteryPercent: batteryPercent,
      charging: charging,
      totalMemoryMB: memory.$1,
      usedMemoryMB: memory.$2,
      cpuPercent: cpu,
      networkConnected: networkConnected,
      appCacheBytes: cache,
    );
  }

  Future<(int?, int?)> _readMemory() async {
    if (!Platform.isAndroid) return (null, null);
    try {
      final text = await File('/proc/meminfo').readAsString();
      int? value(String key) {
        final match = RegExp('^' + key + r':\s+(\d+)', multiLine: true)
            .firstMatch(text);
        return match == null ? null : int.tryParse(match.group(1)!);
      }

      final totalKb = value('MemTotal');
      final availableKb = value('MemAvailable');
      if (totalKb == null || availableKb == null) return (null, null);
      return (
        (totalKb / 1024).round(),
        ((totalKb - availableKb) / 1024).round(),
      );
    } catch (_) {
      return (null, null);
    }
  }

  Future<List<int>?> _cpuCounters() async {
    try {
      final firstLine = (await File('/proc/stat').readAsLines()).first;
      if (!firstLine.startsWith('cpu ')) return null;
      final values = firstLine.trim().split(RegExp(r'\s+')).skip(1)
          .map(int.tryParse).toList();
      if (values.length < 5 || values.any((v) => v == null)) return null;
      return values.cast<int>();
    } catch (_) {
      return null;
    }
  }

  Future<double?> _readCpu() async {
    if (!Platform.isAndroid) return null;
    final first = await _cpuCounters();
    if (first == null) return null;
    await Future<void>.delayed(const Duration(milliseconds: 220));
    final second = await _cpuCounters();
    if (second == null || second.length != first.length) return null;

    final totalDelta = second.reduce((a, b) => a + b) -
        first.reduce((a, b) => a + b);
    // /proc/stat: idle and iowait are counters 3 and 4.
    final idleDelta = (second[3] + second[4]) - (first[3] + first[4]);
    if (totalDelta <= 0) return null;
    return ((totalDelta - idleDelta) / totalDelta * 100)
        .clamp(0.0, 100.0);
  }

  Future<int> measureOwnCache() async {
    try {
      final dir = await getTemporaryDirectory();
      if (!await dir.exists()) return 0;
      var bytes = 0;
      await for (final entry in dir.list(recursive: true, followLinks: false)) {
        if (entry is File) {
          try {
            bytes += await entry.length();
          } catch (_) {}
        }
      }
      return bytes;
    } catch (_) {
      return 0;
    }
  }

  /// Only deletes LaunchDesk's OS-assigned temporary cache directory contents.
  /// Never touches other apps, Downloads, photos, or user documents.
  Future<int> clearOwnCache() async {
    final before = await measureOwnCache();
    final dir = await getTemporaryDirectory();
    if (!await dir.exists()) return 0;
    await for (final entry in dir.list(followLinks: false)) {
      try {
        await entry.delete(recursive: true);
      } catch (_) {
        // Leave entries that are currently in use.
      }
    }
    final after = await measureOwnCache();
    return before > after ? before - after : 0;
  }

  /// Opens official Android settings panels; does not silently change settings.
  Future<bool> openAndroidSettings(String destination) async {
    if (!Platform.isAndroid) return false;
    try {
      return await _channel.invokeMethod<bool>(
            'openSettings', <String, String>{'destination': destination},
          ) ??
          false;
    } catch (_) {
      return false;
    }
  }
}

String formatCacheBytes(int bytes) {
  if (bytes < 1024) return bytes.toString() + ' B';
  if (bytes < 1024 * 1024) {
    return (bytes / 1024).toStringAsFixed(1) + ' KB';
  }
  return (bytes / (1024 * 1024)).toStringAsFixed(1) + ' MB';
}
