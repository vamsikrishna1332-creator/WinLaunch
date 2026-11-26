import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/database/database_helper.dart';
import 'core/services/settings_service.dart';
import 'mobile/mobile_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Android uses sqflite's native SQLite backend, not Windows desktop FFI.
  await DatabaseHelper.instance.database;
  await SettingsService().init();
  runApp(const ProviderScope(child: LaunchDeskMobileApp()));
}
