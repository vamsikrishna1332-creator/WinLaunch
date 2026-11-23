import 'package:fluent_ui/fluent_ui.dart' hide ColorPicker;
import 'package:flutter/material.dart' as material;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:uuid/uuid.dart';
import '../../core/models/theme_model.dart';
import '../../core/providers/app_providers.dart';
import '../../shared/components/glass_container.dart';

class ThemeEditorScreen extends ConsumerStatefulWidget {
  const ThemeEditorScreen({super.key});

  @override
  ConsumerState<ThemeEditorScreen> createState() => _ThemeEditorScreenState();
}

class _ThemeEditorScreenState extends ConsumerState<ThemeEditorScreen> {
  late LaunchDeskTheme _draft;
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  int _tab = 0;

  final _tabLabels = ['Colors', 'Typography', 'Glass', 'Shapes', 'Effects', 'Export'];

  @override
  void initState() {
    super.initState();
    _draft = ref.read(themeProvider);
    _nameCtrl.text = _draft.name;
    _descCtrl.text = _draft.description;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);

    return material.Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // Header
          GlassContainer(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            borderRadius: 0,
            child: Row(
              children: [
                Button(
                  child: Row(children: const [
                    Icon(FluentIcons.chrome_back, size: 14),
                    SizedBox(width: 4),
                    Text('Back'),
                  ]),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 16),
                Text('Theme Editor',
                    style: TextStyle(
                      color: Color(theme.textColor),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    )),
                const Spacer(),
                Button(
                  child: const Text('Reset'),
                  onPressed: () => setState(() {
                    _draft = ref.read(themeProvider);
                    _nameCtrl.text = _draft.name;
                  }),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  child: const Text('Save & Apply'),
                  onPressed: _saveAndApply,
                ),
                const SizedBox(width: 8),
                Button(
                  child: const Text('Save as New'),
                  onPressed: _saveAsNew,
                ),
              ],
            ),
          ),

          Expanded(
            child: Row(
              children: [
                // Left: Editor panels
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      // Tab bar
                      GlassContainer(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        borderRadius: 0,
                        child: Row(
                          children: List.generate(_tabLabels.length, (i) {
                            final sel = i == _tab;
                            return Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: GestureDetector(
                                onTap: () => setState(() => _tab = i),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: sel ? Color(_draft.accentColor).withOpacity(0.2) : Colors.transparent,
                                    borderRadius: BorderRadius.circular(6),
                                    border: sel ? Border.all(color: Color(_draft.accentColor).withOpacity(0.4)) : null,
                                  ),
                                  child: Text(_tabLabels[i],
                                      style: TextStyle(
                                        color: sel ? Color(_draft.accentColor) : Color(_draft.secondaryTextColor),
                                        fontSize: 12,
                                        fontWeight: sel ? FontWeight.w600 : FontWeight.normal,
                                      )),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),

                      // Editor content
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(20),
                          child: _buildTabContent(),
                        ),
                      ),
                    ],
                  ),
                ),

                // Right: Live preview
                SizedBox(
                  width: 300,
                  child: _ThemePreview(draft: _draft),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_tab) {
      case 0: return _ColorsTab(draft: _draft, onChanged: (d) => setState(() => _draft = d));
      case 1: return _TypographyTab(draft: _draft, onChanged: (d) => setState(() => _draft = d));
      case 2: return _GlassTab(draft: _draft, onChanged: (d) => setState(() => _draft = d));
      case 3: return _ShapesTab(draft: _draft, onChanged: (d) => setState(() => _draft = d));
      case 4: return _EffectsTab(draft: _draft, onChanged: (d) => setState(() => _draft = d));
      case 5: return _ExportTab(draft: _draft);
      default: return const SizedBox.shrink();
    }
  }

  Future<void> _saveAndApply() async {
    final updated = _draft.copyWith(
      name: _nameCtrl.text.trim().isEmpty ? _draft.name : _nameCtrl.text.trim(),
    );
    await ref.read(themeProvider.notifier).applyTheme(updated);
    if (mounted) Navigator.pop(context);
  }

