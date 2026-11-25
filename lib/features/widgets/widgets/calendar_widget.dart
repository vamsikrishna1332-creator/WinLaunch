import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/models/widget_config_model.dart';
import '../../../core/providers/app_providers.dart';

class CalendarWidget extends ConsumerStatefulWidget {
  final WidgetConfig config;
  const CalendarWidget({super.key, required this.config});

  @override
  ConsumerState<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends ConsumerState<CalendarWidget> {
  late DateTime _month;
  final DateTime _today = DateTime.now();

  @override
  void initState() {
    super.initState();
    _month = DateTime(_today.year, _today.month);
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final schedules = ref.watch(scheduleProvider);

    final daysInMonth =
        DateTime(_month.year, _month.month + 1, 0).day;
    final firstWeekday = DateTime(_month.year, _month.month, 1).weekday % 7;

    return Column(
      children: [
        // Month nav
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(FluentIcons.chevron_left,
                  size: 12, color: Color(theme.textColor)),
              onPressed: () => setState(() =>
                  _month = DateTime(_month.year, _month.month - 1)),
            ),
            Text(
              DateFormat('MMMM yyyy').format(_month),
              style: TextStyle(
                color: Color(theme.textColor),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            IconButton(
              icon: Icon(FluentIcons.chevron_right,
                  size: 12, color: Color(theme.textColor)),
              onPressed: () => setState(() =>
                  _month = DateTime(_month.year, _month.month + 1)),
            ),
          ],
        ),
        const SizedBox(height: 6),

        // Weekday headers
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: ['S', 'M', 'T', 'W', 'T', 'F', 'S'].map((d) {
            return SizedBox(
              width: 24,
              child: Text(d,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(theme.secondaryTextColor),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  )),
            );
          }).toList(),
        ),
        const SizedBox(height: 4),

        // Calendar grid
        Expanded(
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
            ),
            itemCount: firstWeekday + daysInMonth,
            itemBuilder: (_, idx) {
              if (idx < firstWeekday) return const SizedBox.shrink();
              final day = idx - firstWeekday + 1;
              final date = DateTime(_month.year, _month.month, day);
              final isToday = date.year == _today.year && date.month == _today.month && date.day == _today.day;
              final hasSchedule = schedules.any((s) => s.occursOn(date));

              return GestureDetector(
                onTap: () {},
                child: Container(
                  margin: const EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    color: isToday
                        ? Color(theme.accentColor)
                        : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        '$day',
                        style: TextStyle(
                          color: isToday
                              ? Colors.white
                              : Color(theme.textColor),
                          fontSize: 10,
                          fontWeight:
                              isToday ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      if (hasSchedule && !isToday)
                        Positioned(
                          bottom: 2,
                          child: Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Color(theme.accentColor),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
