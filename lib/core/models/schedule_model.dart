class Schedule {
  final String id;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final RepeatType repeat;
  final List<int> repeatDays; // 1=Mon..7=Sun
  final int color;
  final Priority priority;
  final String icon;
  final bool enableNotification;
  final int notifyMinutesBefore;
  final ScheduleStatus status;
  final bool isActive;
  final String profileId;
  final DateTime createdAt;

  const Schedule({
    required this.id,
    required this.title,
    this.description = '',
    required this.startTime,
    required this.endTime,
    this.repeat = RepeatType.none,
    this.repeatDays = const [],
    this.color = 0xFF0078D4,
    this.priority = Priority.medium,
    this.icon = 'calendar',
    this.enableNotification = true,
    this.notifyMinutesBefore = 5,
    this.status = ScheduleStatus.upcoming,
    this.isActive = true,
    this.profileId = 'default',
    required this.createdAt,
  });

  Duration get duration => endTime.difference(startTime);

  bool get isRunning {
    final now = DateTime.now();
    return now.isAfter(startTime) && now.isBefore(endTime);
  }

  double get progress {
    if (!isRunning) return 0.0;
    final now = DateTime.now();
    final elapsed = now.difference(startTime).inSeconds;
    final total = duration.inSeconds;
    return total > 0 ? (elapsed / total).clamp(0.0, 1.0) : 0.0;
  }

  Duration get timeRemaining {
    final now = DateTime.now();
    if (now.isAfter(endTime)) return Duration.zero;
    return endTime.difference(now);
  }

  bool occursOn(DateTime date) {
    switch (repeat) {
      case RepeatType.none:
        return startTime.day == date.day &&
            startTime.month == date.month &&
            startTime.year == date.year;
      case RepeatType.daily:
        return date.isAfter(startTime.subtract(const Duration(days: 1)));
      case RepeatType.weekly:
        return repeatDays.contains(date.weekday) &&
            date.isAfter(startTime.subtract(const Duration(days: 1)));
      case RepeatType.monthly:
        return startTime.day == date.day;
      case RepeatType.yearly:
        return startTime.day == date.day && startTime.month == date.month;
    }
  }

  Schedule copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    RepeatType? repeat,
    List<int>? repeatDays,
    int? color,
    Priority? priority,
    String? icon,
    bool? enableNotification,
    int? notifyMinutesBefore,
    ScheduleStatus? status,
    bool? isActive,
  }) {
    return Schedule(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      repeat: repeat ?? this.repeat,
      repeatDays: repeatDays ?? this.repeatDays,
      color: color ?? this.color,
      priority: priority ?? this.priority,
      icon: icon ?? this.icon,
      enableNotification: enableNotification ?? this.enableNotification,
      notifyMinutesBefore: notifyMinutesBefore ?? this.notifyMinutesBefore,
      status: status ?? this.status,
      isActive: isActive ?? this.isActive,
      profileId: profileId,
      createdAt: createdAt,
    );
  }

  factory Schedule.fromJson(Map<String, dynamic> json) => Schedule(
        id: json['id'],
        title: json['title'],
        description: json['description'] ?? '',
        startTime: DateTime.parse(json['startTime']),
        endTime: DateTime.parse(json['endTime']),
        repeat: RepeatType.values.firstWhere(
          (e) => e.name == json['repeat'],
          orElse: () => RepeatType.none,
        ),
        repeatDays:
            (json['repeatDays'] as List<dynamic>?)?.map((e) => e as int).toList() ?? [],
        color: json['color'] ?? 0xFF0078D4,
        priority: Priority.values.firstWhere(
          (e) => e.name == json['priority'],
          orElse: () => Priority.medium,
        ),
        icon: json['icon'] ?? 'calendar',
        enableNotification: json['enableNotification'] ?? true,
        notifyMinutesBefore: json['notifyMinutesBefore'] ?? 5,
        status: ScheduleStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () => ScheduleStatus.upcoming,
        ),
        isActive: json['isActive'] ?? true,
        profileId: json['profileId'] ?? 'default',
        createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'startTime': startTime.toIso8601String(),
        'endTime': endTime.toIso8601String(),
        'repeat': repeat.name,
        'repeatDays': repeatDays,
        'color': color,
        'priority': priority.name,
        'icon': icon,
        'enableNotification': enableNotification,
        'notifyMinutesBefore': notifyMinutesBefore,
        'status': status.name,
        'isActive': isActive,
        'profileId': profileId,
        'createdAt': createdAt.toIso8601String(),
      };
}

enum RepeatType { none, daily, weekly, monthly, yearly }

enum Priority { low, medium, high, critical }

enum ScheduleStatus { upcoming, running, completed, cancelled, paused }

extension PriorityExt on Priority {
  String get label {
    switch (this) {
      case Priority.low: return 'Low';
      case Priority.medium: return 'Medium';
      case Priority.high: return 'High';
      case Priority.critical: return 'Critical';
    }
  }

  int get colorValue {
    switch (this) {
      case Priority.low: return 0xFF6BCB77;
      case Priority.medium: return 0xFFFFD166;
      case Priority.high: return 0xFFFF8C42;
      case Priority.critical: return 0xFFCF6679;
    }
  }
}
