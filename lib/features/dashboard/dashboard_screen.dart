import 'dart:async';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../core/providers/app_providers.dart';
import '../../shared/components/top_bar.dart';
import '../../shared/components/notice_bar.dart';
import '../../shared/components/glass_container.dart';
import '../../shared/animations/animation_presets.dart';
import '../launcher/launcher_screen.dart';
import '../widgets/widget_board_screen.dart';
import '../schedule/schedule_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _selectedTab = 0;
  late Timer _clockTimer;
  DateTime _now = DateTime.now();

  final _tabs = ['Dashboard', 'Launcher', 'Widgets', 'Schedule'];

  @override
  void initState() {
    super.initState();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
    // Load active theme from settings
    ref.read(settingsProvider.future).then((settings) {
      ref.read(themeProvider.notifier).load(settings.activeThemeId);
    });
  }

  @override
  void dispose() {
    _clockTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final settingsAsync = ref.watch(settingsProvider);

    return settingsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (settings) => Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            // Top bar
            const TopBar(),
            // Scrolling notice ticker (hidden when no notices set)
            const NoticeBar(),

            // Tab bar
            _buildTabBar(theme),

            // Content
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                switchInCurve: Curves.easeOut,
                child: KeyedSubtree(
                  key: ValueKey(_selectedTab),
                  child: _buildContent(settings),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar(theme) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      borderRadius: 0,
      child: Row(
        children: List.generate(_tabs.length, (i) {
          final selected = i == _selectedTab;
          return Padding(
            padding: const EdgeInsets.only(right: 4),
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: selected
                      ? Color(ref.watch(themeProvider).accentColor).withOpacity(0.2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: selected
                      ? Border.all(
                          color: Color(ref.watch(themeProvider).accentColor)
                              .withOpacity(0.5),
                          width: 1,
                        )
                      : null,
                ),
                child: Text(
                  _tabs[i],
                  style: TextStyle(
                    color: selected
                        ? Color(ref.watch(themeProvider).accentColor)
                        : Color(ref.watch(themeProvider).secondaryTextColor),
                    fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildContent(settings) {
    switch (_selectedTab) {
      case 0:
        return _HomeTab(now: _now, settings: settings);
      case 1:
        return const LauncherScreen();
      case 2:
        return const WidgetBoardScreen();
      case 3:
        return const ScheduleScreen();
      default:
        return const SizedBox.shrink();
    }
  }
}

// ─── Home tab ─────────────────────────────────────────────────────────────────

class _HomeTab extends ConsumerWidget {
  final DateTime now;
  final dynamic settings;

  const _HomeTab({required this.now, required this.settings});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final schedules = ref.watch(scheduleProvider);
    final current = ref.read(scheduleProvider.notifier).current;
    final next = ref.read(scheduleProvider.notifier).next;

    return SingleChildScrollView(
      padding: EdgeInsets.all(theme.margin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome hero
          _WelcomeCard(now: now, settings: settings).fadeSlideIn(),
          SizedBox(height: theme.spacing * 2),

          // Current task + upcoming
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Current task
              Expanded(
                child: _CurrentTaskCard(current: current)
                    .fadeSlideIn(delay: 100.ms),
              ),
              SizedBox(width: theme.spacing * 2),
              // Upcoming
              Expanded(
                child: _UpcomingTaskCard(next: next)
                    .fadeSlideIn(delay: 200.ms),
              ),
            ],
          ),
          SizedBox(height: theme.spacing * 2),

          // Quick stats row
          _QuickStatsRow().fadeSlideIn(delay: 300.ms),
        ],
      ),
    );
  }
}

class _WelcomeCard extends ConsumerWidget {
  final DateTime now;
  final dynamic settings;

  const _WelcomeCard({required this.now, required this.settings});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final hour = now.hour;
    final greeting = hour < 12
        ? 'Good Morning'
        : hour < 17
            ? 'Good Afternoon'
            : 'Good Evening';

    return GlassContainer(
      padding: const EdgeInsets.all(32),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$greeting,',
                  style: TextStyle(
                    color: Color(theme.secondaryTextColor),
                    fontSize: theme.baseFontSize + 2,
                    fontFamily: theme.fontFamily,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  settings.username,
                  style: TextStyle(
                    color: Color(theme.textColor),
                    fontSize: theme.baseFontSize + 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: theme.fontFamily,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  settings.welcomeText,
                  style: TextStyle(
                    color: Color(theme.secondaryTextColor),
                    fontSize: theme.baseFontSize,
                    fontFamily: theme.fontFamily,
                  ),
                ),
              ],
            ),
          ),
          // Big clock
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                DateFormat(settings.timeFormat).format(now),
                style: TextStyle(
                  color: Color(theme.accentColor),
                  fontSize: 48,
                  fontWeight: FontWeight.w300,
                  fontFamily: theme.fontFamily,
                  letterSpacing: -1,
                ),
              ),
              Text(
                DateFormat(settings.dateFormat).format(now),
                style: TextStyle(
                  color: Color(theme.secondaryTextColor),
                  fontSize: theme.baseFontSize,
                  fontFamily: theme.fontFamily,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CurrentTaskCard extends ConsumerWidget {
  final dynamic current;
  const _CurrentTaskCard({this.current});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);

    if (current == null) {
      return GlassContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Current Task',
                style: TextStyle(
                  color: Color(theme.secondaryTextColor),
                  fontSize: 12,
                  fontFamily: theme.fontFamily,
                )),
            const SizedBox(height: 12),
            Text('No active task',
                style: TextStyle(
                  color: Color(theme.textColor),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  fontFamily: theme.fontFamily,
                )),
            const SizedBox(height: 4),
            Text('All caught up! 🎉',
                style: TextStyle(
                  color: Color(theme.secondaryTextColor),
                  fontSize: 12,
                  fontFamily: theme.fontFamily,
                )),
          ],
        ),
      );
    }

    final progress = current.progress;
    final remaining = current.timeRemaining;
    final mins = remaining.inMinutes;
    final secs = remaining.inSeconds % 60;

    return GlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Color(current.color),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text('Current Task',
                  style: TextStyle(
                    color: Color(theme.secondaryTextColor),
                    fontSize: 12,
                    fontFamily: theme.fontFamily,
                  )),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('RUNNING',
                    style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(current.title,
              style: TextStyle(
                color: Color(theme.textColor),
                fontSize: 18,
                fontWeight: FontWeight.w600,
                fontFamily: theme.fontFamily,
              )),
          if (current.description.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(current.description,
                style: TextStyle(
                  color: Color(theme.secondaryTextColor),
                  fontSize: 12,
                  fontFamily: theme.fontFamily,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
          ],
          const SizedBox(height: 16),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(Color(current.color)),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${(progress * 100).round()}% complete',
                  style: TextStyle(
                    color: Color(theme.secondaryTextColor),
                    fontSize: 11,
                  )),
              Text('${mins}m ${secs}s remaining',
                  style: TextStyle(
                    color: Color(current.color),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  )),
            ],
          ),
        ],
      ),
    );
  }
}

