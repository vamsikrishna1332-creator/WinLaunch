import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/app_providers.dart';

/// A horizontally scrolling notice ticker bar.
/// Joins up to 5 notices with a separator and loops them infinitely.
class NoticeBar extends ConsumerStatefulWidget {
  const NoticeBar({super.key});

  @override
  ConsumerState<NoticeBar> createState() => _NoticeBarState();
}

class _NoticeBarState extends ConsumerState<NoticeBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  // How many pixels per second the text travels
  static const double _speed = 60.0;

  // Full pixel width of one copy of the text (measured via GlobalKey trick)
  double _textWidth = 0;
  final GlobalKey _measureKey = GlobalKey();
  bool _measured = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 1));
    // After first frame, measure text and kick off scroll
    WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
  }

  void _measure() {
    if (!mounted) return;
    final box = _measureKey.currentContext?.findRenderObject() as RenderBox?;
    if (box != null) {
      _textWidth = box.size.width;
      _measured = true;
      _startScroll();
    }
  }

  void _startScroll() {
    if (_textWidth <= 0) return;
    // Duration = width / speed so speed stays constant regardless of text length
    final duration = Duration(milliseconds: (_textWidth / _speed * 1000).round());
    _controller.duration = duration;
    _controller.repeat();
  }


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsProvider);
    final theme = ref.watch(themeProvider);

    return settingsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (settings) {
        if (!settings.showNoticeBar) return const SizedBox.shrink();
        final notices = settings.notices;
        if (notices.isEmpty) return const SizedBox.shrink();

        // Build the text that scrolls: notices separated by " ◆ "
        final fullText = notices.join('   ◆   ');

        final textStyle = TextStyle(
          color: Color(theme.textColor).withOpacity(0.9),
          fontSize: 12,
          fontFamily: theme.fontFamily,
          letterSpacing: 0.3,
        );

        return Container(
          height: 28,
          decoration: BoxDecoration(
            color: Color(theme.accentColor).withOpacity(0.15),
            border: Border(
              bottom: BorderSide(
                color: Color(theme.accentColor).withOpacity(0.25),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              // "NOTICE" label badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                height: double.infinity,
                decoration: BoxDecoration(
                  color: Color(theme.accentColor).withOpacity(0.85),
                  border: Border(
                    right: BorderSide(
                      color: Color(theme.accentColor),
                      width: 1,
                    ),
                  ),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      FluentIcons.info,
                      size: 10,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'NOTICE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),

              // Scrolling ticker area
              Expanded(
                child: ClipRect(
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      if (!_measured || _textWidth == 0) {
                        // First pass: render offscreen to measure
                        return Stack(
                          children: [
                            Positioned(
                              top: -9999,
                              left: 0,
                              child: Row(
                                key: _measureKey,
                                children: [
                                  Text(fullText, style: textStyle),
                                  // Gap between loops
                                  const SizedBox(width: 120),
                                ],
                              ),
                            ),
                            Text(fullText, style: textStyle),
                          ],
                        );
                      }

                      // Offset goes from 0 → -_textWidth (one full loop)
                      // We render the text twice side by side for seamless looping
                      final offset = -_controller.value * _textWidth;

                      return Stack(
                        children: [
                          Positioned(
                            left: offset,
                            top: 0,
                            bottom: 0,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(fullText, style: textStyle),
                                const SizedBox(width: 120),
                                Text(fullText, style: textStyle),
                                const SizedBox(width: 120),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
