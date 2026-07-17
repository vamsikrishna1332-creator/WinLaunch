import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/app_providers.dart';
import '../widgets/settings_section.dart';
import '../widgets/settings_row.dart';

class PerformancePage extends ConsumerWidget {
  const PerformancePage({super.key});

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
          Text('Performance', style: TextStyle(color: Color(theme.textColor), fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          settingsAsync.when(
            loading: () => const ProgressRing(),
            error: (_, __) => const Text('Error'),
            data: (s) => Column(children: [
              SettingsSection(title: 'Startup', children: [
                SettingsRow(
                  label: 'Start Fullscreen',
                  child: ToggleSwitch(checked: s.startFullscreen, onChanged: (v) => svc.updateSetting('startFullscreen', v)),
                ),
                SettingsRow(
                  label: 'Start Maximized',
                  child: ToggleSwitch(checked: s.startMaximized, onChanged: (v) => svc.updateSetting('startMaximized', v)),
                ),
              ]),
              const SizedBox(height: 20),
              SettingsSection(title: 'Window', children: [
                SettingsRow(
                  label: 'Custom Title Bar',
                  description: 'Use built-in custom title bar',
                  child: ToggleSwitch(checked: s.customTitleBar, onChanged: (v) => svc.updateSetting('customTitleBar', v)),
                ),
                SettingsRow(
                  label: 'Auto Save',
                  description: 'Automatically save settings on change',
                  child: ToggleSwitch(checked: s.autoSave, onChanged: (v) => svc.updateSetting('autoSave', v)),
                ),
              ]),
            ]),
          ),
        ],
      ),
    );
  }
}
