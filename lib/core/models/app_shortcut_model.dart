class AppShortcut {
  final String id;
  final String name;
  final String? description;
  final ShortcutType type;
  final String target; // exe path, URL, folder path, file path
  final String? iconPath;
  final String? customIconData; // base64 or asset name
  final int iconColor;
  final String? category;
  final String? groupId;
  final bool isFavorite;
  final bool isPinned;
  final int sortOrder;
  final DateTime? lastOpened;
  final int openCount;
  final String profileId;
  final List<String> tags;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;

  const AppShortcut({
    required this.id,
    required this.name,
    this.description,
    required this.type,
    required this.target,
    this.iconPath,
    this.customIconData,
    this.iconColor = 0xFF0078D4,
    this.category,
    this.groupId,
    this.isFavorite = false,
    this.isPinned = false,
    this.sortOrder = 0,
    this.lastOpened,
    this.openCount = 0,
    this.profileId = 'default',
    this.tags = const [],
    this.metadata = const {},
    required this.createdAt,
  });

  AppShortcut copyWith({
    String? name,
    String? description,
    ShortcutType? type,
    String? target,
    String? iconPath,
    String? customIconData,
    int? iconColor,
    String? category,
    String? groupId,
    bool? isFavorite,
    bool? isPinned,
    int? sortOrder,
    DateTime? lastOpened,
    int? openCount,
    List<String>? tags,
    Map<String, dynamic>? metadata,
  }) {
    return AppShortcut(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      target: target ?? this.target,
      iconPath: iconPath ?? this.iconPath,
      customIconData: customIconData ?? this.customIconData,
      iconColor: iconColor ?? this.iconColor,
      category: category ?? this.category,
      groupId: groupId ?? this.groupId,
      isFavorite: isFavorite ?? this.isFavorite,
      isPinned: isPinned ?? this.isPinned,
      sortOrder: sortOrder ?? this.sortOrder,
      lastOpened: lastOpened ?? this.lastOpened,
      openCount: openCount ?? this.openCount,
      profileId: profileId,
      tags: tags ?? this.tags,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt,
    );
  }

  factory AppShortcut.fromJson(Map<String, dynamic> json) => AppShortcut(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        type: ShortcutType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => ShortcutType.app,
        ),
        target: json['target'],
        iconPath: json['iconPath'],
        customIconData: json['customIconData'],
        iconColor: json['iconColor'] ?? 0xFF0078D4,
        category: json['category'],
        groupId: json['groupId'],
        isFavorite: json['isFavorite'] ?? false,
        isPinned: json['isPinned'] ?? false,
        sortOrder: json['sortOrder'] ?? 0,
        lastOpened: json['lastOpened'] != null
            ? DateTime.tryParse(json['lastOpened'])
            : null,
        openCount: json['openCount'] ?? 0,
        profileId: json['profileId'] ?? 'default',
        tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
        metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
        createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'type': type.name,
        'target': target,
        'iconPath': iconPath,
        'customIconData': customIconData,
        'iconColor': iconColor,
        'category': category,
        'groupId': groupId,
        'isFavorite': isFavorite,
        'isPinned': isPinned,
        'sortOrder': sortOrder,
        'lastOpened': lastOpened?.toIso8601String(),
        'openCount': openCount,
        'profileId': profileId,
        'tags': tags,
        'metadata': metadata,
        'createdAt': createdAt.toIso8601String(),
      };
}

enum ShortcutType { app, website, folder, file, command }

class ShortcutGroup {
  final String id;
  final String name;
  final int color;
  final String? iconPath;
  final bool isExpanded;
  final int sortOrder;
  final String profileId;

  const ShortcutGroup({
    required this.id,
    required this.name,
    this.color = 0xFF0078D4,
    this.iconPath,
    this.isExpanded = true,
    this.sortOrder = 0,
    this.profileId = 'default',
  });

  factory ShortcutGroup.fromJson(Map<String, dynamic> json) => ShortcutGroup(
        id: json['id'],
        name: json['name'],
        color: json['color'] ?? 0xFF0078D4,
        iconPath: json['iconPath'],
        isExpanded: json['isExpanded'] ?? true,
        sortOrder: json['sortOrder'] ?? 0,
        profileId: json['profileId'] ?? 'default',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'color': color,
        'iconPath': iconPath,
        'isExpanded': isExpanded,
        'sortOrder': sortOrder,
        'profileId': profileId,
      };

  ShortcutGroup copyWith({String? name, int? color, bool? isExpanded, int? sortOrder}) {
    return ShortcutGroup(
      id: id,
      name: name ?? this.name,
      color: color ?? this.color,
      iconPath: iconPath,
      isExpanded: isExpanded ?? this.isExpanded,
      sortOrder: sortOrder ?? this.sortOrder,
      profileId: profileId,
    );
  }
}
