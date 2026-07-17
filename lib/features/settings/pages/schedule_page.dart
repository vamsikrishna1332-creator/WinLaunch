import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/app_providers.dart';
import '../widgets/settings_section.dart';
import '../widgets/settings_row.dart';

class ScheduleSettingsPage extends ConsumerWidget {
  const ScheduleSettingsPage({super.key});

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
          Text('Schedule', style: TextStyle(color: Color(theme.textColor), fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          settingsAsync.when(
            loading: () => const ProgressRing(),
            error: (_, __) => const Text('Error'),
            data: (s) => Column(children: [
              SettingsSection(title: 'Time & Date', children: [
                SettingsRow(
                  label: 'Time Format',
                  child: ComboBox<String>(
                    value: s.timeFormat,
                    items: const [
                      ComboBoxItem(value: 'HH:mm', child: Text('24h (14:30)')),
                      ComboBoxItem(value: 'hh:mm a', child: Text('12h (2:30 PM)')),
                      ComboBoxItem(value: 'HH:mm:ss', child: Text('24h with seconds')),
                    ],
                    onChanged: (v) => svc.updateSetting('timeFormat', v),
                  ),
                ),
                SettingsRow(
                  label: 'Date Format',
                  child: ComboBox<String>(
                    value: s.dateFormat,
                    items: const [
                      ComboBoxItem(value: 'EEEE, MMMM d', child: Text('Monday, January 1')),
                      ComboBoxItem(value: 'MMM d, yyyy', child: Text('Jan 1, 2024')),
                      ComboBoxItem(value: 'dd/MM/yyyy', child: Text('01/01/2024')),
                      ComboBoxItem(value: 'MM/dd/yyyy', child: Text('01/01/2024 (US)')),
                      ComboBoxItem(value: 'yyyy-MM-dd', child: Text('2024-01-01 (ISO)')),
                    ],
                    onChanged: (v) => svc.updateSetting('dateFormat', v),
                  ),
                ),
              ]),
              const SizedBox(height: 20),
              SettingsSection(title: 'Notifications', children: [
                SettingsRow(
                  label: 'Enable Schedule Notifications',
                  child: ToggleSwitch(
                    checked: s.enableNotifications,
                    onChanged: (v) => svc.updateSetting('enableNotifications', v),
                  ),
                ),
              ]),
            ]),
          ),
        ],
      ),
    );
  }
}
