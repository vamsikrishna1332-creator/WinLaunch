import 'dart:async';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import 'package:intl/intl.dart';
import '../../core/providers/app_providers.dart';
import 'glass_container.dart';

class TopBar extends ConsumerStatefulWidget {
  const TopBar({super.key});

  @override
  ConsumerState<TopBar> createState() => _TopBarState();
}

class _TopBarState extends ConsumerState<TopBar> {
  late Timer _clockTimer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _clockTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsProvider);
    final theme = ref.watch(themeProvider);
    final sysAsync = ref.watch(systemInfoProvider);

    return settingsAsync.when(
      loading: () => const SizedBox(height: 48),
      error: (_, __) => const SizedBox(height: 48),
      data: (settings) {
        if (!settings.showTopBar) return const SizedBox.shrink();

        final textStyle = TextStyle(
          color: Color(theme.textColor),
          fontSize: 12,
          fontFamily: theme.fontFamily,
        );

        return GestureDetector(
          onPanStart: (_) => windowManager.startDragging(),
          child: GlassContainer(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            borderRadius: 0,
            child: Row(
              children: [
                // App name
                Text(
                  settings.appName,
                  style: textStyle.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(theme.accentColor),
                  ),
                ),
                const SizedBox(width: 24),

                // Date
                if (settings.showDate)
                  Text(
                    DateFormat(settings.dateFormat).format(_now),
                    style: textStyle,
                  ),

                const Spacer(),

                // System info
                sysAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (sys) => Row(
                    children: [
                      if (settings.showCpu)
                        _StatChip(
                          label: 'CPU',
                          value: '${sys.cpuPercent}%',
                          style: textStyle,
                          color: sys.cpuPercent > 80
                              ? Colors.red.normal
                              : Color(theme.secondaryTextColor),
                        ),
                      if (settings.showRam)
                        _StatChip(
                          label: 'RAM',
                          value: '${sys.ramPercent.round()}%',
                          style: textStyle,
                          color: sys.ramPercent > 80
                              ? Colors.orange.normal
                              : Color(theme.secondaryTextColor),
                        ),
                      if (settings.showBattery)
                        _BatteryChip(
                          percent: sys.batteryPercent,
                          isCharging: sys.isCharging,
                          style: textStyle,
                          accentColor: Color(theme.accentColor),
                        ),
                      if (settings.showWifi)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Icon(
                            sys.isOnline
                                ? FluentIcons.wifi
                                : FluentIcons.warning,
                            size: 14,
                            color: sys.isOnline
                                ? Color(theme.successColor)
                                : Color(theme.errorColor),
                          ),
                        ),
                    ],
                  ),
                ),

                // Clock
                if (settings.showClock) ...[
                  const SizedBox(width: 12),
                  Text(
                    DateFormat(settings.timeFormat).format(_now),
                    style: textStyle.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],

                const SizedBox(width: 16),

                // Action buttons
                _TopBarButton(
                  icon: FluentIcons.settings,
                  tooltip: 'Settings',
                  onPressed: () =>
                      Navigator.pushNamed(context, '/settings'),
                  color: Color(theme.secondaryTextColor),
                ),
                _TopBarButton(
                  icon: FluentIcons.full_screen,
                  tooltip: 'Toggle Fullscreen',
                  onPressed: () async {
                    final isFs = await windowManager.isFullScreen();
                    windowManager.setFullScreen(!isFs);
                  },
                  color: Color(theme.secondaryTextColor),
                ),
                _TopBarButton(
                  icon: FluentIcons.chrome_minimize,
                  tooltip: 'Minimize',
                  onPressed: () => windowManager.minimize(),
                  color: Color(theme.secondaryTextColor),
                ),
                _TopBarButton(
                  icon: FluentIcons.chrome_close,
                  tooltip: 'Close',
                  onPressed: () => windowManager.close(),
                  color: Color(theme.errorColor),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle style;
  final Color color;

  const _StatChip({
    required this.label,
    required this.value,
    required this.style,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$label ', style: style.copyWith(color: color.withOpacity(0.7))),
          Text(value, style: style.copyWith(color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _BatteryChip extends StatelessWidget {
  final int percent;
  final bool isCharging;
  final TextStyle style;
  final Color accentColor;

  const _BatteryChip({
    required this.percent,
    required this.isCharging,
    required this.style,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    Color color = Colors.green.normal;
    if (percent < 20) color = Colors.red.normal;
    else if (percent < 40) color = Colors.orange.normal;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isCharging
                ? FluentIcons.power_button
                : _batteryIcon(percent),
            size: 14,
            color: color,
          ),
          const SizedBox(width: 2),
          Text('$percent%', style: style.copyWith(color: color)),
        ],
      ),
    );
  }

  IconData _batteryIcon(int percent) {
    if (percent >= 80) return FluentIcons.power_button;
    if (percent >= 60) return FluentIcons.battery_100;
    if (percent >= 40) return FluentIcons.power_button;
    if (percent >= 20) return FluentIcons.battery_50;
    return FluentIcons.power_button;
  }
}

class _TopBarButton extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final Color color;

  const _TopBarButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    required this.color,
  });

  @override
  State<_TopBarButton> createState() => _TopBarButtonState();
}

class _TopBarButtonState extends State<_TopBarButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: widget.onPressed,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: _hovered ? Colors.white.withOpacity(0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(widget.icon, size: 14, color: widget.color),
          ),
        ),
      ),
    );
  }
}
