import 'dart:async';
import 'dart:io';
import 'package:system_info2/system_info2.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class SystemInfoService {
  static final SystemInfoService _instance = SystemInfoService._internal();
  factory SystemInfoService() => _instance;
  SystemInfoService._internal();

  final Battery _battery = Battery();
  final Connectivity _connectivity = Connectivity();

  StreamController<SystemSnapshot>? _controller;
  Timer? _timer;

  Stream<SystemSnapshot> get stream {
    _controller ??= StreamController<SystemSnapshot>.broadcast();
    _startPolling();
    return _controller!.stream;
  }

  void _startPolling() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 2), (_) => _poll());
    _poll();
  }

  Future<void> _poll() async {
    try {
      final snapshot = await getSnapshot();
      _controller?.add(snapshot);
    } catch (_) {}
  }

  Future<SystemSnapshot> getSnapshot() async {
    int cpuPercent = 0;
    int ramUsedMB = 0;
    int ramTotalMB = 0;
    int batteryPercent = 100;
    bool isCharging = false;
    bool isOnline = false;

    // Windows reports aggregate processor load via WMI. Keep the last valid
    // reading if the query fails instead of showing a misleading 0%.
    if (Platform.isWindows) {
      try {
        final result = await Process.run('powershell.exe', [
          '-NoProfile', '-NonInteractive', '-Command',
          '(Get-CimInstance Win32_Processor | Measure-Object -Property LoadPercentage -Average).Average'
        ]).timeout(const Duration(seconds: 5));
        if (result.exitCode == 0) {
          final value = double.tryParse(result.stdout.toString().trim());
          if (value != null) cpuPercent = value.round().clamp(0, 100);
        }
      } catch (_) {}
    }

    try {
      ramTotalMB = (SysInfo.getTotalPhysicalMemory() / 1024 / 1024).round();
      ramUsedMB = ramTotalMB -
          (SysInfo.getFreePhysicalMemory() / 1024 / 1024).round();
    } catch (_) {}

    try {
      batteryPercent = await _battery.batteryLevel;
      final state = await _battery.batteryState;
      isCharging = state == BatteryState.charging;
    } catch (_) {}

    try {
      final result = await _connectivity.checkConnectivity();
      isOnline = result != ConnectivityResult.none;
    } catch (_) {}

    return SystemSnapshot(
      cpuPercent: cpuPercent,
      ramUsedMB: ramUsedMB,
      ramTotalMB: ramTotalMB,
      batteryPercent: batteryPercent,
      isCharging: isCharging,
      isOnline: isOnline,
      timestamp: DateTime.now(),
    );
  }

  void dispose() {
    _timer?.cancel();
    _controller?.close();
    _controller = null;
  }
}

class SystemSnapshot {
  final int cpuPercent;
  final int ramUsedMB;
  final int ramTotalMB;
  final int batteryPercent;
  final bool isCharging;
  final bool isOnline;
  final DateTime timestamp;

  const SystemSnapshot({
    required this.cpuPercent,
    required this.ramUsedMB,
    required this.ramTotalMB,
    required this.batteryPercent,
    required this.isCharging,
    required this.isOnline,
    required this.timestamp,
  });

  double get ramPercent =>
      ramTotalMB > 0 ? (ramUsedMB / ramTotalMB) * 100 : 0;
}
