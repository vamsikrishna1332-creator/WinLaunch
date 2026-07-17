class Note {
  final String id;
  final String title;
  final String content;
  final int color;
  final bool isPinned;
  final List<String> tags;
  final String profileId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Note({
    required this.id,
    required this.title,
    this.content = '',
    this.color = 0xFF1E1E2E,
    this.isPinned = false,
    this.tags = const [],
    this.profileId = 'default',
    required this.createdAt,
    required this.updatedAt,
  });

  Note copyWith({
    String? title,
    String? content,
    int? color,
    bool? isPinned,
    List<String>? tags,
  }) {
    return Note(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      color: color ?? this.color,
      isPinned: isPinned ?? this.isPinned,
      tags: tags ?? this.tags,
      profileId: profileId,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  factory Note.fromJson(Map<String, dynamic> json) => Note(
        id: json['id'],
        title: json['title'],
        content: json['content'] ?? '',
        color: json['color'] ?? 0xFF1E1E2E,
        isPinned: json['isPinned'] ?? false,
        tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
        profileId: json['profileId'] ?? 'default',
        createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
        updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'color': color,
        'isPinned': isPinned,
        'tags': tags,
        'profileId': profileId,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };
}

class TodoItem {
  final String id;
  final String text;
  final bool isCompleted;
  final int priority;
  final DateTime? dueDate;
  final String profileId;
  final int sortOrder;

  const TodoItem({
    required this.id,
    required this.text,
    this.isCompleted = false,
    this.priority = 1,
    this.dueDate,
    this.profileId = 'default',
    this.sortOrder = 0,
  });

  TodoItem copyWith({String? text, bool? isCompleted, int? priority, DateTime? dueDate, int? sortOrder}) {
    return TodoItem(
      id: id,
      text: text ?? this.text,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      profileId: profileId,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  factory TodoItem.fromJson(Map<String, dynamic> json) => TodoItem(
        id: json['id'],
        text: json['text'],
        isCompleted: json['isCompleted'] ?? false,
        priority: json['priority'] ?? 1,
        dueDate: json['dueDate'] != null ? DateTime.tryParse(json['dueDate']) : null,
        profileId: json['profileId'] ?? 'default',
        sortOrder: json['sortOrder'] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'isCompleted': isCompleted,
        'priority': priority,
        'dueDate': dueDate?.toIso8601String(),
        'profileId': profileId,
        'sortOrder': sortOrder,
      };
}
