import 'dart:async';
import 'dart:math';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/widget_config_model.dart';
import '../../../core/providers/app_providers.dart';

class PomodoroWidget extends ConsumerStatefulWidget {
  final WidgetConfig config;
  const PomodoroWidget({super.key, required this.config});

  @override
  ConsumerState<PomodoroWidget> createState() => _PomodoroWidgetState();
}

class _PomodoroWidgetState extends ConsumerState<PomodoroWidget> {
  Timer? _timer;
  bool _running = false;
  bool _onBreak = false;
  late int _secondsLeft;
  int _sessionCount = 0;

  int get _workSeconds =>
      (widget.config.settings['workMinutes'] ?? 25) * 60;
  int get _breakSeconds =>
      (widget.config.settings['breakMinutes'] ?? 5) * 60;

  @override
  void initState() {
    super.initState();
    _secondsLeft = _workSeconds;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _toggle() {
    if (_running) {
      _timer?.cancel();
      setState(() => _running = false);
    } else {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (_secondsLeft <= 0) {
          _timer?.cancel();
          setState(() {
            _running = false;
            if (!_onBreak) {
              _sessionCount++;
              _onBreak = true;
              _secondsLeft = _breakSeconds;
            } else {
              _onBreak = false;
              _secondsLeft = _workSeconds;
            }
          });
        } else {
          setState(() => _secondsLeft--);
        }
      });
      setState(() => _running = true);
    }
  }

  void _reset() {
    _timer?.cancel();
    setState(() {
      _running = false;
      _onBreak = false;
      _secondsLeft = _workSeconds;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final total = _onBreak ? _breakSeconds : _workSeconds;
    final progress = 1 - (_secondsLeft / total);
    final mins = _secondsLeft ~/ 60;
    final secs = _secondsLeft % 60;
    final color = _onBreak
        ? const Color(0xFF6BCB77)
        : Color(theme.accentColor);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Circular progress + timer
        SizedBox(
          width: 100,
          height: 100,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size(100, 100),
                painter: _CircularProgressPainter(
                  progress: progress,
                  color: color,
                  bgColor: Colors.white.withOpacity(0.1),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      color: Color(theme.textColor),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                  Text(
                    _onBreak ? 'Break' : 'Focus',
                    style: TextStyle(
                      color: color,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Button(
              child: Text(_running ? 'Pause' : 'Start'),
              onPressed: _toggle,
            ),
            const SizedBox(width: 8),
            Button(
              child: const Text('Reset'),
              onPressed: _reset,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Sessions: $_sessionCount',
          style: TextStyle(
            color: Color(theme.secondaryTextColor),
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color bgColor;
  _CircularProgressPainter(
      {required this.progress, required this.color, required this.bgColor});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = min(cx, cy) - 8;

    canvas.drawCircle(
        Offset(cx, cy), r, Paint()..color = bgColor..style = PaintingStyle.stroke..strokeWidth = 6);

    final arc = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      -pi / 2,
      2 * pi * progress,
      false,
      arc,
    );
  }

  @override
  bool shouldRepaint(covariant _CircularProgressPainter old) => true;
}
