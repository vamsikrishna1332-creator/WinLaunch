import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:window_manager/window_manager.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:local_notifier/local_notifier.dart';
import 'dart:io';
import 'app.dart';
import 'core/database/database_helper.dart';
import 'core/services/settings_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Init SQLite for desktop
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // Initialize window manager
  await windowManager.ensureInitialized();

  // Load saved window settings
  final settingsService = SettingsService();
  await settingsService.init();
  final settings = await settingsService.loadSettings();

  WindowOptions windowOptions = WindowOptions(
    size: Size(
      settings.windowWidth.toDouble(),
      settings.windowHeight.toDouble(),
    ),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: settings.customTitleBar
        ? TitleBarStyle.hidden
        : TitleBarStyle.normal,
    title: settings.appName,
    minimumSize: const Size(800, 600),
  );

  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
    if (settings.startFullscreen) {
      await windowManager.setFullScreen(true);
    }
    if (settings.startMaximized) {
      await windowManager.maximize();
    }
  });

  // Initialize database
  await DatabaseHelper.instance.database;

  // Initialize hotkey manager
  await hotKeyManager.unregisterAll();

  // Initialize local notifications
  await localNotifier.setup(
    appName: settings.appName,
    shortcutPolicy: ShortcutPolicy.requireCreate,
  );

  runApp(
    ProviderScope(
      child: LaunchDeskApp(),
    ),
  );
}
