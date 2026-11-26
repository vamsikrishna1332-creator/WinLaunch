import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/settings_model.dart';
import '../models/theme_model.dart';
import '../models/schedule_model.dart';
import '../models/app_shortcut_model.dart';
import '../models/widget_config_model.dart';
import '../models/note_model.dart';
import '../services/settings_service.dart';
import '../services/theme_service.dart';
import '../services/schedule_service.dart';
import '../services/launcher_service.dart';
import '../services/widget_service.dart';
import '../services/system_info_service.dart';
import '../services/note_service.dart';
export '../services/system_info_service.dart' show SystemSnapshot;

// ─── Services (singletons) ────────────────────────────────────────────────────

final settingsServiceProvider = Provider<SettingsService>((ref) {
  return SettingsService();
});

final themeServiceProvider = Provider<ThemeService>((ref) => ThemeService());

final scheduleServiceProvider =
    Provider<ScheduleService>((ref) => ScheduleService());

final launcherServiceProvider =
    Provider<LauncherService>((ref) => LauncherService());

final widgetServiceProvider =
    Provider<WidgetService>((ref) => WidgetService());

final systemInfoServiceProvider =
    Provider<SystemInfoService>((ref) {
  final svc = SystemInfoService();
  ref.onDispose(svc.dispose);
  return svc;
});

final noteServiceProvider = Provider<NoteService>((ref) => NoteService());

// ─── Settings ────────────────────────────────────────────────────────────────

final settingsProvider = FutureProvider<AppSettings>((ref) async {
  return ref.read(settingsServiceProvider).loadSettings();
});

// ─── Theme ───────────────────────────────────────────────────────────────────

class ThemeNotifier extends StateNotifier<LaunchDeskTheme> {
  final ThemeService _svc;
  ThemeNotifier(this._svc) : super(LaunchDeskTheme.defaultDark);

  Future<void> load(String themeId) async {
    final theme = await _svc.loadTheme(themeId);
    if (theme != null) state = theme;
  }

  Future<void> applyTheme(LaunchDeskTheme theme) async {
    state = theme;
    await _svc.saveTheme(theme);
  }

  Future<void> updateProperty(LaunchDeskTheme Function(LaunchDeskTheme) updater) async {
    state = updater(state);
    await _svc.saveTheme(state);
  }
}

final themeProvider =
    StateNotifierProvider<ThemeNotifier, LaunchDeskTheme>((ref) {
  return ThemeNotifier(ref.read(themeServiceProvider));
});

final allThemesProvider = FutureProvider<List<LaunchDeskTheme>>((ref) async {
  return ref.read(themeServiceProvider).loadThemes();
});

// ─── Schedules ────────────────────────────────────────────────────────────────

class ScheduleNotifier extends StateNotifier<List<Schedule>> {
  final ScheduleService _svc;
  String _profileId;

  ScheduleNotifier(this._svc, this._profileId) : super([]) {
    load();
  }

  Future<void> load() async {
    state = await _svc.loadSchedules(profileId: _profileId);
  }

  Schedule? get current {
    for (final s in state) {
      if (s.isActive && s.isRunning) return s;
    }
    return null;
  }

  Schedule? get next {
    final now = DateTime.now();
    Schedule? result;
    for (final s in state) {
      if (!s.isActive) continue;
      if (s.startTime.isAfter(now)) {
        if (result == null || s.startTime.isBefore(result.startTime)) {
          result = s;
        }
      }
    }
    return result;
  }

  Future<void> add(Schedule s) async {
    final saved = await _svc.addSchedule(s);
    state = [...state, saved];
  }

  Future<void> update(Schedule s) async {
    await _svc.updateSchedule(s);
    state = state.map((e) => e.id == s.id ? s : e).toList();
  }

  Future<void> remove(String id) async {
    await _svc.deleteSchedule(id);
    state = state.where((e) => e.id != id).toList();
  }

  Future<void> toggle(String id, bool active) async {
    await _svc.toggleActive(id, active);
    state = state
        .map((e) => e.id == id ? e.copyWith(isActive: active) : e)
        .toList();
  }
}

final scheduleProvider =
    StateNotifierProvider<ScheduleNotifier, List<Schedule>>((ref) {
  return ScheduleNotifier(ref.read(scheduleServiceProvider), 'default');
});

// ─── Launcher ────────────────────────────────────────────────────────────────

class LauncherNotifier extends StateNotifier<LauncherState> {
  final LauncherService _svc;

  LauncherNotifier(this._svc) : super(const LauncherState()) {
    load();
  }

  Future<void> load() async {
    final shortcuts = await _svc.loadShortcuts();
    final groups = await _svc.loadGroups();
    state = state.copyWith(shortcuts: shortcuts, groups: groups);
  }

  Future<void> addShortcut(AppShortcut s) async {
    final saved = await _svc.addShortcut(s);
    state = state.copyWith(shortcuts: [...state.shortcuts, saved]);
  }

  Future<void> updateShortcut(AppShortcut s) async {
    await _svc.updateShortcut(s);
    state = state.copyWith(
        shortcuts: state.shortcuts.map((e) => e.id == s.id ? s : e).toList());
  }

  Future<void> removeShortcut(String id) async {
    await _svc.deleteShortcut(id);
    state = state.copyWith(
        shortcuts: state.shortcuts.where((e) => e.id != id).toList());
  }

  Future<void> addGroup(ShortcutGroup g) async {
    final saved = await _svc.addGroup(g);
    state = state.copyWith(groups: [...state.groups, saved]);
  }

  Future<void> removeGroup(String id) async {
    await _svc.deleteGroup(id);
    state = state.copyWith(
        groups: state.groups.where((e) => e.id != id).toList());
  }