class _UpcomingTaskCard extends ConsumerWidget {
  final dynamic next;
  const _UpcomingTaskCard({this.next});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);

    if (next == null) {
      return GlassContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Upcoming Task',
                style: TextStyle(color: Color(theme.secondaryTextColor), fontSize: 12)),
            const SizedBox(height: 12),
            Text('Nothing scheduled',
                style: TextStyle(
                    color: Color(theme.textColor), fontSize: 18, fontWeight: FontWeight.w600)),
          ],
        ),
      );
    }

    final startsIn = next.startTime.difference(DateTime.now());
    final hours = startsIn.inHours;
    final mins = startsIn.inMinutes % 60;
    final startsInText = hours > 0 ? 'in ${hours}h ${mins}m' : 'in ${mins}m';

    return GlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Color(next.color),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text('Upcoming Task',
                  style: TextStyle(color: Color(theme.secondaryTextColor), fontSize: 12)),
            ],
          ),
          const SizedBox(height: 12),
          Text(next.title,
              style: TextStyle(
                color: Color(theme.textColor),
                fontSize: 18,
                fontWeight: FontWeight.w600,
                fontFamily: theme.fontFamily,
              )),
          const SizedBox(height: 4),
          Text('Starts $startsInText',
              style: TextStyle(
                color: Color(next.color),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              )),
          const SizedBox(height: 8),
          Text(
            DateFormat('HH:mm').format(next.startTime) +
                ' – ' +
                DateFormat('HH:mm').format(next.endTime),
            style: TextStyle(
              color: Color(theme.secondaryTextColor),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickStatsRow extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final schedules = ref.watch(scheduleProvider);
    final todos = ref.watch(todoProvider);
    final shortcuts = ref.watch(launcherProvider).shortcuts;

    final completedToday =
        todos.where((t) => t.isCompleted).length;
    final totalTodos = todos.length;

    return Row(
      children: [
        _StatCard(
          label: 'Schedules',
          value: '${schedules.where((s) => s.isActive).length}',
          icon: FluentIcons.calendar,
          color: Color(theme.accentColor),
        ).fadeScaleIn(delay: 0.ms),
        SizedBox(width: theme.spacing),
        _StatCard(
          label: 'To-Do Done',
          value: '$completedToday / $totalTodos',
          icon: FluentIcons.check_mark,
          color: const Color(0xFF6BCB77),
        ).fadeScaleIn(delay: 50.ms),
        SizedBox(width: theme.spacing),
        _StatCard(
          label: 'Apps',
          value: '${shortcuts.length}',
          icon: FluentIcons.app_icon_default,
          color: const Color(0xFFFFD166),
        ).fadeScaleIn(delay: 100.ms),
        SizedBox(width: theme.spacing),
        _StatCard(
          label: 'Favorites',
          value: '${shortcuts.where((s) => s.isFavorite).length}',
          icon: FluentIcons.favorite_star,
          color: const Color(0xFFFF8C42),
        ).fadeScaleIn(delay: 150.ms),
      ].map((e) => Expanded(child: e)).toList(),
    );
  }
}

class _StatCard extends ConsumerWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    return GlassContainer(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: TextStyle(
                    color: Color(theme.textColor),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  )),
              Text(label,
                  style: TextStyle(
                    color: Color(theme.secondaryTextColor),
                    fontSize: 11,
                  )),
            ],
          ),
        ],
      ),
    );
  }
}
