import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/widget_config_model.dart';
import '../../../core/providers/app_providers.dart';
import '../widgets/settings_section.dart';
import '../widgets/settings_row.dart';

class WidgetsSettingsPage extends ConsumerWidget {
  const WidgetsSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final widgets = ref.watch(widgetBoardProvider);
    final notifier = ref.read(widgetBoardProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Widgets', style: TextStyle(color: Color(theme.textColor), fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          SettingsSection(
            title: 'Active Widgets',
            children: widgets.isEmpty
                ? [Text('No widgets added yet.', style: TextStyle(color: Color(theme.secondaryTextColor)))]
                : widgets.map((w) => SettingsRow(
                      label: w.title.isEmpty ? w.type.label : w.title,
                      description: '${w.width.round()}×${w.height.round()} at (${w.x.round()}, ${w.y.round()})',
                      child: Row(children: [
                        ToggleSwitch(
                          checked: w.isVisible,
                          onChanged: (_) => notifier.toggleVisibility(w.id),
                        ),
                        const SizedBox(width: 8),
                        Button(
                          child: const Icon(FluentIcons.delete, size: 12),
                          onPressed: () => notifier.removeWidget(w.id),
                        ),
                      ]),
                    )).toList(),
          ),
        ],
      ),
    );
  }
}
