import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/widget_config_model.dart';
import '../../../core/providers/app_providers.dart';

const _quotes = [
  (
    text: 'The secret of getting ahead is getting started.',
    author: 'Mark Twain'
  ),
  (
    text: 'It always seems impossible until it is done.',
    author: 'Nelson Mandela'
  ),
  (
    text: 'Don\'t watch the clock; do what it does. Keep going.',
    author: 'Sam Levenson'
  ),
  (
    text: 'The future depends on what you do today.',
    author: 'Mahatma Gandhi'
  ),
  (
    text: 'An hour of planning can save you 10 hours of doing.',
    author: 'Dale Carnegie'
  ),
  (
    text: 'Focus on being productive instead of busy.',
    author: 'Tim Ferriss'
  ),
  (
    text: 'You don\'t have to be great to start, but you have to start to be great.',
    author: 'Zig Ziglar'
  ),
  (
    text: 'The key is not to prioritize what\'s on your schedule, but to schedule your priorities.',
    author: 'Stephen Covey'
  ),
];

class QuoteWidget extends ConsumerStatefulWidget {
  final WidgetConfig config;
  const QuoteWidget({super.key, required this.config});

  @override
  ConsumerState<QuoteWidget> createState() => _QuoteWidgetState();
}

class _QuoteWidgetState extends ConsumerState<QuoteWidget> {
  late int _quoteIndex;

  @override
  void initState() {
    super.initState();
    _quoteIndex = DateTime.now().day % _quotes.length;
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final q = _quotes[_quoteIndex];

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(FluentIcons.blocked12,
            size: 20, color: Color(theme.accentColor).withOpacity(0.5)),
        const SizedBox(height: 8),
        Text(
          '"${q.text}"',
          style: TextStyle(
            color: Color(theme.textColor),
            fontSize: 12,
            fontStyle: FontStyle.italic,
            fontFamily: theme.fontFamily,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          '— ${q.author}',
          style: TextStyle(
            color: Color(theme.accentColor),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => setState(
              () => _quoteIndex = (_quoteIndex + 1) % _quotes.length),
          child: Text(
            'Next quote →',
            style: TextStyle(
              color: Color(theme.secondaryTextColor),
              fontSize: 10,
            ),
          ),
        ),
      ],
    );
  }
}
