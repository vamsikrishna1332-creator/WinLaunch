import 'dart:convert';
import 'package:uuid/uuid.dart';
import '../models/widget_config_model.dart';
import '../database/database_helper.dart';

class WidgetService {
  static final WidgetService _instance = WidgetService._internal();
  factory WidgetService() => _instance;
  WidgetService._internal();

  final _uuid = const Uuid();

  Future<List<WidgetConfig>> loadWidgets({String profileId = 'default'}) async {
    final rows = await DatabaseHelper.instance.queryAll(
      'widgets',
      where: 'profile_id = ?',
      whereArgs: [profileId],
      orderBy: 'sort_order ASC',
    );
    return rows.map((r) => WidgetConfig.fromJson({
          ...r,
          'isVisible': r['is_visible'],
          'sortOrder': r['sort_order'],
          'settings': jsonDecode(r['settings'] as String? ?? '{}'),
          'createdAt': r['created_at'],
          'profileId': r['profile_id'],
        })).toList();
  }

  Future<WidgetConfig> addWidget(WidgetType type, {String profileId = 'default'}) async {
    final defaultConfig = type.defaultConfig;
    final widget = WidgetConfig(
      id: _uuid.v4(),
      type: type,
      title: defaultConfig.title,
      isVisible: true,
      x: defaultConfig.x,
      y: defaultConfig.y,
      width: defaultConfig.width,
      height: defaultConfig.height,
      sortOrder: DateTime.now().millisecondsSinceEpoch,
      settings: defaultConfig.settings,
      profileId: profileId,
      createdAt: DateTime.now(),
    );
    await _save(widget);
    return widget;
  }

  Future<void> updateWidget(WidgetConfig widget) async {
    await _save(widget);
  }

  Future<void> updatePosition(String id, double x, double y) async {
    await DatabaseHelper.instance.update('widgets', {'x': x, 'y': y}, id);
  }

  Future<void> updateSize(String id, double width, double height) async {
    await DatabaseHelper.instance.update('widgets', {'width': width, 'height': height}, id);
  }

  Future<void> toggleVisibility(String id, bool visible) async {
    await DatabaseHelper.instance.update('widgets', {'is_visible': visible ? 1 : 0}, id);
  }

  Future<void> deleteWidget(String id) async {
    await DatabaseHelper.instance.delete('widgets', id);
  }

  Future<void> updateSettings(String id, Map<String, dynamic> settings) async {
    await DatabaseHelper.instance.update(
        'widgets', {'settings': jsonEncode(settings)}, id);
  }

  Future<void> _save(WidgetConfig w) async {
    await DatabaseHelper.instance.insert('widgets', {
      'id': w.id,
      'profile_id': w.profileId,
      'type': w.type.name,
      'title': w.title,
      'is_visible': w.isVisible ? 1 : 0,
      'x': w.x,
      'y': w.y,
      'width': w.width,
      'height': w.height,
      'sort_order': w.sortOrder,
      'settings': jsonEncode(w.settings),
      'created_at': w.createdAt.toIso8601String(),
    });
  }
}
