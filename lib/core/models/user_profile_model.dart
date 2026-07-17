class UserProfile {
  final String id;
  final String name;
  final String? avatarPath;
  final String activeThemeId;
  final Map<String, dynamic> preferences;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime lastUsed;

  const UserProfile({
    required this.id,
    required this.name,
    this.avatarPath,
    this.activeThemeId = 'default_dark',
    this.preferences = const {},
    this.isDefault = false,
    required this.createdAt,
    required this.lastUsed,
  });

  UserProfile copyWith({
    String? name,
    String? avatarPath,
    String? activeThemeId,
    Map<String, dynamic>? preferences,
    bool? isDefault,
    DateTime? lastUsed,
  }) {
    return UserProfile(
      id: id,
      name: name ?? this.name,
      avatarPath: avatarPath ?? this.avatarPath,
      activeThemeId: activeThemeId ?? this.activeThemeId,
      preferences: preferences ?? this.preferences,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt,
      lastUsed: lastUsed ?? this.lastUsed,
    );
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: json['id'],
        name: json['name'],
        avatarPath: json['avatarPath'],
        activeThemeId: json['activeThemeId'] ?? 'default_dark',
        preferences: Map<String, dynamic>.from(json['preferences'] ?? {}),
        isDefault: json['isDefault'] ?? false,
        createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
        lastUsed: DateTime.tryParse(json['lastUsed'] ?? '') ?? DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'avatarPath': avatarPath,
        'activeThemeId': activeThemeId,
        'preferences': preferences,
        'isDefault': isDefault,
        'createdAt': createdAt.toIso8601String(),
        'lastUsed': lastUsed.toIso8601String(),
      };

  static UserProfile get defaultProfile => UserProfile(
        id: 'default',
        name: 'User',
        activeThemeId: 'default_dark',
        isDefault: true,
        createdAt: DateTime.now(),
        lastUsed: DateTime.now(),
      );
}