  Future<void> _saveAsNew() async {
    final newTheme = LaunchDeskTheme(
      id: const Uuid().v4(),
      name: _nameCtrl.text.trim().isEmpty ? '${_draft.name} (Copy)' : _nameCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      author: 'User',
      version: '1.0.0',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      backgroundColor: _draft.backgroundColor,
      surfaceColor: _draft.surfaceColor,
      cardColor: _draft.cardColor,
      accentColor: _draft.accentColor,
      textColor: _draft.textColor,
      secondaryTextColor: _draft.secondaryTextColor,
      borderColor: _draft.borderColor,
      errorColor: _draft.errorColor,
      successColor: _draft.successColor,
      warningColor: _draft.warningColor,
      gradientColors: _draft.gradientColors,
      backgroundType: _draft.backgroundType,
      backgroundOpacity: _draft.backgroundOpacity,
      enableGlass: _draft.enableGlass,
      glassOpacity: _draft.glassOpacity,
      glassBorderOpacity: _draft.glassBorderOpacity,
      fontFamily: _draft.fontFamily,
      baseFontSize: _draft.baseFontSize,
      borderRadius: _draft.borderRadius,
      cardBorderRadius: _draft.cardBorderRadius,
      spacing: _draft.spacing,
      margin: _draft.margin,
      padding: _draft.padding,
      enableShadow: _draft.enableShadow,
      enableGlow: _draft.enableGlow,
      glowRadius: _draft.glowRadius,
      glowColor: _draft.glowColor,
      animationStyle: _draft.animationStyle,
      animationSpeed: _draft.animationSpeed,
      enableParticles: _draft.enableParticles,
      buttonStyle: _draft.buttonStyle,
      cardStyle: _draft.cardStyle,
      isDark: _draft.isDark,
      customVariables: _draft.customVariables,
    );
    await ref.read(themeServiceProvider).saveTheme(newTheme);
    ref.invalidate(allThemesProvider);
    if (mounted) {
      displayInfoBar(context, builder: (_, close) => InfoBar(
        title: Text('Theme "${newTheme.name}" saved!'),
        severity: InfoBarSeverity.success,
        onClose: close,
      ));
    }
  }
}

class _ColorProp extends StatelessWidget {
  final String label;
  final Color color;
  final ValueChanged<Color> onChanged;

  const _ColorProp({required this.label, required this.color, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(width: 160, child: Text(label, style: const TextStyle(fontSize: 12))),
          GestureDetector(
            onTap: () => _pick(context),
            child: Container(
              width: 36,
              height: 24,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text('#${color.value.toRadixString(16).padLeft(8, '0').toUpperCase()}',
              style: const TextStyle(fontSize: 10, fontFamily: 'monospace')),
        ],
      ),
    );
  }

  Future<void> _pick(BuildContext context) async {
    Color picked = color;
    await showDialog(
      context: context,
      builder: (_) => ContentDialog(
        title: Text(label),
        content: ColorPicker(
          color: color,
          onColorChanged: (c) => picked = c,
          width: 36, height: 36, borderRadius: 4,
          colorPickerType: ColorPickerType.both,
        ),
        actions: [
          Button(child: const Text('Cancel'), onPressed: () => Navigator.pop(context)),
          FilledButton(
            child: const Text('Apply'),
            onPressed: () { onChanged(picked); Navigator.pop(context); },
          ),
        ],
      ),
    );
  }
}

class _ColorsTab extends StatelessWidget {
  final LaunchDeskTheme draft;
  final ValueChanged<LaunchDeskTheme> onChanged;
  const _ColorsTab({required this.draft, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      _ColorProp(label: 'Accent', color: Color(draft.accentColor), onChanged: (c) => onChanged(draft.copyWith(accentColor: c.value))),
      _ColorProp(label: 'Background', color: Color(draft.backgroundColor), onChanged: (c) => onChanged(draft.copyWith(backgroundColor: c.value))),
      _ColorProp(label: 'Surface', color: Color(draft.surfaceColor), onChanged: (c) => onChanged(draft.copyWith(surfaceColor: c.value))),
      _ColorProp(label: 'Card', color: Color(draft.cardColor), onChanged: (c) => onChanged(draft.copyWith(cardColor: c.value))),
      _ColorProp(label: 'Text', color: Color(draft.textColor), onChanged: (c) => onChanged(draft.copyWith(textColor: c.value))),
      _ColorProp(label: 'Secondary Text', color: Color(draft.secondaryTextColor), onChanged: (c) => onChanged(draft.copyWith(secondaryTextColor: c.value))),
    ]);
  }
}

class _TypographyTab extends StatelessWidget {
  final LaunchDeskTheme draft;
  final ValueChanged<LaunchDeskTheme> onChanged;
  const _TypographyTab({required this.draft, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Font Family', style: TextStyle(fontSize: 12)),
      const SizedBox(height: 6),
      ComboBox<String>(
        value: draft.fontFamily,
        items: ['Segoe UI', 'Cascadia Code', 'Arial', 'Consolas', 'Verdana', 'Georgia']
            .map((f) => ComboBoxItem<String>(value: f, child: Text(f))).toList(),
        onChanged: (v) => onChanged(draft.copyWith(fontFamily: v)),
      ),
      const SizedBox(height: 16),
      const Text('Base Font Size', style: TextStyle(fontSize: 12)),
      const SizedBox(height: 6),
      Row(children: [
        Expanded(child: Slider(
          value: draft.baseFontSize, min: 10, max: 24, divisions: 14,
          onChanged: (v) => onChanged(draft.copyWith(baseFontSize: v)),
        )),
        const SizedBox(width: 8),
        Text('${draft.baseFontSize.round()}pt'),
      ]),
      const SizedBox(height: 16),
      Row(children: [
        const Text('Dark Mode', style: TextStyle(fontSize: 12)),
        const SizedBox(width: 12),
        ToggleSwitch(checked: draft.isDark, onChanged: (v) => onChanged(draft.copyWith(isDark: v))),
      ]),
    ]);
  }
}

