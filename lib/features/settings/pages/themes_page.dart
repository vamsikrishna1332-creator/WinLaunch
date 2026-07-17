import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/theme_model.dart';
import '../../../core/providers/app_providers.dart';
import '../../../shared/components/glass_container.dart';

class ThemesSettingsPage extends ConsumerWidget {
  const ThemesSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final themesAsync = ref.watch(allThemesProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text('Themes', style: TextStyle(color: Color(theme.textColor), fontSize: 22, fontWeight: FontWeight.bold)),
            const Spacer(),
            FilledButton(
              child: const Text('Create New Theme'),
              onPressed: () => Navigator.pushNamed(context, '/theme-editor'),
            ),
          ]),
          const SizedBox(height: 24),
          themesAsync.when(
            loading: () => const ProgressRing(),
            error: (_, __) => const Text('Error loading themes'),
            data: (themes) => Wrap(
              spacing: 16,
              runSpacing: 16,
              children: themes.map((t) => _ThemeCard(theme: t, current: theme)).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeCard extends ConsumerWidget {
  final LaunchDeskTheme theme;
  final LaunchDeskTheme current;

  const _ThemeCard({required this.theme, required this.current});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isActive = theme.id == current.id;

    return GestureDetector(
      onTap: () => ref.read(themeProvider.notifier).applyTheme(theme),
      child: SizedBox(
        width: 180,
        child: GlassContainer(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Color preview
              Container(
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: theme.gradientColors.map((c) => Color(c)).toList(),
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: 8, top: 8,
                      child: Container(
                        width: 20, height: 20,
                        decoration: BoxDecoration(
                          color: Color(theme.accentColor),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    if (isActive)
                      Positioned(
                        left: 8, top: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Color(theme.accentColor),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text('Active', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(theme.name, style: TextStyle(
                color: Color(current.textColor),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              )),
              if (theme.description.isNotEmpty)
                Text(theme.description, style: TextStyle(
                  color: Color(current.secondaryTextColor),
                  fontSize: 10,
                ), maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 8),
              Text('by ${theme.author}', style: TextStyle(
                color: Color(current.secondaryTextColor),
                fontSize: 10,
              )),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(
                  child: Button(
                    child: const Text('Apply', style: TextStyle(fontSize: 11)),
                    onPressed: () => ref.read(themeProvider.notifier).applyTheme(theme),
                  ),
                ),
                const SizedBox(width: 4),
                Button(
                  child: const Icon(FluentIcons.edit, size: 12),
                  onPressed: () => Navigator.pushNamed(context, '/theme-editor'),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}