  Future<void> launch(AppShortcut s) => _svc.launch(s);

  void setSearch(String query) => state = state.copyWith(searchQuery: query);
  void setCategory(String? cat) => state = state.copyWith(selectedCategory: cat);
}

class LauncherState {
  final List<AppShortcut> shortcuts;
  final List<ShortcutGroup> groups;
  final String searchQuery;
  final String? selectedCategory;

  const LauncherState({
    this.shortcuts = const [],
    this.groups = const [],
    this.searchQuery = '',
    this.selectedCategory,
  });

  List<AppShortcut> get filtered {
    var list = shortcuts;
    if (searchQuery.isNotEmpty) {
      list = list
          .where((s) =>
              s.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
              (s.description?.toLowerCase().contains(searchQuery.toLowerCase()) ?? false))
          .toList();
    }
    if (selectedCategory != null) {
      list = list.where((s) => s.category == selectedCategory).toList();
    }
    // Pinned first, then favorites, then rest
    final pinned = list.where((s) => s.isPinned).toList();
    final favorites = list.where((s) => s.isFavorite && !s.isPinned).toList();
    final rest = list.where((s) => !s.isFavorite && !s.isPinned).toList();
    return [...pinned, ...favorites, ...rest];
  }

  List<String> get categories {
    return shortcuts
        .map((s) => s.category)
        .whereType<String>()
        .toSet()
        .toList()
      ..sort();
  }

  LauncherState copyWith({
    List<AppShortcut>? shortcuts,
    List<ShortcutGroup>? groups,
    String? searchQuery,
    String? selectedCategory,
  }) {
    return LauncherState(
      shortcuts: shortcuts ?? this.shortcuts,
      groups: groups ?? this.groups,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
    );
  }
}

final launcherProvider =
    StateNotifierProvider<LauncherNotifier, LauncherState>((ref) {
  return LauncherNotifier(ref.read(launcherServiceProvider));
});

// ─── Widgets ──────────────────────────────────────────────────────────────────

class WidgetBoardNotifier extends StateNotifier<List<WidgetConfig>> {
  final WidgetService _svc;

  WidgetBoardNotifier(this._svc) : super([]) {
    load();
  }

  Future<void> load() async {
    state = await _svc.loadWidgets();
  }

  Future<void> addWidget(WidgetType type) async {
    final w = await _svc.addWidget(type);
    state = [...state, w];
  }

  Future<void> updatePosition(String id, double x, double y) async {
    await _svc.updatePosition(id, x, y);
    state = state.map((w) => w.id == id ? w.copyWith(x: x, y: y) : w).toList();
  }

  Future<void> updateSize(String id, double width, double height) async {
    await _svc.updateSize(id, width, height);
    state = state
        .map((w) => w.id == id ? w.copyWith(width: width, height: height) : w)
        .toList();
  }

  Future<void> toggleVisibility(String id) async {
    final widget = state.firstWhere((w) => w.id == id);
    await _svc.toggleVisibility(id, !widget.isVisible);
    state = state
        .map((w) =>
            w.id == id ? w.copyWith(isVisible: !w.isVisible) : w)
        .toList();
  }

  Future<void> removeWidget(String id) async {
    await _svc.deleteWidget(id);
    state = state.where((w) => w.id != id).toList();
  }

  Future<void> updateSettings(String id, Map<String, dynamic> settings) async {
    await _svc.updateSettings(id, settings);
    state = state
        .map((w) => w.id == id ? w.copyWith(settings: settings) : w)
        .toList();
  }
}

final widgetBoardProvider =
    StateNotifierProvider<WidgetBoardNotifier, List<WidgetConfig>>((ref) {
  return WidgetBoardNotifier(ref.read(widgetServiceProvider));
});

// ─── System info ─────────────────────────────────────────────────────────────

final systemInfoProvider = StreamProvider<SystemSnapshot>((ref) {
  return ref.read(systemInfoServiceProvider).stream;
});

// ─── Notes / Todo ─────────────────────────────────────────────────────────────

class NotesNotifier extends StateNotifier<List<Note>> {
  final NoteService _svc;
  NotesNotifier(this._svc) : super([]) { load(); }

  Future<void> load() async { state = await _svc.loadNotes(); }

  Future<void> add(Note note) async {
    final saved = await _svc.addNote(note);
    state = [saved, ...state];
  }

  Future<void> update(Note note) async {
    await _svc.updateNote(note);
    state = state.map((n) => n.id == note.id ? note : n).toList();
  }

  Future<void> remove(String id) async {
    await _svc.deleteNote(id);
    state = state.where((n) => n.id != id).toList();
  }
}

final notesProvider = StateNotifierProvider<NotesNotifier, List<Note>>((ref) {
  return NotesNotifier(ref.read(noteServiceProvider));
});

class TodoNotifier extends StateNotifier<List<TodoItem>> {
  final NoteService _svc;
  TodoNotifier(this._svc) : super([]) { load(); }

  Future<void> load() async { state = await _svc.loadTodos(); }

  Future<void> add(TodoItem item) async {
    final saved = await _svc.addTodo(item);
    state = [...state, saved];
  }

  Future<void> toggle(String id) async {
    final item = state.firstWhere((t) => t.id == id);
    final updated = item.copyWith(isCompleted: !item.isCompleted);
    await _svc.updateTodo(updated);
    state = state.map((t) => t.id == id ? updated : t).toList();
  }

  Future<void> remove(String id) async {
    await _svc.deleteTodo(id);
    state = state.where((t) => t.id != id).toList();
  }
}

final todoProvider = StateNotifierProvider<TodoNotifier, List<TodoItem>>((ref) {
  return TodoNotifier(ref.read(noteServiceProvider));
});

