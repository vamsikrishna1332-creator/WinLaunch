import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/app_providers.dart';
import '../widgets/settings_section.dart';
import '../widgets/settings_row.dart';

class AdvancedPage extends ConsumerWidget {
  const AdvancedPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final settingsAsync = ref.watch(settingsProvider);
    final svc = ref.read(settingsServiceProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Advanced', style: TextStyle(color: Color(theme.textColor), fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          settingsAsync.when(
            loading: () => const ProgressRing(),
            error: (_, __) => const Text('Error'),
            data: (s) => Column(children: [
              SettingsSection(title: 'Developer', children: [
                SettingsRow(
                  label: 'Developer Mode',
                  description: 'Enable advanced diagnostics and logging',
                  child: ToggleSwitch(checked: s.developerMode, onChanged: (v) => svc.updateSetting('developerMode', v)),
                ),
              ]),
              const SizedBox(height: 20),
              SettingsSection(title: 'Reset', children: [
                SettingsRow(
                  label: 'Reset to Defaults',
                  description: 'Restore all settings to factory defaults',
                  child: Button(
                    child: const Text('Reset All Settings'),
                    onPressed: () => showDialog(
                      context: context,
                      builder: (_) => ContentDialog(
                        title: const Text('Reset Settings'),
                        content: const Text('Are you sure? This will reset all settings to their defaults.'),
                        actions: [
                          Button(child: const Text('Cancel'), onPressed: () => Navigator.pop(context)),
                          FilledButton(
                            child: const Text('Reset'),
                            onPressed: () {
                              svc.resetToDefaults();
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ]),
              if (s.developerMode) ...[
                const SizedBox(height: 20),
                SettingsSection(title: 'Custom Variables', children: [
                  const Text('Custom theme variables are editable in the Theme Editor.',
                      style: TextStyle(fontSize: 12)),
                ]),
              ],
            ]),
          ),
        ],
      ),
    );
  }
}