class _GlassTab extends StatelessWidget {
  final LaunchDeskTheme draft;
  final ValueChanged<LaunchDeskTheme> onChanged;
  const _GlassTab({required this.draft, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const Text('Enable Glass', style: TextStyle(fontSize: 12)),
        const SizedBox(width: 12),
        ToggleSwitch(checked: draft.enableGlass, onChanged: (v) => onChanged(draft.copyWith(enableGlass: v))),
      ]),
      const SizedBox(height: 16),
      const Text('Glass Opacity', style: TextStyle(fontSize: 12)),
      Row(children: [
        Expanded(child: Slider(value: draft.glassOpacity, min: 0, max: 0.8, onChanged: (v) => onChanged(draft.copyWith(glassOpacity: v)))),
        const SizedBox(width: 8),
        Text('${(draft.glassOpacity * 100).round()}%'),
      ]),
      const SizedBox(height: 12),
      const Text('Blur Amount', style: TextStyle(fontSize: 12)),
      Row(children: [
        Expanded(child: Slider(value: draft.blurAmount, min: 0, max: 40, onChanged: (v) => onChanged(draft.copyWith(blurAmount: v)))),
        const SizedBox(width: 8),
        Text('${draft.blurAmount.round()}px'),
      ]),
    ]);
  }
}

class _ShapesTab extends StatelessWidget {
  final LaunchDeskTheme draft;
  final ValueChanged<LaunchDeskTheme> onChanged;
  const _ShapesTab({required this.draft, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Card Border Radius', style: TextStyle(fontSize: 12)),
      Row(children: [
        Expanded(child: Slider(value: draft.cardBorderRadius, min: 0, max: 32, divisions: 32, onChanged: (v) => onChanged(draft.copyWith(cardBorderRadius: v)))),
        const SizedBox(width: 8),
        Text('${draft.cardBorderRadius.round()}px'),
      ]),
      const SizedBox(height: 12),
      const Text('Spacing', style: TextStyle(fontSize: 12)),
      Row(children: [
        Expanded(child: Slider(value: draft.spacing, min: 2, max: 24, onChanged: (v) => onChanged(draft.copyWith(spacing: v)))),
        const SizedBox(width: 8),
        Text('${draft.spacing.round()}px'),
      ]),
      const SizedBox(height: 12),
      const Text('Padding', style: TextStyle(fontSize: 12)),
      Row(children: [
        Expanded(child: Slider(value: draft.padding, min: 8, max: 40, onChanged: (v) => onChanged(draft.copyWith(padding: v)))),
        const SizedBox(width: 8),
        Text('${draft.padding.round()}px'),
      ]),
      const SizedBox(height: 16),
      const Text('Button Style', style: TextStyle(fontSize: 12)),
      const SizedBox(height: 6),
      ComboBox<String>(
        value: draft.buttonStyle,
        items: ['filled', 'outline', 'ghost', 'glass']
            .map((s) => ComboBoxItem<String>(value: s, child: Text(s[0].toUpperCase() + s.substring(1)))).toList(),
        onChanged: (v) => onChanged(draft.copyWith(buttonStyle: v)),
      ),
      const SizedBox(height: 16),
      const Text('Card Style', style: TextStyle(fontSize: 12)),
      const SizedBox(height: 6),
      ComboBox<String>(
        value: draft.cardStyle,
        items: ['flat', 'elevated', 'glass', 'bordered']
            .map((s) => ComboBoxItem<String>(value: s, child: Text(s[0].toUpperCase() + s.substring(1)))).toList(),
        onChanged: (v) => onChanged(draft.copyWith(cardStyle: v)),
      ),
    ]);
  }
}

