import 'dart:io';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/providers/app_providers.dart';
import '../widgets/settings_section.dart';
import '../widgets/settings_row.dart';

class BackupPage extends ConsumerWidget {
  const BackupPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Backup & Restore', style: TextStyle(color: Color(theme.textColor), fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          SettingsSection(title: 'Settings', children: [
            SettingsRow(
              label: 'Export Settings',
              description: 'Save all settings to a JSON file',
              child: FilledButton(
                child: const Text('Export'),
                onPressed: () async {
                  try {
                    final json = await ref.read(settingsServiceProvider).exportSettings();
                    final path = await FilePicker.platform.saveFile(
                      dialogTitle: 'Export Settings',
                      fileName: 'launchdesk_settings.json',
                    );
                    if (path != null) {
                      await File(path).writeAsString(json);
                      if (context.mounted) {
                        displayInfoBar(context, builder: (_, close) => InfoBar(
                          title: const Text('Settings exported successfully'),
                          severity: InfoBarSeverity.success,
                          onClose: close,
                        ));
                      }
                    }
                  } catch (e) {
                    if (context.mounted) {
                      displayInfoBar(context, builder: (_, close) => InfoBar(
                        title: Text('Export failed: $e'),
                        severity: InfoBarSeverity.error,
                        onClose: close,
                      ));
                    }
                  }
                },
              ),
            ),
            SettingsRow(
              label: 'Import Settings',
              description: 'Restore settings from a JSON file',
              child: Button(
                child: const Text('Import'),
                onPressed: () async {
                  try {
                    final result = await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: ['json'],
                    );
                    if (result != null && result.files.single.path != null) {
                      final json = await File(result.files.single.path!).readAsString();
                      await ref.read(settingsServiceProvider).importSettings(json);
                      if (context.mounted) {
                        displayInfoBar(context, builder: (_, close) => InfoBar(
                          title: const Text('Settings imported. Restart to apply.'),
                          severity: InfoBarSeverity.success,
                          onClose: close,
                        ));
                      }
                    }
                  } catch (e) {
                    if (context.mounted) {
                      displayInfoBar(context, builder: (_, close) => InfoBar(
                        title: Text('Import failed: $e'),
                        severity: InfoBarSeverity.error,
                        onClose: close,
                      ));
                    }
                  }
                },
              ),
            ),
          ]),
          const SizedBox(height: 20),
          SettingsSection(title: 'Themes', children: [
            SettingsRow(
              label: 'Export Current Theme',
              description: 'Save active theme as .json file',
              child: FilledButton(
                child: const Text('Export Theme'),
                onPressed: () async {
                  try {
                    final theme = ref.read(themeProvider);
                    final json = await ref.read(themeServiceProvider).exportTheme(theme);
                    final path = await FilePicker.platform.saveFile(
                      dialogTitle: 'Export Theme',
                      fileName: '${theme.name.replaceAll(' ', '_').toLowerCase()}.launchdesk_theme.json',
                    );
                    if (path != null) await File(path).writeAsString(json);
                  } catch (e) {}
                },
              ),
            ),
            SettingsRow(
              label: 'Import Theme',
              description: 'Load a .json theme file',
              child: Button(
                child: const Text('Import Theme'),
                onPressed: () async {
                  try {
                    final result = await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: ['json'],
                    );
                    if (result != null && result.files.single.path != null) {
                      final json = await File(result.files.single.path!).readAsString();
                      final imported = await ref.read(themeServiceProvider).importTheme(json);
                      if (imported != null && context.mounted) {
                        displayInfoBar(context, builder: (_, close) => InfoBar(
                          title: Text('Theme "${imported.name}" imported!'),
                          severity: InfoBarSeverity.success,
                          onClose: close,
                        ));
                      }
                    }
                  } catch (e) {}
                },
              ),
            ),
          ]),
        ],
      ),
    );
  }
}
