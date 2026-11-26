import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

import '../core/models/app_shortcut_model.dart';
import '../core/models/note_model.dart';
import '../core/models/schedule_model.dart';
import '../core/providers/app_providers.dart';
import 'mobile_optimizations.dart';
import 'mobile_optimizer_page.dart';

const mobileBackground = Color(0xFF081423);
const mobileSidebar = Color(0xFF0B1525);
const mobileCard = Color(0xFF101E2F);
const mobileBorder = Color(0xFF233145);
const mobileMuted = Color(0xFF9CA9BD);
const mobilePurple = Color(0xFF9685FF);
const mobileGreen = Color(0xFF38CB74);

class LaunchDeskMobileApp extends StatelessWidget {
  const LaunchDeskMobileApp({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(
      seedColor: mobilePurple,
      brightness: Brightness.dark,
      surface: mobileCard,
    );
    return MaterialApp(
      title: 'LaunchDesk',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: scheme,
        scaffoldBackgroundColor: mobileBackground,
        appBarTheme: const AppBarTheme(
          backgroundColor: mobileSidebar,
          foregroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      home: const _MobileShell(),
    );
  }
}

class _MobileShell extends ConsumerStatefulWidget {
  const _MobileShell();

  @override
  ConsumerState<_MobileShell> createState() => _MobileShellState();
}

class _MobileShellState extends ConsumerState<_MobileShell> {
  static const _labels = [
    'Dashboard', 'Schedule', 'Tasks', 'Notes', 'Apps', 'Focus Timer',
    'Habits', 'Journal', 'Settings', 'ChatGPT', 'Widgets', 'Optimizer',
  ];
  static const _icons = [
    Icons.dashboard_outlined, Icons.calendar_month_outlined,
    Icons.check_circle_outline, Icons.edit_note, Icons.apps,
    Icons.timer_outlined, Icons.favorite_border, Icons.book_outlined,
    Icons.settings_outlined, Icons.chat_outlined, Icons.widgets_outlined,
    Icons.speed_outlined,
  ];
  static const _bottomPages = [0, 2, 4, 11];

  int _page = 0;
  int _focusSeconds = 25 * 60;
  bool _focusRunning = false;
  Timer? _focusTicker;
  List<String> _habits = [];
  List<String> _doneHabits = [];

  @override
  void initState() {
    super.initState();
    _focusTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || !_focusRunning) return;
      setState(() {
        if (_focusSeconds > 0) _focusSeconds--;
        if (_focusSeconds == 0) _focusRunning = false;
      });
    });
    _loadHabits();
  }

  @override
  void dispose() {
    _focusTicker?.cancel();
    super.dispose();
  }

  String get _dayKey =>
      'launchdesk_habits_' + DateFormat('yyyy-MM-dd').format(DateTime.now());

  Future<void> _loadHabits() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _habits = prefs.getStringList('launchdesk_habits') ?? [];
      _doneHabits = prefs.getStringList(_dayKey) ?? [];
    });
  }

  Future<void> _addHabit() async {
    final value = await _askText('New habit', 'Habit name');
    if (value == null || value.isEmpty || _habits.contains(value)) return;
    setState(() => _habits = [..._habits, value]);
    (await SharedPreferences.getInstance())
        .setStringList('launchdesk_habits', _habits);
  }

  Future<void> _toggleHabit(String habit) async {
    setState(() {
      _doneHabits = _doneHabits.contains(habit)
          ? _doneHabits.where((h) => h != habit).toList()
          : [..._doneHabits, habit];
    });
    (await SharedPreferences.getInstance())
        .setStringList(_dayKey, _doneHabits);
  }

  Future<String?> _askText(String title, String label,
      {String initial = ''}) async {
    final controller = TextEditingController(text: initial);
    try {
      return await showDialog<String>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(labelText: label),
            onSubmitted: (_) =>
                Navigator.pop(dialogContext, controller.text.trim()),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, controller.text.trim()),
              child: const Text('Save'),
            ),
          ],
        ),
      );
    } finally {
      controller.dispose();
    }
  }

  void _message(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _addTask() async {
    final text = await _askText('Add task', 'What needs doing?');
    if (text == null || text.isEmpty) return;
    await ref.read(todoProvider.notifier)
        .add(TodoItem(id: const Uuid().v4(), text: text));
  }

  Future<void> _editNote({Note? existing, bool journal = false}) async {
    final titleController = TextEditingController(text: existing?.title ?? '');
    final bodyController = TextEditingController(text: existing?.content ?? '');
    try {
      final result = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(existing == null ? 'New entry' : 'Edit entry'),
          content: SizedBox(
            width: 460,
            child: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                  autofocus: true,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: bodyController,
                  decoration: const InputDecoration(labelText: 'Content'),
                  maxLines: 6,
                  minLines: 3,
                ),
              ]),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Save'),
            ),
          ],
        ),
      );
      if (result != true || titleController.text.trim().isEmpty) return;
      final now = DateTime.now();
      if (existing == null) {
        await ref.read(notesProvider.notifier).add(Note(
          id: const Uuid().v4(),
          title: titleController.text.trim(),
          content: bodyController.text.trim(),
          tags: journal ? ['journal'] : [],
          createdAt: now,
          updatedAt: now,
        ));
      } else {
        await ref.read(notesProvider.notifier).update(existing.copyWith(
          title: titleController.text.trim(),
          content: bodyController.text.trim(),
        ));
      }
    } finally {
      titleController.dispose();
      bodyController.dispose();
    }
  }

  Future<void> _addSchedule() async {
    final title = await _askText('New schedule', 'Schedule title');
    if (title == null || title.isEmpty || !mounted) return;
    final day = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (day == null || !mounted) return;
    final start = await showTimePicker(
      context: context, initialTime: TimeOfDay.now(),
    );
    if (start == null || !mounted) return;
    final finish = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(DateTime(
        day.year, day.month, day.day, start.hour + 1, start.minute,
      )),
    );
    if (finish == null) return;
    final startDate = DateTime(
      day.year, day.month, day.day, start.hour, start.minute,
    );
    final endDate = DateTime(
      day.year, day.month, day.day, finish.hour, finish.minute,
    );
    if (!endDate.isAfter(startDate)) {
      _message('End time must be after start time.');
      return;
    }
    await ref.read(scheduleProvider.notifier).add(Schedule(
      id: const Uuid().v4(),
      title: title,
      startTime: startDate,
      endTime: endDate,
      enableNotification: false, // Background scheduling is not implemented.
      createdAt: DateTime.now(),
    ));
  }

  Future<void> _pinInstalledApp(InstalledMobileApp app) async {
    final existing = ref.read(launcherProvider).shortcuts;
    if (existing.any((item) =>
        item.type == ShortcutType.app && item.target == app.packageName)) {
      _message('Already in your launcher');
      return;
    }
    await ref.read(launcherProvider.notifier).addShortcut(AppShortcut(
      id: const Uuid().v4(),
      name: app.name,
      type: ShortcutType.app,
      target: app.packageName,
      isPinned: true,
      createdAt: DateTime.now(),
    ));
    if (mounted) _message(app.name + ' added');
  }

  Future<void> _chooseInstalledApp() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: mobileSidebar,
      builder: (sheetContext) => SafeArea(
        child: FractionallySizedBox(
          heightFactor: 0.78,
          child: Column(children: [
            const Padding(
              padding: EdgeInsets.all(18),
              child: Text('Add installed app',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: FutureBuilder<List<InstalledMobileApp>>(
                future: MobileOptimizationService.instance.installedApps(),
                builder: (_, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final apps = snapshot.data!;
                  if (apps.isEmpty) {
                    return const Center(
                      child: Text('No launchable apps were found.'),
                    );
                  }
                  return ListView.builder(
                    itemCount: apps.length,
                    itemBuilder: (_, index) {
                      final app = apps[index];
                      return ListTile(
                        leading: const Icon(Icons.apps, color: mobilePurple),
                        title: Text(app.name),
                        subtitle: Text(app.packageName,
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                        trailing: const Icon(Icons.add_circle_outline),
                        onTap: () async {
                          Navigator.pop(sheetContext);
                          await _pinInstalledApp(app);
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Future<void> _addWebShortcut() async {
    final name = await _askText('Add website', 'Name');
    if (name == null || name.isEmpty || !mounted) return;
    final address = await _askText('Website address', 'https://example.com');
    if (address == null || address.isEmpty) return;
    final uri = Uri.tryParse(address);
    if (uri == null || !uri.hasAuthority ||
        (uri.scheme != 'https' && uri.scheme != 'http')) {
      _message('Enter a valid http:// or https:// URL.');
      return;
    }
    await ref.read(launcherProvider.notifier).addShortcut(AppShortcut(
      id: const Uuid().v4(),
      name: name,
      type: ShortcutType.website,
      target: uri.toString(),
      createdAt: DateTime.now(),
    ));
  }

  Future<void> _openChatGpt() async {
    final success = await launchUrl(Uri.parse('https://chatgpt.com/'),
        mode: LaunchMode.externalApplication);
    if (!success) _message('Could not open your browser.');
  }

  Widget _panel(String title, Widget child, {Widget? trailing}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 13),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: mobileCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: mobileBorder),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(title.toUpperCase(),
              style: const TextStyle(
                color: mobileMuted, fontSize: 11,
                letterSpacing: 1.1, fontWeight: FontWeight.bold,
              ))),
          if (trailing != null) trailing,
        ]),
        const SizedBox(height: 12),
        child,
      ]),
    );
  }

  Widget _dashboard() {
    final tasks = ref.watch(todoProvider);
    final completed = tasks.where((t) => t.isCompleted).length;
    final schedules = ref.watch(scheduleProvider);
    final upcoming = schedules.where((s) =>
        s.isActive && s.startTime.isAfter(DateTime.now())).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
    final notes = ref.watch(notesProvider)
        .where((n) => !n.tags.contains('journal')).toList();
    final name = ref.watch(settingsProvider).asData?.value.username ?? 'User';
    final system = ref.watch(systemInfoProvider).asData?.value;
    final next = upcoming.isEmpty ? null : upcoming.first;
    return ListView(padding: const EdgeInsets.all(16), children: [
      Text('Welcome back, ' + name + ' 👋',
          style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
      const SizedBox(height: 5),
      const Text('Stay focused. Stay consistent.',
          style: TextStyle(color: mobileMuted)),
      const SizedBox(height: 19),
      _panel('Overview', Wrap(spacing: 12, runSpacing: 12, children: [
        _stat('Tasks', completed.toString() + '/' + tasks.length.toString(),
            Icons.check_circle_outline),
        _stat('Notes', notes.length.toString(), Icons.edit_note),
        _stat('Battery',
            system == null ? '—' : system.batteryPercent.toString() + '%',
            Icons.battery_charging_full),
        _stat('Schedules', schedules.length.toString(),
            Icons.calendar_today_outlined),
      ])),
      _panel('Now & next', Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('NEXT SCHEDULE', style: TextStyle(
            color: mobileGreen, fontSize: 11, fontWeight: FontWeight.bold,
          )),
          const SizedBox(height: 8),
          Text(next?.title ?? 'Nothing upcoming',
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 5),
          Text(next == null ? 'Create a schedule to get started'
              : DateFormat('EEE, MMM d • h:mm a').format(next.startTime),
              style: const TextStyle(color: mobileMuted)),
        ],
      ), trailing: IconButton(
        onPressed: () => setState(() => _page = 1),
        icon: const Icon(Icons.arrow_forward),
      )),
      _panel('Quick actions', Wrap(spacing: 8, runSpacing: 8, children: [
        ActionChip(avatar: const Icon(Icons.add, size: 17),
            label: const Text('New task'), onPressed: _addTask),
        ActionChip(avatar: const Icon(Icons.edit_note, size: 17),
            label: const Text('New note'),
            onPressed: () => _editNote()),
        ActionChip(avatar: const Icon(Icons.speed, size: 17),
            label: const Text('Optimizer'),
            onPressed: () => setState(() => _page = 11)),
        ActionChip(avatar: const Icon(Icons.apps, size: 17),
            label: const Text('My apps'),
            onPressed: () => setState(() => _page = 4)),
      ])),
    ]);
  }

  Widget _stat(String name, String value, IconData icon) => SizedBox(
    width: 142,
    child: Row(children: [
      Icon(icon, color: mobilePurple, size: 25),
      const SizedBox(width: 9),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value, style: const TextStyle(
            fontWeight: FontWeight.bold, fontSize: 17)),
        Text(name, style: const TextStyle(color: mobileMuted, fontSize: 11)),
      ]),
    ]),
  );

  Widget _tasks() {
    final tasks = ref.watch(todoProvider);
    return ListView(padding: const EdgeInsets.all(16), children: [
      _panel('Your tasks', Column(children: [
        for (final task in tasks)
          CheckboxListTile(
            value: task.isCompleted,
            controlAffinity: ListTileControlAffinity.leading,
            title: Text(task.text),
            secondary: IconButton(
              tooltip: 'Delete',
              onPressed: () =>
                  ref.read(todoProvider.notifier).remove(task.id),
              icon: const Icon(Icons.delete_outline),
            ),
            onChanged: (_) => ref.read(todoProvider.notifier).toggle(task.id),
          ),
        if (tasks.isEmpty)
          const Padding(
            padding: EdgeInsets.all(12),
            child: Text('Your task list is empty.',
                style: TextStyle(color: mobileMuted)),
          ),
        const SizedBox(height: 8),
        FilledButton.icon(
          onPressed: _addTask,
          icon: const Icon(Icons.add),
          label: const Text('Add task'),
        ),
      ])),
    ]);
  }

  Widget _schedules() {
    final schedules = [...ref.watch(scheduleProvider)]
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
    return ListView(padding: const EdgeInsets.all(16), children: [
      _panel('Schedule', Column(children: [
        for (final schedule in schedules)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.event,
                color: schedule.isActive ? mobilePurple : mobileMuted),
            title: Text(schedule.title),
            subtitle: Text(
              DateFormat('EEE, MMM d • h:mm a').format(schedule.startTime)
                  + ' – ' + DateFormat('h:mm a').format(schedule.endTime),
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (selection) {
                if (selection == 'delete') {
                  ref.read(scheduleProvider.notifier).remove(schedule.id);
                } else {
                  ref.read(scheduleProvider.notifier)
                      .toggle(schedule.id, !schedule.isActive);
                }
              },
              itemBuilder: (_) => [
                PopupMenuItem(value: 'toggle', child: Text(
                    schedule.isActive ? 'Disable' : 'Enable')),
                const PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          ),
        if (schedules.isEmpty)
          const Text('No schedules yet.',
              style: TextStyle(color: mobileMuted)),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: _addSchedule,
          icon: const Icon(Icons.add),
          label: const Text('New schedule'),
        ),
        const SizedBox(height: 12),
        const Text('Background schedule alerts are not yet supported on Android.',
            style: TextStyle(color: mobileMuted, fontSize: 11)),
      ])),
    ]);
  }

  Widget _notes({bool journal = false}) {
    final notes = ref.watch(notesProvider)
        .where((note) => note.tags.contains('journal') == journal)
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return ListView(padding: const EdgeInsets.all(16), children: [
      _panel(journal ? 'Journal' : 'Notes', Column(children: [
        for (final note in notes)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              journal ? Icons.book_outlined : Icons.description_outlined,
              color: mobilePurple,
            ),
            title: Text(note.title),
            subtitle: Text(note.content,
                maxLines: 2, overflow: TextOverflow.ellipsis),
            onTap: () => _editNote(existing: note, journal: journal),
            trailing: IconButton(
              tooltip: 'Delete',
              icon: const Icon(Icons.delete_outline),
              onPressed: () => ref.read(notesProvider.notifier).remove(note.id),
            ),
          ),
        if (notes.isEmpty)
          const Text('No entries yet.',
              style: TextStyle(color: mobileMuted)),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: () => _editNote(journal: journal),
          icon: const Icon(Icons.add),
          label: Text(journal ? 'New journal entry' : 'New note'),
        ),
      ])),
    ]);
  }

  Widget _apps() {
    final shortcuts = ref.watch(launcherProvider).shortcuts;
    return ListView(padding: const EdgeInsets.all(16), children: [
      _panel('Quick launch', Column(children: [
        for (final shortcut in shortcuts)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(shortcut.type == ShortcutType.app
                ? Icons.android : Icons.language, color: mobilePurple),
            title: Text(shortcut.name),
            subtitle: Text(shortcut.target,
                maxLines: 1, overflow: TextOverflow.ellipsis),
            onTap: () async {
              final success =
                  await ref.read(launcherServiceProvider).launch(shortcut);
              if (!success) _message('App or link could not be opened.');
            },
            trailing: IconButton(
              tooltip: 'Remove shortcut',
              icon: const Icon(Icons.remove_circle_outline),
              onPressed: () => ref.read(launcherProvider.notifier)
                  .removeShortcut(shortcut.id),
            ),
          ),
        if (shortcuts.isEmpty)
          const Text('Pin a phone app or a website.',
              style: TextStyle(color: mobileMuted)),
        const SizedBox(height: 12),
        Wrap(spacing: 10, runSpacing: 10, children: [
          FilledButton.icon(
            onPressed: _chooseInstalledApp,
            icon: const Icon(Icons.apps),
            label: const Text('Add installed app'),
          ),
          OutlinedButton.icon(
            onPressed: _addWebShortcut,
            icon: const Icon(Icons.language),
            label: const Text('Add website'),
          ),
        ]),
      ])),
      const Text('App shortcuts are saved locally. Android may limit '
          'visibility of some installed apps.',
          style: TextStyle(color: mobileMuted, fontSize: 12)),
    ]);
  }

  Widget _focusTimer() {
    final mins = (_focusSeconds ~/ 60).toString().padLeft(2, '0');
    final secs = (_focusSeconds % 60).toString().padLeft(2, '0');
    return ListView(padding: const EdgeInsets.all(16), children: [
      _panel('Focus timer', Column(children: [
        const SizedBox(height: 20),
        CircularProgressIndicator(
          value: _focusSeconds / (25 * 60),
          strokeWidth: 8,
          strokeCap: StrokeCap.round,
        ),
        const SizedBox(height: 22),
        Text(mins + ':' + secs,
            style: const TextStyle(fontSize: 48,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          FilledButton(
            onPressed: () => setState(
                () => _focusRunning = !_focusRunning),
            child: Text(_focusRunning ? 'Pause' : 'Start'),
          ),
          const SizedBox(width: 12),
          OutlinedButton(
            onPressed: () => setState(() {
              _focusSeconds = 25 * 60;
              _focusRunning = false;
            }),
            child: const Text('Reset'),
          ),
        ]),
        const SizedBox(height: 12),
        const Text('Timer runs while LaunchDesk remains active.',
            style: TextStyle(color: mobileMuted)),
      ])),
    ]);
  }

  Widget _habitsPage() => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      _panel('Daily habits', Column(children: [
        for (final habit in _habits)
          CheckboxListTile(
            title: Text(habit),
            value: _doneHabits.contains(habit),
            onChanged: (_) => _toggleHabit(habit),
          ),
        if (_habits.isEmpty)
          const Text('Add a habit to track each day.',
              style: TextStyle(color: mobileMuted)),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: _addHabit,
          icon: const Icon(Icons.add),
          label: const Text('New habit'),
        ),
      ])),
    ],
  );

  Widget _settings() {
    final name = ref.watch(settingsProvider).asData?.value.username ?? 'User';
    return ListView(padding: const EdgeInsets.all(16), children: [
      _panel('Profile', Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Signed in locally as ' + name),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () async {
              final value = await _askText(
                  'Display name', 'Your name', initial: name);
              if (value == null || value.isEmpty) return;
              await ref.read(settingsServiceProvider)
                  .updateSetting('username', value);
              ref.invalidate(settingsProvider);
            },
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Change display name'),
          ),
        ],
      )),
      _panel('About this build', const Text(
          'LaunchDesk Android uses the same local task, note, schedule and '
          'shortcut models as LaunchDesk Windows. Device data stays on this '
          'phone, with no automatic syncing to your PC.\n\n'
          'Android does not permit third-party apps to boost other apps, '
          'force higher FPS or delete another app’s cache.',
          style: TextStyle(height: 1.5))),
    ]);
  }

  Widget _chatGpt() => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      _panel('ChatGPT', Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Open the official ChatGPT website in your browser. '
              'LaunchDesk does not collect your login details.'),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: _openChatGpt,
            icon: const Icon(Icons.open_in_new),
            label: const Text('Open ChatGPT'),
          ),
        ],
      )),
    ],
  );

  Widget _widgetsPage() {
    final tasks = ref.watch(todoProvider);
    final notes = ref.watch(notesProvider);
    return ListView(padding: const EdgeInsets.all(16), children: [
      _panel('Clock', Text(DateFormat('EEEE, MMM d • h:mm a')
          .format(DateTime.now()), style: const TextStyle(fontSize: 18))),
      _panel('Tasks', Text(tasks.where((t) => t.isCompleted).length.toString()
          + ' of ' + tasks.length.toString() + ' done')),
      _panel('Notes', Text(notes.length.toString() + ' saved entries')),
      const Text('Mobile widgets currently live inside LaunchDesk. '
          'Home-screen widgets are not yet implemented.',
          style: TextStyle(color: mobileMuted)),
    ]);
  }

  Widget _content() => switch (_page) {
    0 => _dashboard(),
    1 => _schedules(),
    2 => _tasks(),
    3 => _notes(),
    4 => _apps(),
    5 => _focusTimer(),
    6 => _habitsPage(),
    7 => _notes(journal: true),
    8 => _settings(),
    9 => _chatGpt(),
    10 => _widgetsPage(),
    11 => const MobileOptimizerPage(),
    _ => _dashboard(),
  };

  @override
  Widget build(BuildContext context) {
    final selectedBottom = _bottomPages.indexOf(_page);
    return Scaffold(
      appBar: AppBar(
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('LaunchDesk', style: TextStyle(
            color: mobilePurple, fontWeight: FontWeight.bold, fontSize: 20)),
          Text(_labels[_page], style: const TextStyle(
            color: mobileMuted, fontSize: 11)),
        ]),
        actions: [
          IconButton(
            tooltip: 'Device optimizer',
            onPressed: () => setState(() => _page = 11),
            icon: const Icon(Icons.speed_outlined, color: mobilePurple),
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: mobileSidebar,
        child: SafeArea(child: Column(children: [
          const ListTile(
            title: Text('LaunchDesk', style: TextStyle(
              color: mobilePurple, fontSize: 23,
              fontWeight: FontWeight.bold)),
            subtitle: Text('Your mobile workspace'),
          ),
          const Divider(color: mobileBorder),
          Expanded(child: ListView.builder(
            itemCount: _labels.length,
            itemBuilder: (context, index) => ListTile(
              dense: true,
              selected: index == _page,
              selectedColor: mobilePurple,
              leading: Icon(_icons[index], size: 21),
              title: Text(_labels[index]),
              onTap: () {
                Navigator.pop(context);
                setState(() => _page = index);
              },
            ),
          )),
        ])),
      ),
      body: _content(),
      bottomNavigationBar: NavigationBar(
        backgroundColor: mobileSidebar,
        selectedIndex: selectedBottom < 0 ? 0 : selectedBottom,
        onDestinationSelected: (index) =>
            setState(() => _page = _bottomPages[index]),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.dashboard_outlined), label: 'Home'),
          NavigationDestination(
              icon: Icon(Icons.check_circle_outline), label: 'Tasks'),
          NavigationDestination(icon: Icon(Icons.apps), label: 'Apps'),
          NavigationDestination(
              icon: Icon(Icons.speed_outlined), label: 'Optimize'),
        ],
      ),
    );
  }
}