class _EffectsTab extends StatelessWidget {
  final LaunchDeskTheme draft;
  final ValueChanged<LaunchDeskTheme> onChanged;
  const _EffectsTab({required this.draft, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const Text('Enable Glow', style: TextStyle(fontSize: 12)),
        const SizedBox(width: 12),
        ToggleSwitch(checked: draft.enableGlow, onChanged: (v) => onChanged(draft.copyWith(enableGlow: v))),
      ]),
      const SizedBox(height: 12),
      const Text('Glow Radius', style: TextStyle(fontSize: 12)),
      Row(children: [
        Expanded(child: Slider(value: draft.glowRadius, min: 2, max: 40, onChanged: (v) => onChanged(draft.copyWith(glowRadius: v)))),
        const SizedBox(width: 8),
        Text('${draft.glowRadius.round()}px'),
      ]),
      const SizedBox(height: 16),
      Row(children: [
        const Text('Particle Effects', style: TextStyle(fontSize: 12)),
        const SizedBox(width: 12),
        ToggleSwitch(checked: draft.enableParticles, onChanged: (v) => onChanged(draft.copyWith(enableParticles: v))),
      ]),
      const SizedBox(height: 16),
      const Text('Animation Style', style: TextStyle(fontSize: 12)),
      const SizedBox(height: 6),
      ComboBox<String>(
        value: draft.animationStyle,
        items: ['material', 'windows', 'none']
            .map((s) => ComboBoxItem<String>(value: s, child: Text(s[0].toUpperCase() + s.substring(1)))).toList(),
        onChanged: (v) => onChanged(draft.copyWith(animationStyle: v)),
      ),
      const SizedBox(height: 12),
      const Text('Animation Speed', style: TextStyle(fontSize: 12)),
      Row(children: [
        Expanded(child: Slider(value: draft.animationSpeed, min: 0.2, max: 3.0, onChanged: (v) => onChanged(draft.copyWith(animationSpeed: v)))),
        const SizedBox(width: 8),
        Text('${draft.animationSpeed.toStringAsFixed(1)}x'),
      ]),
    ]);
  }
}

class _ExportTab extends ConsumerWidget {
  final LaunchDeskTheme draft;
  const _ExportTab({required this.draft});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Export / Import Theme', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      const SizedBox(height: 16),
      FilledButton(
        child: const Text('Export Theme as JSON'),
        onPressed: () async {
          final json = await ref.read(themeServiceProvider).exportTheme(draft);
          if (context.mounted) {
            showDialog(
              context: context,
              builder: (_) => ContentDialog(
                title: const Text('Theme JSON'),
                content: SizedBox(
                  height: 300,
                  child: SingleChildScrollView(
                    child: SelectableText(json, style: const TextStyle(fontSize: 11, fontFamily: 'monospace')),
                  ),
                ),
                actions: [
                  Button(child: const Text('Close'), onPressed: () => Navigator.pop(context)),
                ],
              ),
            );
          }
        },
      ),
    ]);
  }
}

class _ThemePreview extends StatelessWidget {
  final LaunchDeskTheme draft;
  const _ThemePreview({required this.draft});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(draft.backgroundColor),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Preview', style: TextStyle(color: Color(draft.secondaryTextColor), fontSize: 11, letterSpacing: 1)),
          const SizedBox(height: 12),
          _PreviewCard(draft: draft, title: 'Good Morning', subtitle: 'Your day at a glance'),
          const SizedBox(height: 8),
          _PreviewCard(draft: draft, title: 'Widget Card', subtitle: 'Sample content here'),
          const SizedBox(height: 12),
          Row(children: [
            _PreviewButton(draft: draft, label: 'Primary', filled: true),
            const SizedBox(width: 8),
            _PreviewButton(draft: draft, label: 'Secondary', filled: false),
          ]),
          const SizedBox(height: 12),
          // Color swatches
          Wrap(
            spacing: 6,
            children: [
              draft.accentColor, draft.textColor, draft.cardColor,
              draft.backgroundColor, draft.errorColor, draft.successColor,
            ].map((c) => Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                color: Color(c),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.white.withOpacity(0.15)),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  final LaunchDeskTheme draft;
  final String title;
  final String subtitle;
  const _PreviewCard({required this.draft, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color(draft.cardColor).withOpacity(draft.glassOpacity + 0.3),
        borderRadius: BorderRadius.circular(draft.cardBorderRadius),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: TextStyle(color: Color(draft.textColor), fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 2),
        Text(subtitle, style: TextStyle(color: Color(draft.secondaryTextColor), fontSize: 10)),
      ]),
    );
  }
}

class _PreviewButton extends StatelessWidget {
  final LaunchDeskTheme draft;
  final String label;
  final bool filled;
  const _PreviewButton({required this.draft, required this.label, required this.filled});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: filled ? Color(draft.accentColor) : Colors.transparent,
        borderRadius: BorderRadius.circular(draft.buttonBorderRadius),
        border: Border.all(color: Color(draft.accentColor).withOpacity(filled ? 0 : 0.6)),
      ),
      child: Text(label, style: TextStyle(
        color: filled ? Colors.white : Color(draft.accentColor),
        fontSize: 11,
        fontWeight: FontWeight.w500,
      )),
    );
  }
}
