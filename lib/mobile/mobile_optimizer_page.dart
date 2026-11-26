import 'dart:async';

import 'package:flutter/material.dart';

import 'mobile_optimizations.dart';

const _card = Color(0xFF101E2F);
const _border = Color(0xFF233145);
const _muted = Color(0xFF9CA9BD);
const _purple = Color(0xFF9685FF);
const _green = Color(0xFF38CB74);

class MobileOptimizerPage extends StatefulWidget {
  const MobileOptimizerPage({super.key});

  @override
  State<MobileOptimizerPage> createState() => _MobileOptimizerPageState();
}

class _MobileOptimizerPageState extends State<MobileOptimizerPage> {
  final _service = MobileOptimizationService.instance;
  late Future<MobileMetrics> _future;
  Timer? _refreshTimer;
  bool _cleaning = false;

  @override
  void initState() {
    super.initState();
    _future = _service.measure();
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (mounted && !_cleaning) _refresh();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _refresh() {
    setState(() => _future = _service.measure());
  }

  void _show(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _cleanCache() async {
    final allowed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear LaunchDesk cache?'),
        content: const Text(
          'Only temporary files belonging to LaunchDesk will be removed. '
          'Saved notes, tasks, shortcuts, photos, and other apps are untouched.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear my app cache'),
          ),
        ],
      ),
    );
    if (allowed != true || !mounted) return;
    setState(() => _cleaning = true);
    try {
      final bytes = await _service.clearOwnCache();
      _show('Removed ' + formatCacheBytes(bytes) +
          ' of LaunchDesk temporary files.');
    } catch (_) {
      _show('Cache cleanup was not available.');
    } finally {
      if (mounted) {
        setState(() => _cleaning = false);
        _refresh();
      }
    }
  }

  Future<void> _openSettings(String destination) async {
    final worked = await _service.openAndroidSettings(destination);
    if (!worked) _show('This Android settings page is unavailable.');
  }

  Widget _panel(String title, Widget child) => Container(
    margin: const EdgeInsets.only(bottom: 13),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: _card,
      border: Border.all(color: _border),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title.toUpperCase(), style: const TextStyle(
          color: _muted, fontSize: 11, fontWeight: FontWeight.bold,
          letterSpacing: 1,
        )),
        const SizedBox(height: 14),
        child,
      ],
    ),
  );

  Widget _metric(String name, String value, IconData icon,
      {Color color = _purple, String? detail}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        Icon(icon, size: 22, color: color),
        const SizedBox(width: 13),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: const TextStyle(color: _muted)),
            if (detail != null) Text(detail,
                style: const TextStyle(color: _muted, fontSize: 11)),
          ],
        )),
        Text(value, style: const TextStyle(
          fontSize: 17, fontWeight: FontWeight.bold,
        )),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        final next = _service.measure();
        setState(() => _future = next);
        await next;
      },
      child: FutureBuilder<MobileMetrics>(
        future: _future,
        builder: (context, snapshot) {
          final data = snapshot.data;
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              const Text('Device optimizer', style: TextStyle(
                fontSize: 25, fontWeight: FontWeight.bold,
              )),
              const SizedBox(height: 5),
              const Text('Monitor your Android phone and manage '
                  'LaunchDesk’s own cache safely.',
                  style: TextStyle(color: _muted)),
              const SizedBox(height: 19),
              if (snapshot.connectionState == ConnectionState.waiting &&
                  data == null)
                const Padding(
                  padding: EdgeInsets.all(14),
                  child: Center(child: CircularProgressIndicator()),
                ),
              _panel('Live system overview', Column(children: [
                _metric('Battery',
                  data?.batteryPercent == null ? 'Unavailable'
                      : data!.batteryPercent.toString() + '%',
                  Icons.battery_charging_full,
                  color: _green,
                  detail: data?.charging == true ? 'Charging' : null),
                const Divider(color: _border),
                _metric('CPU load',
                  data?.cpuPercent == null ? 'Unavailable'
                      : data!.cpuPercent!.toStringAsFixed(1) + '%',
                  Icons.memory_outlined,
                  detail: 'Whole-device estimate, if Android exposes it'),
                const Divider(color: _border),
                _metric('Memory in use',
                  data?.memoryPercent == null ? 'Unavailable'
                      : data!.memoryPercent!.toStringAsFixed(1) + '%',
                  Icons.data_usage,
                  detail: data?.totalMemoryMB == null ? null
                      : (data!.usedMemoryMB?.toString() ?? '—') + ' MB of ' +
                        data.totalMemoryMB.toString() + ' MB'),
                const Divider(color: _border),
                _metric('Network connection',
                  data == null ? 'Checking'
                      : data.networkConnected ? 'Connected' : 'Disconnected',
                  Icons.wifi_outlined),
                const SizedBox(height: 6),
                OutlinedButton.icon(
                  onPressed: _refresh,
                  icon: const Icon(Icons.refresh, size: 17),
                  label: const Text('Refresh metrics'),
                ),
              ])),
              _panel('Safe cleanup', Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _metric('LaunchDesk temporary cache',
                    data == null ? 'Checking'
                        : formatCacheBytes(data.appCacheBytes),
                    Icons.cleaning_services_outlined),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: _cleaning ? null : _cleanCache,
                    icon: const Icon(Icons.delete_outline),
                    label: Text(_cleaning ? 'Cleaning…' : 'Clear app cache'),
                  ),
                  const SizedBox(height: 9),
                  const Text(
                    'Android manages other apps’ memory and caches. '
                    'LaunchDesk will not interfere with them.',
                    style: TextStyle(color: _muted, fontSize: 12),
                  ),
                ],
              )),
              _panel('Android settings', Column(children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.battery_saver, color: _green),
                  title: const Text('Battery saver'),
                  subtitle: const Text('Review power settings'),
                  trailing: const Icon(Icons.open_in_new),
                  onTap: () => _openSettings('battery'),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.wifi, color: _purple),
                  title: const Text('Wi-Fi'),
                  subtitle: const Text('Review network settings'),
                  trailing: const Icon(Icons.open_in_new),
                  onTap: () => _openSettings('wifi'),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.settings_applications,
                      color: _purple),
                  title: const Text('LaunchDesk app settings'),
                  subtitle: const Text('Permissions, storage and notifications'),
                  trailing: const Icon(Icons.open_in_new),
                  onTap: () => _openSettings('app'),
                ),
              ])),
              _panel('What optimization can do', const Text(
                'This page reports available device statistics, can delete '
                'LaunchDesk temporary files, and opens Android settings. '
                'It does not overclock your phone, raise Roblox FPS, '
                'shut down other apps, or change protected Android settings.',
                style: TextStyle(color: _muted, height: 1.5),
              )),
            ],
          );
        },
      ),
    );
  }
}
