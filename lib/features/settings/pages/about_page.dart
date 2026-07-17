import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/app_providers.dart';
import '../../../shared/components/glass_container.dart';

class AboutPage extends ConsumerWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('About', style: TextStyle(color: Color(theme.textColor), fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          GlassContainer(
            child: Column(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Color(theme.accentColor),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(FluentIcons.rocket, size: 40, color: Colors.white),
                ),
                const SizedBox(height: 16),
                Text('LaunchDesk',
                    style: TextStyle(
                      color: Color(theme.textColor),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    )),
                const SizedBox(height: 4),
                Text('Version 1.0.0',
                    style: TextStyle(color: Color(theme.secondaryTextColor), fontSize: 13)),
                const SizedBox(height: 8),
                Text(
                  'A professional Windows productivity launcher with unlimited customization.',
                  style: TextStyle(color: Color(theme.secondaryTextColor), fontSize: 12),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 16),
                _InfoRow('Built with', 'Flutter + fluent_ui'),
                _InfoRow('Database', 'SQLite (sqflite_common_ffi)'),
                _InfoRow('State', 'Riverpod'),
                _InfoRow('License', 'MIT'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
          Text(value, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
