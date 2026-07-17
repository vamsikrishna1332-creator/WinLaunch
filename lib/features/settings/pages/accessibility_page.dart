import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/app_providers.dart';
import '../widgets/settings_section.dart';
import '../widgets/settings_row.dart';

class AccessibilityPage extends ConsumerWidget {
  const AccessibilityPage({super.key});

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
          Text('Accessibility', style: TextStyle(color: Color(theme.textColor), fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          settingsAsync.when(
            loading: () => const ProgressRing(),
            error: (_, __) => const Text('Error'),
            data: (s) => Column(children: [
              SettingsSection(title: 'Visual', children: [
                SettingsRow(
                  label: 'High Contrast',
                  description: 'Increase text and border contrast',
                  child: ToggleSwitch(checked: s.highContrast, onChanged: (v) => svc.updateSetting('highContrast', v)),
                ),
                SettingsRow(
                  label: 'Reduce Motion',
                  description: 'Disable all animations',
                  child: ToggleSwitch(checked: s.reduceMotion, onChanged: (v) => svc.updateSetting('reduceMotion', v)),
                ),
              ]),
              const SizedBox(height: 20),
              SettingsSection(title: 'Input', children: [
                SettingsRow(
                  label: 'Touchscreen Mode',
                  description: 'Larger buttons and touch-friendly layout',
                  child: ToggleSwitch(checked: s.enableTouchscreen, onChanged: (v) => svc.updateSetting('enableTouchscreen', v)),
                ),
                SettingsRow(
                  label: 'Keyboard Shortcuts',
                  description: 'Enable hotkey bindings',
                  child: ToggleSwitch(checked: s.enableHotkeys, onChanged: (v) => svc.updateSetting('enableHotkeys', v)),
                ),
              ]),
            ]),
          ),
        ],
      ),
    );
  }
}
