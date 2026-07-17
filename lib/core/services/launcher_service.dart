import 'dart:convert';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import '../models/app_shortcut_model.dart';
import '../database/database_helper.dart';

class LauncherService {
  static final LauncherService _instance = LauncherService._internal();
  factory LauncherService() => _instance;
  LauncherService._internal();

  final _uuid = const Uuid();

  // ─── Shortcuts ─────────────────────────────────────────────────────────────

  Future<List<AppShortcut>> loadShortcuts({String profileId = 'default'}) async {
    final rows = await DatabaseHelper.instance.queryAll(
      'apps',
      where: 'profile_id = ?',
      whereArgs: [profileId],
      orderBy: 'sort_order ASC, name ASC',
    );
    return rows.map((r) => AppShortcut.fromJson({
          ...r,
          'isFavorite': r['is_favorite'],
          'isPinned': r['is_pinned'],
          'sortOrder': r['sort_order'],
          'lastOpened': r['last_opened'],
          'openCount': r['open_count'],
          'iconPath': r['icon_path'],
          'customIconData': r['custom_icon_data'],
          'iconColor': r['icon_color'],
          'groupId': r['group_id'],
          'createdAt': r['created_at'],
          'profileId': r['profile_id'],
          'tags': jsonDecode(r['tags'] as String? ?? '[]'),
          'metadata': jsonDecode(r['metadata'] as String? ?? '{}'),
        })).toList();
  }

  Future<AppShortcut> addShortcut(AppShortcut shortcut) async {
    final s = shortcut.id.isEmpty
        ? AppShortcut(
            id: _uuid.v4(),
            name: shortcut.name,
            description: shortcut.description,
            type: shortcut.type,
            target: shortcut.target,
            iconPath: shortcut.iconPath,
            customIconData: shortcut.customIconData,
            iconColor: shortcut.iconColor,
            category: shortcut.category,
            groupId: shortcut.groupId,
            isFavorite: shortcut.isFavorite,
            isPinned: shortcut.isPinned,
            sortOrder: shortcut.sortOrder,
            profileId: shortcut.profileId,
            tags: shortcut.tags,
            metadata: shortcut.metadata,
            createdAt: DateTime.now(),
          )
        : shortcut;
    await _saveShortcut(s);
    return s;
  }

  Future<void> updateShortcut(AppShortcut shortcut) async {
    await _saveShortcut(shortcut);
  }

  Future<void> deleteShortcut(String id) async {
    await DatabaseHelper.instance.delete('apps', id);
  }

  Future<void> reorderShortcuts(List<AppShortcut> shortcuts) async {
    for (int i = 0; i < shortcuts.length; i++) {
      await DatabaseHelper.instance.update(
          'apps', {'sort_order': i}, shortcuts[i].id);
    }
  }

  Future<void> _saveShortcut(AppShortcut s) async {
    await DatabaseHelper.instance.insert('apps', {
      'id': s.id,
      'profile_id': s.profileId,
      'name': s.name,
      'description': s.description,
      'type': s.type.name,
      'target': s.target,
      'icon_path': s.iconPath,
      'custom_icon_data': s.customIconData,
      'icon_color': s.iconColor,
      'category': s.category,
      'group_id': s.groupId,
      'is_favorite': s.isFavorite ? 1 : 0,
      'is_pinned': s.isPinned ? 1 : 0,
      'sort_order': s.sortOrder,
      'last_opened': s.lastOpened?.toIso8601String(),
      'open_count': s.openCount,
      'tags': jsonEncode(s.tags),
      'metadata': jsonEncode(s.metadata),
      'created_at': s.createdAt.toIso8601String(),
    });
  }

  // ─── Groups ────────────────────────────────────────────────────────────────

  Future<List<ShortcutGroup>> loadGroups({String profileId = 'default'}) async {
    final rows = await DatabaseHelper.instance.queryAll(
      'app_groups',
      where: 'profile_id = ?',
      whereArgs: [profileId],
      orderBy: 'sort_order ASC',
    );
    return rows.map((r) => ShortcutGroup.fromJson({
          ...r,
          'isExpanded': r['is_expanded'],
          'sortOrder': r['sort_order'],
          'iconPath': r['icon_path'],
          'profileId': r['profile_id'],
        })).toList();
  }

  Future<ShortcutGroup> addGroup(ShortcutGroup group) async {
    final g = ShortcutGroup(
      id: group.id.isEmpty ? _uuid.v4() : group.id,
      name: group.name,
      color: group.color,
      iconPath: group.iconPath,
      isExpanded: group.isExpanded,
      sortOrder: group.sortOrder,
      profileId: group.profileId,
    );
    await DatabaseHelper.instance.insert('app_groups', {
      'id': g.id,
      'profile_id': g.profileId,
      'name': g.name,
      'color': g.color,
      'icon_path': g.iconPath,
      'is_expanded': g.isExpanded ? 1 : 0,
      'sort_order': g.sortOrder,
    });
    return g;
  }

  Future<void> deleteGroup(String id) async {
    await DatabaseHelper.instance.delete('app_groups', id);
    // Move group's shortcuts to ungrouped
    final db = DatabaseHelper.instance;
    await (await db.database)
        .update('apps', {'group_id': null}, where: 'group_id = ?', whereArgs: [id]);
  }

  // ─── Launch ────────────────────────────────────────────────────────────────

  Future<bool> launch(AppShortcut shortcut) async {
    try {
      bool success = false;
      switch (shortcut.type) {
        case ShortcutType.app:
        case ShortcutType.file:
        case ShortcutType.folder:
          if (Platform.isWindows) {
            await Process.start('explorer', [shortcut.target]);
            success = true;
          } else {
            final uri = Uri.file(shortcut.target);
            success = await launchUrl(uri);
          }
          break;
        case ShortcutType.website:
          final uri = Uri.parse(shortcut.target);
          success = await launchUrl(uri, mode: LaunchMode.externalApplication);
          break;
        case ShortcutType.command:
          await Process.run('cmd', ['/c', shortcut.target]);
          success = true;
          break;
      }
      if (success) {
        await DatabaseHelper.instance.update('apps', {
          'last_opened': DateTime.now().toIso8601String(),
          'open_count': shortcut.openCount + 1,
        }, shortcut.id);
      }
      return success;
    } catch (e) {
      return false;
    }
  }
}
