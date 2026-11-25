import 'dart:convert';
import 'dart:io';
import '../models/theme_model.dart';
import '../database/database_helper.dart';

class ThemeService {
  static final ThemeService _instance = ThemeService._internal();
  factory ThemeService() => _instance;
  ThemeService._internal();

  List<LaunchDeskTheme>? _cachedThemes;

  Future<List<LaunchDeskTheme>> loadThemes() async {
    if (_cachedThemes != null) return _cachedThemes!;
    final rows = await DatabaseHelper.instance.queryAll('themes',
        orderBy: 'created_at ASC');
    final themes = rows.map((r) => LaunchDeskTheme.fromJson(
          jsonDecode(r['data'] as String),
        )).toList();

    // Ensure built-in themes always exist
    for (final builtin in LaunchDeskTheme.builtinThemes) {
      if (!themes.any((t) => t.id == builtin.id)) {
        themes.insert(0, builtin);
        await _saveThemeToDB(builtin);
      }
    }

    _cachedThemes = themes;
    return themes;
  }

  Future<LaunchDeskTheme?> loadTheme(String id) async {
    final themes = await loadThemes();
    return themes.firstWhere((t) => t.id == id,
        orElse: () => LaunchDeskTheme.defaultDark);
  }

  Future<void> saveTheme(LaunchDeskTheme theme) async {
    await _saveThemeToDB(theme);
    _cachedThemes = null; // invalidate cache
  }

  Future<void> _saveThemeToDB(LaunchDeskTheme theme) async {
    await DatabaseHelper.instance.insert('themes', {
      'id': theme.id,
      'name': theme.name,
      'description': theme.description,
      'author': theme.author,
      'version': theme.version,
      'data': jsonEncode(theme.toJson()),
      'thumbnail': theme.thumbnail,
      'created_at': theme.createdAt.toIso8601String(),
      'updated_at': theme.updatedAt.toIso8601String(),
    });
  }

  Future<void> deleteTheme(String id) async {
    // Can't delete built-in themes
    if (LaunchDeskTheme.builtinThemes.any((t) => t.id == id)) return;
    await DatabaseHelper.instance.delete('themes', id);
    _cachedThemes?.removeWhere((t) => t.id == id);
  }

  Future<String> exportTheme(LaunchDeskTheme theme) async {
    return jsonEncode({
      'launchdesk_theme': '1.0',
      'theme': theme.toJson(),
    });
  }

  Future<LaunchDeskTheme?> importTheme(String jsonString) async {
    try {
      final data = jsonDecode(jsonString);
      final themeData = data['theme'] ?? data;
      final theme = LaunchDeskTheme.fromJson(themeData);
      await saveTheme(theme);
      return theme;
    } catch (e) {
      return null;
    }
  }

  Future<void> exportThemeToFile(LaunchDeskTheme theme, String path) async {
    final file = File(path);
    await file.writeAsString(await exportTheme(theme));
  }

  Future<LaunchDeskTheme?> importThemeFromFile(String path) async {
    final file = File(path);
    if (!await file.exists()) return null;
    return importTheme(await file.readAsString());
  }

  void invalidateCache() => _cachedThemes = null;
}
