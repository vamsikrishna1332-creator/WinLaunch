import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/app_providers.dart';
import '../widgets/settings_section.dart';
import '../widgets/settings_row.dart';

class LauncherSettingsPage extends ConsumerWidget {
  const LauncherSettingsPage({super.key});

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
          _title('Launcher', theme),
          const SizedBox(height: 24),
          settingsAsync.when(
            loading: () => const ProgressRing(),
            error: (_, __) => const Text('Error loading settings'),
            data: (s) => Column(
              children: [
                SettingsSection(title: 'Layout', children: [
                  SettingsRow(
                    label: 'Layout Style',
                    description: 'Grid or list view',
                    child: ComboBox<String>(
                      value: s.launcherLayout,
                      items: const [
                        ComboBoxItem(value: 'grid', child: Text('Grid')),
                        ComboBoxItem(value: 'list', child: Text('List')),
                      ],
                      onChanged: (v) => svc.updateSetting('launcherLayout', v),
                    ),
                  ),
                  SettingsRow(
                    label: 'Grid Columns',
                    description: 'Number of columns in grid view',
                    child: Row(children: [
                      SizedBox(
                        width: 180,
                        child: Slider(
                          value: s.launcherColumns.toDouble(),
                          min: 2, max: 12, divisions: 10,
                          onChanged: (v) => svc.updateSetting('launcherColumns', v.round()),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('${s.launcherColumns} cols',
                          style: TextStyle(color: Color(theme.secondaryTextColor), fontSize: 12)),
                    ]),
                  ),
                  SettingsRow(
                    label: 'Icon Size',
                    description: 'Size of app icons',
                    child: Row(children: [
                      SizedBox(
                        width: 180,
                        child: Slider(
                          value: s.launcherIconSize,
                          min: 32, max: 96, divisions: 8,
                          onChanged: (v) => svc.updateSetting('launcherIconSize', v),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('${s.launcherIconSize.round()}px',
                          style: TextStyle(color: Color(theme.secondaryTextColor), fontSize: 12)),
                    ]),
                  ),
                  SettingsRow(
                    label: 'Show Labels',
                    description: 'Display app names under icons',
                    child: ToggleSwitch(
                      checked: s.showLauncherLabels,
                      onChanged: (v) => svc.updateSetting('showLauncherLabels', v),
                    ),
                  ),
                ]),
                const SizedBox(height: 20),
                SettingsSection(title: 'Search & Sort', children: [
                  SettingsRow(
                    label: 'Enable Search',
                    child: ToggleSwitch(
                      checked: s.enableSearch,
                      onChanged: (v) => svc.updateSetting('enableSearch', v),
                    ),
                  ),
                  SettingsRow(
                    label: 'Sort Order',
                    child: ComboBox<String>(
                      value: s.sortOrder,
                      items: const [
                        ComboBoxItem(value: 'custom', child: Text('Custom')),
                        ComboBoxItem(value: 'name', child: Text('Name A-Z')),
                        ComboBoxItem(value: 'recent', child: Text('Recently Used')),
                      ],
                      onChanged: (v) => svc.updateSetting('sortOrder', v),
                    ),
                  ),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _title(String t, theme) => Text(t,
      style: TextStyle(
          color: Color(theme.textColor), fontSize: 22, fontWeight: FontWeight.bold));
}
