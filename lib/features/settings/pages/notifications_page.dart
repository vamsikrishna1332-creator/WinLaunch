import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/app_providers.dart';
import '../../../shared/components/notice_bar.dart';
import '../widgets/settings_section.dart';
import '../widgets/settings_row.dart';

class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> {
  final List<TextEditingController> _controllers =
      List.generate(5, (_) => TextEditingController());
  bool _loaded = false;

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _loadIfNeeded(List<String> notices) {
    if (_loaded) return;
    _loaded = true;
    for (int i = 0; i < 5; i++) {
      _controllers[i].text = i < notices.length ? notices[i] : '';
    }
  }

  Future<void> _save() async {
    final svc = ref.read(settingsServiceProvider);
    final notices = _controllers
        .map((c) => c.text.trim())
        .where((t) => t.isNotEmpty)
        .toList();
    await svc.updateSetting('notices', notices);
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final settingsAsync = ref.watch(settingsProvider);
    final svc = ref.read(settingsServiceProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Notifications',
              style: TextStyle(
                  color: Color(theme.textColor),
                  fontSize: 22,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          settingsAsync.when(
            loading: () => const ProgressRing(),
            error: (_, __) => const Text('Error'),
            data: (s) {
              _loadIfNeeded(s.notices);
              return Column(
                children: [
                  // ── Alerts ──────────────────────────────────────────
                  SettingsSection(title: 'Alerts', children: [
                    SettingsRow(
                      label: 'Enable Notifications',
                      description: 'System tray and popup notifications',
                      child: ToggleSwitch(
                          checked: s.enableNotifications,
                          onChanged: (v) =>
                              svc.updateSetting('enableNotifications', v)),
                    ),
                    SettingsRow(
                      label: 'Enable Sounds',
                      description: 'Audio alerts for events',
                      child: ToggleSwitch(
                          checked: s.enableSounds,
                          onChanged: (v) =>
                              svc.updateSetting('enableSounds', v)),
                    ),
                  ]),

                  const SizedBox(height: 20),

                  // ── Notice Bar ───────────────────────────────────────
                  SettingsSection(
                    title: 'Notice Bar',
                    children: [
                      SettingsRow(
                        label: 'Show Notice Bar',
                        description:
                            'A scrolling ticker below the top bar',
                        child: ToggleSwitch(
                            checked: s.showNoticeBar,
                            onChanged: (v) =>
                                svc.updateSetting('showNoticeBar', v)),
                      ),

                      // Live preview (only when enabled)
                      if (s.showNoticeBar && s.notices.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: const NoticeBar(),
                        ),
                        const SizedBox(height: 8),
                      ],

                      // Notice inputs
                      const SizedBox(height: 4),
                      ...List.generate(5, (i) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              // Index badge
                              Container(
                                width: 24,
                                height: 24,
                                margin: const EdgeInsets.only(right: 10),
                                decoration: BoxDecoration(
                                  color: Color(theme.accentColor)
                                      .withOpacity(0.15),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: Color(theme.accentColor)
                                          .withOpacity(0.4)),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '${i + 1}',
                                  style: TextStyle(
                                    color: Color(theme.accentColor),
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              // Text field
                              Expanded(
                                child: TextBox(
                                  controller: _controllers[i],
                                  placeholder:
                                      i == 0 ? 'e.g. Welcome to LaunchDesk!' : 'Notice ${i + 1} (optional)',
                                  style: TextStyle(
                                      color: Color(theme.textColor),
                                      fontSize: 13),
                                  onChanged: (_) => _save(),
                                ),
                              ),
                              // Clear button
                              if (_controllers[i].text.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(left: 6),
                                  child: IconButton(
                                    icon: const Icon(FluentIcons.clear,
                                        size: 12),
                                    onPressed: () {
                                      setState(() =>
                                          _controllers[i].clear());
                                      _save();
                                    },
                                  ),
                                ),
                            ],
                          ),
                        );
                      }),

                      // Helper text
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'Notices scroll continuously in the bar below the top bar. '
                          'Leave a field blank to skip it. Max 5 notices.',
                          style: TextStyle(
                            color: Color(theme.secondaryTextColor),
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
