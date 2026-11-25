import 'package:fluent_ui/fluent_ui.dart' hide ColorPicker;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import '../../../core/providers/app_providers.dart';
import '../widgets/settings_section.dart';
import '../widgets/settings_row.dart';

class AppearancePage extends ConsumerStatefulWidget {
  const AppearancePage({super.key});

  @override
  ConsumerState<AppearancePage> createState() => _AppearancePageState();
}

class _AppearancePageState extends ConsumerState<AppearancePage> {
  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);
    final settingsAsync = ref.watch(settingsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(title: 'Appearance', subtitle: 'Customize every visual aspect'),
          const SizedBox(height: 24),

          SettingsSection(
            title: 'General',
            children: [
              settingsAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (settings) => Column(
                  children: [
                    SettingsRow(
                      label: 'App Name',
                      description: 'Shown in the top bar and title',
                      child: SizedBox(
                        width: 220,
                        child: TextBox(
                          controller: TextEditingController(text: settings.appName),
                          onChanged: (v) => ref
                              .read(settingsServiceProvider)
                              .updateSetting('appName', v),
                        ),
                      ),
                    ),
                    SettingsRow(
                      label: 'Welcome Text',
                      description: 'Displayed under your name',
                      child: SizedBox(
                        width: 220,
                        child: TextBox(
                          controller: TextEditingController(text: settings.welcomeText),
                          onChanged: (v) => ref
                              .read(settingsServiceProvider)
                              .updateSetting('welcomeText', v),
                        ),
                      ),
                    ),
                    SettingsRow(
                      label: 'Username',
                      description: 'Your name on the home screen',
                      child: SizedBox(
                        width: 220,
                        child: TextBox(
                          controller: TextEditingController(text: settings.username),
                          onChanged: (v) => ref
                              .read(settingsServiceProvider)
                              .updateSetting('username', v),
                        ),
                      ),
                    ),
                    SettingsRow(
                      label: 'UI Scale',
                      description: 'Zoom level for the entire UI',
                      child: Row(
                        children: [
                          SizedBox(
                            width: 180,
                            child: Slider(
                              value: settings.uiScale,
                              min: 0.7,
                              max: 1.5,
                              divisions: 8,
                              onChanged: (v) => ref
                                  .read(settingsServiceProvider)
                                  .updateSetting('uiScale', v),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text('${(settings.uiScale * 100).round()}%',
                              style: TextStyle(
                                  color: Color(theme.secondaryTextColor),
                                  fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          SettingsSection(
            title: 'Colors',
            children: [
              _ColorRow(
                label: 'Accent Color',
                color: Color(theme.accentColor),
                onChanged: (c) => themeNotifier.updateProperty(
                    (t) => t.copyWith(accentColor: c.value)),
              ),
              _ColorRow(
                label: 'Text Color',
                color: Color(theme.textColor),
                onChanged: (c) => themeNotifier.updateProperty(
                    (t) => t.copyWith(textColor: c.value)),
              ),
              _ColorRow(
                label: 'Background Color',
                color: Color(theme.backgroundColor),
                onChanged: (c) => themeNotifier.updateProperty(
                    (t) => t.copyWith(backgroundColor: c.value)),
              ),
              _ColorRow(
                label: 'Card Color',
                color: Color(theme.cardColor),
                onChanged: (c) => themeNotifier.updateProperty(
                    (t) => t.copyWith(cardColor: c.value)),
              ),
            ],
          ),
          const SizedBox(height: 20),

          SettingsSection(
            title: 'Typography',
            children: [
              SettingsRow(
                label: 'Font Family',
                description: 'Used throughout the app',
                child: SizedBox(
                  width: 220,
                  child: ComboBox<String>(
                    value: theme.fontFamily,
                    items: const [
                      'Segoe UI', 'Cascadia Code', 'Arial', 'Consolas',
                      'Verdana', 'Tahoma', 'Georgia', 'Times New Roman',
                    ].map((f) => ComboBoxItem<String>(value: f, child: Text(f))).toList(),
                    onChanged: (v) => themeNotifier.updateProperty(
                        (t) => t.copyWith(fontFamily: v)),
                  ),
                ),
              ),
              SettingsRow(
                label: 'Base Font Size',
                description: 'Size in points',
                child: Row(
                  children: [
                    SizedBox(
                      width: 180,
                      child: Slider(
                        value: theme.baseFontSize,
                        min: 10,
                        max: 24,
                        divisions: 14,
                        onChanged: (v) => themeNotifier.updateProperty(
                            (t) => t.copyWith(baseFontSize: v)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('${theme.baseFontSize.round()}pt',
                        style: TextStyle(
                            color: Color(theme.secondaryTextColor),
                            fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          SettingsSection(
            title: 'Glass & Blur',
            children: [
              SettingsRow(
                label: 'Enable Glass Effect',
                description: 'Frosted glass on cards and panels',
                child: ToggleSwitch(
                  checked: theme.enableGlass,
                  onChanged: (v) => themeNotifier.updateProperty(
                      (t) => t.copyWith(enableGlass: v)),
                ),
              ),
              if (theme.enableGlass) ...[
                SettingsRow(
                  label: 'Glass Opacity',
                  description: 'Transparency level of glass surfaces',
                  child: Row(
                    children: [
                      SizedBox(
                        width: 180,
                        child: Slider(
                          value: theme.glassOpacity,
                          min: 0.0,
                          max: 0.8,
                          onChanged: (v) => themeNotifier.updateProperty(
                              (t) => t.copyWith(glassOpacity: v)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('${(theme.glassOpacity * 100).round()}%',
                          style: TextStyle(
                              color: Color(theme.secondaryTextColor),
                              fontSize: 12)),
                    ],
                  ),
                ),
                SettingsRow(
                  label: 'Blur Amount',
                  description: 'Background blur strength',
                  child: Row(
                    children: [
                      SizedBox(
                        width: 180,
                        child: Slider(
                          value: theme.blurAmount,
                          min: 0,
                          max: 40,
                          onChanged: (v) => themeNotifier.updateProperty(
                              (t) => t.copyWith(blurAmount: v)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('${theme.blurAmount.round()}px',
                          style: TextStyle(
                              color: Color(theme.secondaryTextColor),
                              fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 20),

          SettingsSection(
            title: 'Shapes & Spacing',
            children: [
              SettingsRow(
                label: 'Card Border Radius',
                description: 'Roundness of cards',
                child: Row(
                  children: [
                    SizedBox(
                      width: 180,
                      child: Slider(
                        value: theme.cardBorderRadius,
                        min: 0,
                        max: 32,
                        divisions: 32,
                        onChanged: (v) => themeNotifier.updateProperty(
                            (t) => t.copyWith(cardBorderRadius: v)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('${theme.cardBorderRadius.round()}px',
                        style: TextStyle(
                            color: Color(theme.secondaryTextColor),
                            fontSize: 12)),
                  ],
                ),
              ),
              SettingsRow(
                label: 'Spacing',
                description: 'Gap between elements',
                child: Row(
                  children: [
                    SizedBox(
                      width: 180,
                      child: Slider(
                        value: theme.spacing,
                        min: 2,
                        max: 24,
                        onChanged: (v) => themeNotifier.updateProperty(
                            (t) => t.copyWith(spacing: v)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('${theme.spacing.round()}px',
                        style: TextStyle(
                            color: Color(theme.secondaryTextColor),
                            fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          SettingsSection(
            title: 'Glow & Shadows',
            children: [
              SettingsRow(
                label: 'Enable Shadow',
                child: ToggleSwitch(
                  checked: theme.enableShadow,
                  onChanged: (v) => themeNotifier.updateProperty(
                      (t) => t.copyWith(enableShadow: v)),
                ),
              ),
              SettingsRow(
                label: 'Enable Glow',
                description: 'Accent color glow on cards',
                child: ToggleSwitch(
                  checked: theme.enableGlow,
                  onChanged: (v) => themeNotifier.updateProperty(
                      (t) => t.copyWith(enableGlow: v)),
                ),
              ),
              if (theme.enableGlow) ...[
                SettingsRow(
                  label: 'Glow Radius',
                  child: Row(
                    children: [
                      SizedBox(
                        width: 180,
                        child: Slider(
                          value: theme.glowRadius,
                          min: 2,
                          max: 40,
                          onChanged: (v) => themeNotifier.updateProperty(
                              (t) => t.copyWith(glowRadius: v)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('${theme.glowRadius.round()}px',
                          style: TextStyle(
                              color: Color(theme.secondaryTextColor),
                              fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 20),

          SettingsSection(
            title: 'Animations',
            children: [
              SettingsRow(
                label: 'Enable Animations',
                child: settingsAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (settings) => ToggleSwitch(
                    checked: settings.enableAnimations,
                    onChanged: (v) => ref
                        .read(settingsServiceProvider)
                        .updateSetting('enableAnimations', v),
                  ),
                ),
              ),
              SettingsRow(
                label: 'Animation Style',
                child: SizedBox(
                  width: 180,
                  child: ComboBox<String>(
                    value: theme.animationStyle,
                    items: const ['material', 'windows', 'none']
                        .map((s) => ComboBoxItem<String>(
                            value: s,
                            child: Text(s[0].toUpperCase() + s.substring(1))))
                        .toList(),
                    onChanged: (v) => themeNotifier.updateProperty(
                        (t) => t.copyWith(animationStyle: v)),
                  ),
                ),
              ),
              SettingsRow(
                label: 'Animation Speed',
                child: Row(
                  children: [
                    SizedBox(
                      width: 180,
                      child: Slider(
                        value: theme.animationSpeed,
                        min: 0.2,
                        max: 3.0,
                        onChanged: (v) => themeNotifier.updateProperty(
                            (t) => t.copyWith(animationSpeed: v)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('${theme.animationSpeed.toStringAsFixed(1)}x',
                        style: TextStyle(
                            color: Color(theme.secondaryTextColor),
                            fontSize: 12)),
                  ],
                ),
              ),
              SettingsRow(
                label: 'Particle Effects',
                description: 'Floating particles in background',
                child: ToggleSwitch(
                  checked: theme.enableParticles,
                  onChanged: (v) => themeNotifier.updateProperty(
                      (t) => t.copyWith(enableParticles: v)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String title;
  final String subtitle;
  const _Header({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(subtitle,
            style: TextStyle(
                color: Colors.grey.withOpacity(0.7), fontSize: 13)),
      ],
    );
  }
}

class _ColorRow extends ConsumerWidget {
  final String label;
  final Color color;
  final ValueChanged<Color> onChanged;

  const _ColorRow({
    required this.label,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SettingsRow(
      label: label,
      child: GestureDetector(
        onTap: () => _pickColor(context),
        child: Container(
          width: 40,
          height: 28,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
        ),
      ),
    );
  }

  Future<void> _pickColor(BuildContext context) async {
    Color picked = color;
    await showDialog(
      context: context,
      builder: (_) => ContentDialog(
        title: Text('Pick $label'),
        content: ColorPicker(
          color: color,
          onColorChanged: (c) => picked = c,
          width: 40,
          height: 40,
          borderRadius: 4,
          spacing: 5,
          runSpacing: 5,
          wheelDiameter: 200,
          heading: Text(label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          subheading: const Text('Select shade'),
        ),
        actions: [
          Button(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          FilledButton(
            child: const Text('Apply'),
            onPressed: () {
              onChanged(picked);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
