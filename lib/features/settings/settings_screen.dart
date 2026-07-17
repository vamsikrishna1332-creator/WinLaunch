import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/providers/app_providers.dart';
import '../../shared/components/glass_container.dart';
import 'pages/appearance_page.dart';
import 'pages/launcher_page.dart';
import 'pages/schedule_page.dart';
import 'pages/widgets_page.dart';
import 'pages/themes_page.dart';
import 'pages/notifications_page.dart';
import 'pages/backup_page.dart';
import 'pages/accessibility_page.dart';
import 'pages/performance_page.dart';
import 'pages/advanced_page.dart';
import 'pages/about_page.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  int _selectedIndex = 0;

  final List<_SettingItem> _items = [
    _SettingItem(FluentIcons.color, 'Appearance', 'Colors, fonts, effects'),
    _SettingItem(FluentIcons.app_icon_default, 'Launcher', 'App grid & shortcuts'),
    _SettingItem(FluentIcons.calendar, 'Schedule', 'Time & task settings'),
    _SettingItem(FluentIcons.web_components, 'Widgets', 'Widget board settings'),
    _SettingItem(FluentIcons.paint_bucket, 'Themes', 'Theme engine & editor'),
    _SettingItem(FluentIcons.ringer, 'Notifications', 'Alerts & sounds'),
    _SettingItem(FluentIcons.save, 'Backup', 'Import & export data'),
    _SettingItem(FluentIcons.accessibility_checker, 'Accessibility', 'Visual & input aids'),
    _SettingItem(FluentIcons.speed_high, 'Performance', 'Startup & memory'),
    _SettingItem(FluentIcons.settings, 'Advanced', 'Developer & power user'),
    _SettingItem(FluentIcons.info, 'About', 'Version & licenses'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);

    return Scaffold(
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
                  child: Row(
                    children: const [
                      Icon(FluentIcons.chrome_back, size: 14),
                      SizedBox(width: 4),
                      Text('Back'),
                    ],
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 16),
                Text(
                  'Settings',
                  style: TextStyle(
                    color: Color(theme.textColor),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: theme.fontFamily,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: Row(
              children: [
                // Sidebar
                SizedBox(
                  width: 220,
                  child: GlassContainer(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    borderRadius: 0,
                    child: ListView.builder(
                      itemCount: _items.length,
                      itemBuilder: (_, i) {
                        final item = _items[i];
                        final selected = i == _selectedIndex;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedIndex = i),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: selected
                                    ? Color(theme.accentColor).withOpacity(0.15)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                border: selected
                                    ? Border.all(
                                        color: Color(theme.accentColor)
                                            .withOpacity(0.4))
                                    : null,
                              ),
                              child: Row(
                                children: [
                                  Icon(item.icon,
                                      size: 16,
                                      color: selected
                                          ? Color(theme.accentColor)
                                          : Color(theme.secondaryTextColor)),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(item.label,
                                            style: TextStyle(
                                              color: selected
                                                  ? Color(theme.accentColor)
                                                  : Color(theme.textColor),
                                              fontSize: 13,
                                              fontWeight: selected
                                                  ? FontWeight.w600
                                                  : FontWeight.normal,
                                            )),
                                        Text(item.subtitle,
                                            style: TextStyle(
                                              color: Color(
                                                  theme.secondaryTextColor),
                                              fontSize: 10,
                                            )),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ).animate().slideX(begin: -0.1, duration: 300.ms),

                // Content
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: KeyedSubtree(
                      key: ValueKey(_selectedIndex),
                      child: _buildPage(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage() {
    switch (_selectedIndex) {
      case 0: return const AppearancePage();
      case 1: return const LauncherSettingsPage();
      case 2: return const ScheduleSettingsPage();
      case 3: return const WidgetsSettingsPage();
      case 4: return const ThemesSettingsPage();
      case 5: return const NotificationsPage();
      case 6: return const BackupPage();
      case 7: return const AccessibilityPage();
      case 8: return const PerformancePage();
      case 9: return const AdvancedPage();
      case 10: return const AboutPage();
      default: return const AppearancePage();
    }
  }
}

class _SettingItem {
  final IconData icon;
  final String label;
  final String subtitle;
  const _SettingItem(this.icon, this.label, this.subtitle);
}
