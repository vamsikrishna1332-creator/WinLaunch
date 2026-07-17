import 'dart:async';
import 'dart:math';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/models/widget_config_model.dart';
import '../../../core/providers/app_providers.dart';

class ClockWidget extends ConsumerStatefulWidget {
  final WidgetConfig config;
  const ClockWidget({super.key, required this.config});

  @override
  ConsumerState<ClockWidget> createState() => _ClockWidgetState();
}

class _ClockWidgetState extends ConsumerState<ClockWidget> {
  late Timer _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final format = widget.config.settings['format'] ?? '24h';
    final showSeconds = widget.config.settings['showSeconds'] ?? true;
    final showAnalog = widget.config.settings['showAnalog'] ?? false;

    if (showAnalog) {
      return _AnalogClock(time: _now, accentColor: Color(theme.accentColor));
    }

    final timeStr = format == '12h'
        ? DateFormat(showSeconds ? 'hh:mm:ss a' : 'hh:mm a').format(_now)
        : DateFormat(showSeconds ? 'HH:mm:ss' : 'HH:mm').format(_now);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          timeStr,
          style: TextStyle(
            color: Color(theme.textColor),
            fontSize: 36,
            fontWeight: FontWeight.w300,
            fontFamily: theme.fontFamily,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          DateFormat('EEEE, MMM d').format(_now),
          style: TextStyle(
            color: Color(theme.secondaryTextColor),
            fontSize: 11,
            fontFamily: theme.fontFamily,
          ),
        ),
      ],
    );
  }
}

class _AnalogClock extends StatelessWidget {
  final DateTime time;
  final Color accentColor;
  const _AnalogClock({required this.time, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _AnalogClockPainter(time: time, accentColor: accentColor),
    );
  }
}

class _AnalogClockPainter extends CustomPainter {
  final DateTime time;
  final Color accentColor;
  _AnalogClockPainter({required this.time, required this.accentColor});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = min(cx, cy) - 8;

    final fgPaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Clock face
    canvas.drawCircle(Offset(cx, cy), r,
        Paint()..color = Colors.white.withOpacity(0.05));
    canvas.drawCircle(Offset(cx, cy), r,
        fgPaint..strokeWidth = 1.5..color = Colors.white.withOpacity(0.2));

    // Tick marks
    for (int i = 0; i < 12; i++) {
      final angle = (i * 30 - 90) * pi / 180;
      final inner = i % 3 == 0 ? r - 12 : r - 7;
      canvas.drawLine(
        Offset(cx + cos(angle) * inner, cy + sin(angle) * inner),
        Offset(cx + cos(angle) * r, cy + sin(angle) * r),
        fgPaint..strokeWidth = i % 3 == 0 ? 2 : 1,
      );
    }

    // Hour hand
    final hourAngle =
        ((time.hour % 12 + time.minute / 60) * 30 - 90) * pi / 180;
    canvas.drawLine(
      Offset(cx, cy),
      Offset(cx + cos(hourAngle) * r * 0.55, cy + sin(hourAngle) * r * 0.55),
      fgPaint..strokeWidth = 3..color = Colors.white,
    );

    // Minute hand
    final minAngle = (time.minute * 6 - 90) * pi / 180;
    canvas.drawLine(
      Offset(cx, cy),
      Offset(cx + cos(minAngle) * r * 0.75, cy + sin(minAngle) * r * 0.75),
      fgPaint..strokeWidth = 2..color = Colors.white.withOpacity(0.9),
    );

    // Second hand
    final secAngle = (time.second * 6 - 90) * pi / 180;
    canvas.drawLine(
      Offset(cx, cy),
      Offset(cx + cos(secAngle) * r * 0.85, cy + sin(secAngle) * r * 0.85),
      fgPaint..strokeWidth = 1..color = accentColor,
    );

    // Center dot
    canvas.drawCircle(Offset(cx, cy), 4, Paint()..color = accentColor);
  }

  @override
  bool shouldRepaint(covariant _AnalogClockPainter old) => true;
}
