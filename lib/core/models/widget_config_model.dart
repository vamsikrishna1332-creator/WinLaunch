class WidgetConfig {
  final String id;
  final WidgetType type;
  final String title;
  final bool isVisible;
  final double x;
  final double y;
  final double width;
  final double height;
  final int sortOrder;
  final Map<String, dynamic> settings;
  final String profileId;
  final DateTime createdAt;

  const WidgetConfig({
    required this.id,
    required this.type,
    this.title = '',
    this.isVisible = true,
    this.x = 0,
    this.y = 0,
    this.width = 200,
    this.height = 150,
    this.sortOrder = 0,
    this.settings = const {},
    this.profileId = 'default',
    required this.createdAt,
  });

  WidgetConfig copyWith({
    String? title,
    bool? isVisible,
    double? x,
    double? y,
    double? width,
    double? height,
    int? sortOrder,
    Map<String, dynamic>? settings,
  }) {
    return WidgetConfig(
      id: id,
      type: type,
      title: title ?? this.title,
      isVisible: isVisible ?? this.isVisible,
      x: x ?? this.x,
      y: y ?? this.y,
      width: width ?? this.width,
      height: height ?? this.height,
      sortOrder: sortOrder ?? this.sortOrder,
      settings: settings ?? this.settings,
      profileId: profileId,
      createdAt: createdAt,
    );
  }

  factory WidgetConfig.fromJson(Map<String, dynamic> json) => WidgetConfig(
        id: json['id'],
        type: WidgetType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => WidgetType.clock,
        ),
        title: json['title'] ?? '',
        isVisible: json['isVisible'] ?? true,
        x: (json['x'] ?? 0).toDouble(),
        y: (json['y'] ?? 0).toDouble(),
        width: (json['width'] ?? 200).toDouble(),
        height: (json['height'] ?? 150).toDouble(),
        sortOrder: json['sortOrder'] ?? 0,
        settings: Map<String, dynamic>.from(json['settings'] ?? {}),
        profileId: json['profileId'] ?? 'default',
        createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'title': title,
        'isVisible': isVisible,
        'x': x,
        'y': y,
        'width': width,
        'height': height,
        'sortOrder': sortOrder,
        'settings': settings,
        'profileId': profileId,
        'createdAt': createdAt.toIso8601String(),
      };
}

enum WidgetType {
  clock,
  calendar,
  notes,
  weather,
  battery,
  ram,
  cpu,
  spotify,
  todo,
  pomodoro,
  calculator,
  recentFiles,
  recentApps,
  taskCounter,
  customHtml,
  image,
  gif,
  video,
  quote,
  shortcutGrid,
  diskUsage,
  networkSpeed,
  scheduleWidget,
  countdown,
  stats,
}

extension WidgetTypeExt on WidgetType {
  String get label {
    switch (this) {
      case WidgetType.clock: return 'Clock';
      case WidgetType.calendar: return 'Calendar';
      case WidgetType.notes: return 'Notes';
      case WidgetType.weather: return 'Weather';
      case WidgetType.battery: return 'Battery';
      case WidgetType.ram: return 'RAM Monitor';
      case WidgetType.cpu: return 'CPU Monitor';
      case WidgetType.spotify: return 'Spotify';
      case WidgetType.todo: return 'To-Do List';
      case WidgetType.pomodoro: return 'Pomodoro Timer';
      case WidgetType.calculator: return 'Calculator';
      case WidgetType.recentFiles: return 'Recent Files';
      case WidgetType.recentApps: return 'Recent Apps';
      case WidgetType.taskCounter: return 'Task Counter';
      case WidgetType.customHtml: return 'Custom HTML';
      case WidgetType.image: return 'Image';
      case WidgetType.gif: return 'GIF';
      case WidgetType.video: return 'Video';
      case WidgetType.quote: return 'Quote';
      case WidgetType.shortcutGrid: return 'Shortcut Grid';
      case WidgetType.diskUsage: return 'Disk Usage';
      case WidgetType.networkSpeed: return 'Network Speed';
      case WidgetType.scheduleWidget: return 'Schedule';
      case WidgetType.countdown: return 'Countdown';
      case WidgetType.stats: return 'Statistics';
    }
  }

  String get icon {
    switch (this) {
      case WidgetType.clock: return '🕐';
      case WidgetType.calendar: return '📅';
      case WidgetType.notes: return '📝';
      case WidgetType.weather: return '🌤️';
      case WidgetType.battery: return '🔋';
      case WidgetType.ram: return '💾';
      case WidgetType.cpu: return '⚙️';
      case WidgetType.spotify: return '🎵';
      case WidgetType.todo: return '✅';
      case WidgetType.pomodoro: return '🍅';
      case WidgetType.calculator: return '🔢';
      case WidgetType.recentFiles: return '📂';
      case WidgetType.recentApps: return '🖥️';
      case WidgetType.taskCounter: return '📊';
      case WidgetType.customHtml: return '🌐';
      case WidgetType.image: return '🖼️';
      case WidgetType.gif: return '🎞️';
      case WidgetType.video: return '📹';
      case WidgetType.quote: return '💬';
      case WidgetType.shortcutGrid: return '⚡';
      case WidgetType.diskUsage: return '💿';
      case WidgetType.networkSpeed: return '📡';
      case WidgetType.scheduleWidget: return '📋';
      case WidgetType.countdown: return '⏳';
      case WidgetType.stats: return '📈';
    }
  }

  WidgetConfig get defaultConfig {
    final now = DateTime.now();
    switch (this) {
      case WidgetType.clock:
        return WidgetConfig(id: '', type: this, title: 'Clock',
            width: 220, height: 140, settings: {'showSeconds': true, 'format': '24h'}, createdAt: now);
      case WidgetType.calendar:
        return WidgetConfig(id: '', type: this, title: 'Calendar',
            width: 300, height: 280, createdAt: now);
      case WidgetType.notes:
        return WidgetConfig(id: '', type: this, title: 'Quick Notes',
            width: 280, height: 220, createdAt: now);
      case WidgetType.cpu:
        return WidgetConfig(id: '', type: this, title: 'CPU',
            width: 200, height: 120, settings: {'showGraph': true}, createdAt: now);
      case WidgetType.ram:
        return WidgetConfig(id: '', type: this, title: 'RAM',
            width: 200, height: 120, settings: {'showGraph': true}, createdAt: now);
      case WidgetType.todo:
        return WidgetConfig(id: '', type: this, title: 'To-Do',
            width: 280, height: 300, createdAt: now);
      case WidgetType.pomodoro:
        return WidgetConfig(id: '', type: this, title: 'Pomodoro',
            width: 240, height: 200, settings: {'workMinutes': 25, 'breakMinutes': 5}, createdAt: now);
      case WidgetType.quote:
        return WidgetConfig(id: '', type: this, title: 'Quote of the Day',
            width: 320, height: 150, createdAt: now);
      default:
        return WidgetConfig(id: '', type: this, title: label,
            width: 240, height: 180, createdAt: now);
    }
  }
}
