import 'dart:async';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../core/models/note_model.dart';
import '../../core/models/schedule_model.dart';
import '../../core/providers/app_providers.dart';
import '../launcher/launcher_screen.dart';
import '../schedule/schedule_screen.dart';
import '../settings/settings_screen.dart';
import '../widgets/widget_board_screen.dart';
import '../chatgpt/chatgpt_screen.dart';

const _background = Color(0xFF081423);
const _sidebar = Color(0xFF0B1525);
const _card = Color(0xFF101E2F);
const _border = Color(0xFF233145);
const _muted = Color(0xFF9CA9BD);
const _purple = Color(0xFF7562E8);
const _green = Color(0xFF38CB74);
const _blue = Color(0xFF458EF5);

/// Reference-based Windows shell: 190px sidebar, compact notice ticker,
/// and dashboard grid. Existing provider-backed data stays intact.
class DashboardScreen extends ConsumerStatefulWidget {
  final String? signedInName;
  final VoidCallback? onSignOut;
  const DashboardScreen({super.key, this.signedInName, this.onSignOut});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  static const _labels = <String>[
    'Dashboard', 'Schedule', 'Tasks', 'Notes', 'Apps',
    'Focus Timer', 'Habits', 'Journal', 'Settings', 'ChatGPT', 'Widgets'
  ];
  static const _icons = <IconData>[
    FluentIcons.home, FluentIcons.calendar, FluentIcons.check_mark,
    FluentIcons.edit, FluentIcons.app_icon_default, FluentIcons.timer,
    FluentIcons.favorite_star, FluentIcons.page, FluentIcons.settings,
    FluentIcons.chat, FluentIcons.app_icon_default
  ];
  int _page = 0;
  DateTime _now = DateTime.now();
  late Timer _ticker;
  int _focusSeconds = 25 * 60;
  bool _focusActive = false;
  List<String> _habits = [];
  List<String> _completedHabits = [];

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _now = DateTime.now();
        if (_focusActive && _focusSeconds > 0) _focusSeconds--;
        if (_focusSeconds <= 0) _focusActive = false;
      });
    });
    _loadHabits();
  }

  Future<void> _loadHabits() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _habits = prefs.getStringList('launchdesk_habits') ?? [];
      _completedHabits = prefs.getStringList(
        'launchdesk_habits_' + DateFormat('yyyy-MM-dd').format(DateTime.now())) ?? [];
    });
  }

  Future<void> _addHabit() async {
    final name = await _inputDialog('New habit', 'Habit name');
    if (name == null || name.isEmpty || _habits.contains(name)) return;
    setState(() => _habits = [..._habits, name]);
    (await SharedPreferences.getInstance())
        .setStringList('launchdesk_habits', _habits);
  }

  Future<void> _toggleHabit(String habit) async {
    setState(() {
      _completedHabits = _completedHabits.contains(habit)
          ? _completedHabits.where((h) => h != habit).toList()
          : [..._completedHabits, habit];
    });
    (await SharedPreferences.getInstance()).setStringList(
      'launchdesk_habits_' + DateFormat('yyyy-MM-dd').format(DateTime.now()),
      _completedHabits);
  }

  @override
  void dispose() {
    _ticker.cancel();
    super.dispose();
  }

  Future<String?> _inputDialog(String title, String hint) async {
    final controller = TextEditingController();
    try {
      return await showDialog<String>(
        context: context,
        builder: (dialogContext) => ContentDialog(
          title: Text(title),
          content: TextBox(controller: controller, placeholder: hint,
              autofocus: true),
          actions: [
            Button(child: const Text('Cancel'),
                onPressed: () => Navigator.pop(dialogContext)),
            FilledButton(child: const Text('Save'),
                onPressed: () => Navigator.pop(dialogContext, controller.text.trim()))
          ],
        ),
      );
    } finally {
      controller.dispose();
    }
  }

  Future<void> _addTask() async {
    final title = await _inputDialog('Add task', 'What needs doing?');
    if (title == null || title.isEmpty) return;
    await ref.read(todoProvider.notifier).add(TodoItem(
        id: const Uuid().v4(), text: title));
  }

  Future<void> _addNote({bool journal = false}) async {
    final title = await _inputDialog(
      journal ? 'New journal entry' : 'New note', 'Title');
    if (title == null || title.isEmpty || !mounted) return;
    final body = await _inputDialog('Write ' + title, 'Your text');
    if (body == null) return;
    final now = DateTime.now();
    await ref.read(notesProvider.notifier).add(Note(
      id: const Uuid().v4(), title: title, content: body,
      tags: journal ? ['journal'] : [], createdAt: now, updatedAt: now,
    ));
  }

  Widget _sidebarItem(int index) {
    final selected = index == _page;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      child: HoverButton(
        onPressed: () => setState(() => _page = index),
        builder: (context, states) => Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 13),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF272659)
                : const Color(0xFF0B1525),
            borderRadius: BorderRadius.circular(7),
          ),
          child: Row(children: [
            Icon(_icons[index], size: 15,
                color: selected ? const Color(0xFFAC9AFF) : _muted),
            const SizedBox(width: 13),
            Text(_labels[index], style: TextStyle(
              fontSize: 12, color: selected ? const Color(0xFFFFFFFF) : _muted,
              fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
            )),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final schedules = ref.watch(scheduleProvider);
    final active = schedules.where((s) => s.isActive && s.isRunning).toList();
    final running = active.isEmpty ? null : active.first;
    final upcoming = schedules.where((s) =>
        s.isActive && s.startTime.isAfter(_now)).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
    final next = upcoming.isEmpty ? null : upcoming.first;
    final String name = widget.signedInName ??
        ref.watch(settingsProvider).asData?.value.username ?? 'User';

    return Container(
      color: _background,
      child: Row(children: [
        Container(
          width: 190,
          decoration: const BoxDecoration(color: _sidebar,
              border: Border(right: BorderSide(color: _border))),
          child: Column(children: [
            Container(
              height: 75, padding: const EdgeInsets.only(left: 19),
              alignment: Alignment.centerLeft,
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('LaunchDesk', style: TextStyle(
                    color: Color(0xFF9685FF), fontWeight: FontWeight.bold,
                    fontSize: 20)),
                  SizedBox(height: 3),
                  Text('Launcher', style: TextStyle(
                    color: _muted, fontSize: 10)),
                ],
              ),
            ),
            Expanded(child: ListView(
              children: [
                for (var i = 0; i < 9; i++) _sidebarItem(i),
                const SizedBox(height: 14),
                const Padding(
                  padding: EdgeInsets.only(left: 22, bottom: 7),
                  child: Text('INTEGRATIONS', style: TextStyle(
                      fontSize: 9, letterSpacing: 1, color: _muted)),
                ),
                _sidebarItem(9),
                _sidebarItem(10),
              ],
            )),
            Container(height: 1, color: _border),
            Container(
              padding: const EdgeInsets.all(13),
              child: Row(children: [
                Container(
                  width: 31, height: 31, alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: Color(0xFF3C3368), shape: BoxShape.circle),
                  child: Text(name.isEmpty ? 'U' : name[0].toUpperCase(),
                      style: const TextStyle(fontSize: 14)),
                ),
                const SizedBox(width: 8),
                Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 11,
                              fontWeight: FontWeight.w600)),
                      const Text('Stay productive!', style:
                          TextStyle(fontSize: 9, color: _muted))
                    ])),
                if (widget.onSignOut != null)
                  Tooltip(
                    message: 'Lock workspace',
                    child: IconButton(
                      icon: const Icon(FluentIcons.lock, size: 13),
                      onPressed: widget.onSignOut,
                    ),
                  ),
              ]),
            )
          ]),
        ),
        Expanded(child: Column(children: [
          _notice(running, next),
          Expanded(child: _body(name, running, next)),
        ])),
      ]),
    );
  }

  Widget _notice(Schedule? running, Schedule? next) {
    final currentText = running == null
        ? 'No task running'
        : 'NOW RUNNING: ' + running.title +
            '  |  Ends in ' + running.timeRemaining.inMinutes.toString() + ' min';
    final nextText = next == null ? 'No upcoming schedule'
        : 'NEXT: ' + next.title + ' at ' + DateFormat('hh:mm a').format(next.startTime);
    return Container(
      height: 29, padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: const BoxDecoration(color: Color(0xFF0C1929),
          border: Border(bottom: BorderSide(color: _border))),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
          decoration: BoxDecoration(color: const Color(0xFFE2B340),
              borderRadius: BorderRadius.circular(4)),
          child: const Text('📢 NOTICE', style: TextStyle(
              color: Color(0xFF14202D), fontSize: 9,
              fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 12),
        const Icon(FluentIcons.circle_fill, color: _green, size: 6),
        const SizedBox(width: 7),
        Expanded(child: Text(currentText + '   |   ' + nextText +
            '   ◆   Stay focused. Great things take time.',
            maxLines: 1, overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Color(0xFFD6DEE9), fontSize: 10))),
      ]),
    );
  }

  Widget _body(String name, Schedule? running, Schedule? next) {
    if (_page == 4) return const LauncherScreen();
    if (_page == 8) return SettingsScreen(
      onBack: () => setState(() => _page = 0));
    if (_page == 9) return const ChatGptScreen();
    if (_page == 10) return const WidgetBoardScreen();
    return LayoutBuilder(builder: (context, constraints) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(width: constraints.maxWidth < 980 ? 980 : constraints.maxWidth,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: 790,
                  minHeight: constraints.maxHeight > 0
                      ? constraints.maxHeight - 40 : 0),
          child: switch (_page) {
            0 => _home(name, running, next),
            1 => _schedulePage(),
            2 => _tasksPage(),
            3 => _notesPage(journal: false),
            5 => _focusPage(),
            6 => _habitsPage(),
            7 => _notesPage(journal: true),
            _ => const SizedBox.shrink(),
          },
            ),
          ),
        ),
      );
    });
  }

  Widget _home(String name, Schedule? running, Schedule? next) {
    final todos = ref.watch(todoProvider);
    final notes = ref.watch(notesProvider)
        .where((n) => !n.tags.contains('journal')).toList();
    final schedules = ref.watch(scheduleProvider);
    final shortcuts = ref.watch(launcherProvider).shortcuts;
    final snapshot = ref.watch(systemInfoProvider).asData?.value;
    final completed = todos.where((t) => t.isCompleted).length;
    final total = todos.length;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Welcome back,', style: TextStyle(
                color: _muted, fontSize: 14)),
            const SizedBox(height: 2),
            Text(name + ' 👋', style: const TextStyle(
                fontSize: 29, fontWeight: FontWeight.w700)),
            const SizedBox(height: 3),
            const Text('Stay focused. Stay consistent. Success is on the way.',
                style: TextStyle(fontSize: 11, color: _muted)),
          ],
        )),
        _tile(
          Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(FluentIcons.clock, color: _purple, size: 27),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(DateFormat('hh:mm:ss a').format(_now), style:
                  const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              Text(DateFormat('EEEE, dd MMM yyyy').format(_now),
                  style: const TextStyle(color: _muted, fontSize: 10)),
            ]),
          ]),
          padding: 14,
        ),
      ]),
      const SizedBox(height: 16),
      SizedBox(height: 245, child: Row(children: [
        Expanded(flex: 11, child: _tile(
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const _SmallLabel('● NOW RUNNING', _green),
            const SizedBox(height: 7),
            Row(children: [
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(running?.title ?? 'No active task',
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 24,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 7),
                  Text(running == null ? 'Add a schedule to get started'
                      : DateFormat('hh:mm a').format(running.startTime) +
                        ' - ' + DateFormat('hh:mm a').format(running.endTime),
                      style: const TextStyle(color: _muted, fontSize: 11)),
                  const SizedBox(height: 13),
                  Text(running == null ? 'READY' :
                      'Ends in ' + running.timeRemaining.inMinutes.toString() +
                          ' minutes', style: const TextStyle(
                              fontSize: 12, color: _green)),
                ],
              )),
              _ring(running?.progress ?? 0, _green, 86,
                  ((running?.progress ?? 0) * 100).round().toString() + '%',
                  'Complete'),
            ]),
            const SizedBox(height: 15),
            _progress(running?.progress ?? 0, _green, 7),
            const SizedBox(height: 11),
            Row(children: [
              const Text('NEXT', style: TextStyle(
                  color: _blue, fontSize: 10, fontWeight: FontWeight.bold)),
              const Spacer(),
              Text(next == null ? '--' :
                DateFormat('hh:mm a').format(next.startTime),
                style: const TextStyle(color: _blue, fontSize: 10)),
            ]),
            const SizedBox(height: 3),
            Text(next?.title ?? 'Nothing upcoming',
                style: const TextStyle(color: _muted, fontSize: 11)),
          ]), padding: 18,
        )),
        const SizedBox(width: 13),
        Expanded(flex: 9, child: _tile(
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const _Heading('TODAY\'S SCHEDULE'),
              const Spacer(),
              _link('View all', () => setState(() => _page = 1)),
            ]),
            const SizedBox(height: 12),
            if (schedules.isEmpty)
              const Text('No schedules yet', style: TextStyle(color: _muted))
            else
              ...schedules.where((s) => s.isActive && s.occursOn(_now))
                  .take(4).map((s) => Padding(
                    padding: const EdgeInsets.only(bottom: 11),
                    child: Row(children: [
                      Container(width: 7, height: 7, decoration: BoxDecoration(
                          shape: BoxShape.circle, color: Color(s.color))),
                      const SizedBox(width: 10),
                      Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s.title, maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12,
                                  fontWeight: FontWeight.w600)),
                          Text(DateFormat('hh:mm a').format(s.startTime) +
                              ' - ' + DateFormat('hh:mm a').format(s.endTime),
                            style: const TextStyle(color: _muted, fontSize: 10)),
                        ])),
                      if (s.isRunning)
                        const Text('RUNNING', style:
                            TextStyle(fontSize: 9, color: _green)),
                    ]),
                  )),
          ]), padding: 18,
        )),
      ])),
      const SizedBox(height: 13),
      SizedBox(height: 160, child: Row(children: [
        Expanded(child: _tile(Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: [
            const _Heading('FOCUS TIMER'),
            const SizedBox(height: 13),
            Row(children: [
              _ring(_focusSeconds / 1500, _purple, 86,
                  _formatFocus(), _focusActive ? 'Running' : 'Focus'),
              const SizedBox(width: 14),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Ready to focus?', style:
                      TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                  const SizedBox(height: 5),
                  const Text('Eliminate distractions and get things done.',
                      style: TextStyle(fontSize: 10, color: _muted)),
                  const SizedBox(height: 10),
                  FilledButton(
                    onPressed: () => setState(() =>
                        _focusActive = !_focusActive),
                    child: Text(_focusActive ? 'Pause Focus' : 'Start Focus'),
                  ),
                ],
              ))
            ]),
          ]), padding: 15)),
        const SizedBox(width: 12),
        Expanded(child: _tile(Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: [
            const _Heading('TASKS OVERVIEW'),
            const SizedBox(height: 18),
            Row(children: [
              _stat(total.toString(), 'Total Tasks', _purple),
              _stat(completed.toString(), 'Completed', _green),
            ]),
            const SizedBox(height: 14),
            Row(children: [
              _stat((total - completed).toString(), 'In Progress',
                  const Color(0xFFFFCA62)),
              _stat((total - completed).toString(), 'Pending', _blue),
            ]),
          ]), padding: 15)),
        const SizedBox(width: 12),
        Expanded(child: _tile(Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const _Heading('QUICK NOTES'),
              const Spacer(),
              IconButton(icon: const Icon(FluentIcons.add, size: 12),
                  onPressed: () => _addNote()),
            ]),
            const SizedBox(height: 10),
            if (notes.isEmpty)
              const Text('Add your first note',
                  style: TextStyle(color: _muted, fontSize: 11))
            else
              ...notes.take(3).map((note) => Padding(
                padding: const EdgeInsets.only(bottom: 9),
                child: Text('•  ' + note.title, maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11)),
              )),
          ]), padding: 15)),
      ])),
      const SizedBox(height: 13),
      SizedBox(height: 90, child: Row(children: [
        Expanded(flex: 4, child: _tile(Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const _Heading('QUICK LAUNCH'),
              const Spacer(),
              _link('+ Add', () => setState(() => _page = 4)),
            ]),
            const SizedBox(height: 11),
            Expanded(child: Row(children: [
              if (shortcuts.isEmpty)
                const Text('Add apps in the Apps page',
                    style: TextStyle(fontSize: 11, color: _muted))
              else
                ...shortcuts.take(8).map((shortcut) => Expanded(
                  child: HoverButton(
                    onPressed: () => ref.read(launcherProvider.notifier)
                        .launch(shortcut),
                    builder: (_, states) => Column(children: [
                      Icon(FluentIcons.app_icon_default,
                          color: Color(shortcut.iconColor), size: 19),
                      const SizedBox(height: 5),
                      Text(shortcut.name, maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 9, color: _muted)),
                    ]),
                  ),
                )),
            ])),
          ]), padding: 13)),
        const SizedBox(width: 12),
        Expanded(flex: 2, child: _tile(Row(children: [
          const Icon(FluentIcons.power_button, color: _green, size: 20),
          const SizedBox(width: 8),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Battery', style: TextStyle(color: _muted, fontSize: 10)),
            Text(snapshot == null ? '—' :
                snapshot.batteryPercent.toString() + '%',
                style: const TextStyle(color: _green,
                    fontWeight: FontWeight.bold)),
            Text(snapshot?.isCharging == true ? 'Charging' : 'System',
                style: const TextStyle(fontSize: 9, color: _muted)),
          ]),
        ]), padding: 13)),
      ])),
    ]);
  }

  Widget _schedulePage() {
    final schedules = ref.watch(scheduleProvider);
    final today = schedules.where((s) => s.isActive && s.occursOn(_now)).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _pageHeading('Schedule', 'Your day at a glance',
          'Manage schedules', () => Navigator.push(context,
            FluentPageRoute(builder: (_) => const ScaffoldPage(
                content: ScheduleScreen())))),
      const SizedBox(height: 17),
      _tile(Column(children: [
        Row(children: [
          const Text('Day View', style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 16)),
          const Spacer(),
          Text(DateFormat('EEEE, MMMM d').format(_now),
              style: const TextStyle(fontSize: 12, color: _muted))
        ]),
        const SizedBox(height: 14),
        for (var hour = 7; hour <= 22; hour++)
          Container(
            constraints: const BoxConstraints(minHeight: 49),
            decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: _border))),
            child: Row(children: [
              SizedBox(width: 70, child: Text(
                DateFormat('h a').format(DateTime(2026, 1, 1, hour)),
                style: const TextStyle(fontSize: 11, color: _muted))),
              Expanded(child: Wrap(spacing: 6, runSpacing: 6,
                children: today.where((s) => s.startTime.hour == hour)
                    .map((s) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 9),
                      decoration: BoxDecoration(
                        color: Color(s.color).withOpacity(0.16),
                        border: Border(left: BorderSide(
                            color: Color(s.color), width: 3)),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(s.title + ' · ' +
                          DateFormat('h:mm a').format(s.startTime),
                          style: const TextStyle(fontSize: 12)),
                    )).toList(),
              )),
            ]),
          ),
      ])),
    ]);
  }

  Widget _tasksPage() {
    final todos = ref.watch(todoProvider);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _pageHeading('Tasks', 'Keep track of everything you need to do',
          '+ Add Task', _addTask),
      const SizedBox(height: 17),
      _tile(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const _Heading('TO-DO LIST'),
        const SizedBox(height: 12),
        if (todos.isEmpty)
          const Text('No tasks yet. Add your first task.',
              style: TextStyle(color: _muted)),
        for (final task in todos)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: const BoxDecoration(border:
                Border(bottom: BorderSide(color: _border))),
            child: Row(children: [
              Checkbox(checked: task.isCompleted,
                onChanged: (_) => ref.read(todoProvider.notifier)
                    .toggle(task.id)),
              const SizedBox(width: 10),
              Expanded(child: Text(task.text,
                  style: TextStyle(color: task.isCompleted ? _muted
                      : const Color(0xFFE7EAF4),
                      decoration: task.isCompleted
                          ? TextDecoration.lineThrough : null))),
              IconButton(icon: const Icon(FluentIcons.delete, size: 13),
                  onPressed: () => ref.read(todoProvider.notifier)
                      .remove(task.id)),
            ]),
          ),
      ])),
    ]);
  }

  Widget _notesPage({required bool journal}) {
    final entries = ref.watch(notesProvider).where((n) =>
        n.tags.contains('journal') == journal).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _pageHeading(journal ? 'Journal' : 'Notes',
          journal ? 'Capture the moments that matter' :
            'Organize ideas and thoughts',
          journal ? '+ New Entry' : '+ New Note',
          () => _addNote(journal: journal)),
      const SizedBox(height: 17),
      if (entries.isEmpty)
        _tile(Text(journal ? 'Your journal is empty.' :
            'Create a note to get started.',
            style: const TextStyle(color: _muted)))
      else
        Wrap(spacing: 12, runSpacing: 12, children: entries.map((note) =>
          SizedBox(width: 300, child: _tile(Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text(note.title,
                    style: const TextStyle(fontSize: 15,
                        fontWeight: FontWeight.bold))),
                IconButton(icon: const Icon(FluentIcons.delete, size: 12),
                  onPressed: () => ref.read(notesProvider.notifier)
                      .remove(note.id)),
              ]),
              const SizedBox(height: 10),
              Text(note.content, maxLines: 8,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: _muted)),
              const SizedBox(height: 11),
              Text(DateFormat('MMM d, yyyy').format(note.updatedAt),
                  style: const TextStyle(fontSize: 10, color: _muted)),
            ]), padding: 16)),
        ).toList()),
    ]);
  }

  Widget _focusPage() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _pageHeading('Focus Timer', 'Stay in the zone', null, null),
      const SizedBox(height: 18),
      Center(child: SizedBox(width: 440, child: _tile(Column(children: [
        const _Heading('POMODORO · FOCUS SESSION'),
        const SizedBox(height: 35),
        _ring(_focusSeconds / 1500, _purple, 240, _formatFocus(), 'Focus'),
        const SizedBox(height: 32),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          FilledButton(
            onPressed: () => setState(() =>
                _focusActive = !_focusActive),
            child: Text(_focusActive ? 'Pause' : 'Start Focus'),
          ),
          const SizedBox(width: 13),
          Button(
            onPressed: () => setState(() {
              _focusActive = false; _focusSeconds = 1500;
            }),
            child: const Text('Reset'),
          ),
        ]),
        const SizedBox(height: 18),
        const Text('25-minute focus session',
            style: TextStyle(color: _muted, fontSize: 12)),
      ]), padding: 34))),
    ]);
  }

  Widget _habitsPage() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _pageHeading('Habits', 'Build consistency, one day at a time',
          '+ Add Habit', _addHabit),
      const SizedBox(height: 17),
      _tile(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const _Heading('WEEKLY HABIT TRACKER'),
        const SizedBox(height: 18),
        if (_habits.isEmpty)
          const Text('Add your first habit',
              style: TextStyle(color: _muted)),
        for (final habit in _habits)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 11),
            decoration: const BoxDecoration(border: Border(
                bottom: BorderSide(color: _border))),
            child: Row(children: [
              Expanded(child: Text(habit, style:
                  const TextStyle(fontWeight: FontWeight.w600))),
              Text(DateFormat('EEE, MMM d').format(_now),
                  style: const TextStyle(color: _muted, fontSize: 11)),
              const SizedBox(width: 16),
              Checkbox(checked: _completedHabits.contains(habit),
                  onChanged: (_) => _toggleHabit(habit)),
              IconButton(icon: const Icon(FluentIcons.delete, size: 13),
                onPressed: () async {
                  setState(() => _habits.remove(habit));
                  (await SharedPreferences.getInstance())
                      .setStringList('launchdesk_habits', _habits);
                }),
            ]),
          ),
      ])),
    ]);
  }

  String _formatFocus() {
    final mins = (_focusSeconds ~/ 60).toString().padLeft(2, '0');
    final secs = (_focusSeconds % 60).toString().padLeft(2, '0');
    return mins + ':' + secs;
  }

  Widget _pageHeading(String title, String description,
      String? action, VoidCallback? callback) {
    return Row(children: [
      Expanded(child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(
              fontSize: 29, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text(description, style:
              const TextStyle(fontSize: 12, color: _muted)),
        ],
      )),
      if (action != null && callback != null)
        FilledButton(onPressed: callback, child: Text(action)),
    ]);
  }

  Widget _stat(String value, String label, Color color) => Expanded(
    child: Row(children: [
      Container(
        width: 31, height: 31, alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color.withOpacity(0.17), shape: BoxShape.circle),
        child: Text(value, style: TextStyle(
            color: color, fontWeight: FontWeight.bold, fontSize: 12)),
      ),
      const SizedBox(width: 8),
      Expanded(child: Text(label, style:
          const TextStyle(fontSize: 10, color: _muted))),
    ]),
  );

  Widget _link(String label, VoidCallback pressed) => HoverButton(
    onPressed: pressed,
    builder: (_, states) => Text(label, style: TextStyle(
      fontSize: 10, color: _purple)),
  );

  Widget _tile(Widget child, {double padding = 16}) => Container(
    padding: EdgeInsets.all(padding),
    decoration: BoxDecoration(
      color: _card, borderRadius: BorderRadius.circular(9),
      border: Border.all(color: _border, width: 0.8),
    ),
    child: child,
  );

  Widget _progress(double amount, Color color, double height) =>
      ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: SizedBox(height: height,
          child: ProgressBar(value: (amount * 100).clamp(0, 100).toDouble(),
              activeColor: color, backgroundColor: const Color(0xFF263247)),
        ),
      );

  Widget _ring(double progress, Color color, double size,
      String primary, String secondary) {
    return SizedBox(
      width: size, height: size,
      child: Stack(alignment: Alignment.center, children: [
        SizedBox(
          width: size, height: size,
          child: ProgressRing(
            value: (progress * 100).clamp(0, 100).toDouble(),
            strokeWidth: size > 100 ? 9 : 6,
            activeColor: color,
            backgroundColor: const Color(0xFF243149),
          ),
        ),
        Column(mainAxisSize: MainAxisSize.min, children: [
          Text(primary, style: TextStyle(fontSize: size > 100 ? 38 : 17,
              fontWeight: FontWeight.bold)),
          Text(secondary, style: TextStyle(
              fontSize: size > 100 ? 12 : 9, color: _muted)),
        ]),
      ]),
    );
  }
}

class _SmallLabel extends StatelessWidget {
  final String value;
  final Color color;
  const _SmallLabel(this.value, this.color);
  @override
  Widget build(BuildContext context) =>
      Text(value, style: TextStyle(
          color: color, fontWeight: FontWeight.bold,
          fontSize: 10, letterSpacing: 0.4));
}

class _Heading extends StatelessWidget {
  final String value;
  const _Heading(this.value);
  @override
  Widget build(BuildContext context) =>
      Text(value, style: const TextStyle(
          fontSize: 11, letterSpacing: 0.4,
          fontWeight: FontWeight.w700, color: Color(0xFFE9EDF7)));
}
