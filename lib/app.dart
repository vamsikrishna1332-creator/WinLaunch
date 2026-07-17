import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import 'core/models/enums.dart';
import 'core/providers/app_providers.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/themes/theme_editor_screen.dart';
import 'shared/components/startup_splash.dart';

class LaunchDeskApp extends ConsumerStatefulWidget {
  const LaunchDeskApp({super.key});

  @override
  ConsumerState<LaunchDeskApp> createState() => _LaunchDeskAppState();
}

class _LaunchDeskAppState extends ConsumerState<LaunchDeskApp>
    with WindowListener {
  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowResize() {
    windowManager.getSize().then((size) {
      ref.read(settingsServiceProvider).updateWindowSize(
            size.width.toInt(),
            size.height.toInt(),
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeProvider);
    final settingsAsync = ref.watch(settingsProvider);

    return settingsAsync.when(
      loading: () => const StartupSplash(),
      error: (e, s) => FluentApp(
        title: 'LaunchDesk',
        theme: FluentThemeData.dark(),
        home: const ErrorScreen(),
      ),
      data: (settings) {
        final fluentTheme = themeState.toFluentTheme();

        return FluentApp(
          title: settings.appName,
          theme: fluentTheme,
          darkTheme: themeState.isDark
              ? fluentTheme
              : FluentThemeData.dark().copyWith(
                  accentColor: fluentTheme.accentColor,
                ),
          themeMode: themeState.themeMode,
          debugShowCheckedModeBanner: false,
          builder: (context, child) {
            return _AppShell(child: child ?? const SizedBox());
          },
          routes: {
            '/': (context) => const DashboardScreen(),
            '/settings': (context) => const SettingsScreen(),
            '/theme-editor': (context) => const ThemeEditorScreen(),
          },
          initialRoute: '/',
        );
      },
    );
  }
}

class _AppShell extends ConsumerWidget {
  final Widget child;
  const _AppShell({required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);

    return Stack(
      children: [
        // Animated background
        if (themeState.backgroundType == BackgroundType.color)
          Container(color: themeState.backgroundColor),

        if (themeState.backgroundType == BackgroundType.gradient)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: themeState.gradientColors,
              ),
            ),
          ),

        if (themeState.backgroundType == BackgroundType.image &&
            themeState.backgroundImagePath != null)
          Positioned.fill(
            child: Image.asset(
              themeState.backgroundImagePath!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: themeState.backgroundColor,
              ),
            ),
          ),

        // Particle effect overlay
        if (themeState.enableParticles)
          Positioned.fill(
            child: ParticleOverlay(config: themeState.particleConfig),
          ),

        // Main content
        child,
      ],
    );
  }
}

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      content: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(FluentIcons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text('Failed to load LaunchDesk settings.',
                style: TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Button(
              child: const Text('Retry'),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class ParticleOverlay extends StatelessWidget {
  final ParticleConfig config;
  const ParticleOverlay({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    // Particle engine placeholder - uses CustomPainter
    return CustomPaint(painter: ParticlePainter(config: config));
  }
}

class ParticlePainter extends CustomPainter {
  final ParticleConfig config;
  ParticlePainter({required this.config});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = config.color.withOpacity(0.3)
      ..strokeWidth = config.size;
    // Minimal particle dots
    for (int i = 0; i < config.count; i++) {
      final x = (i * 37.0) % size.width;
      final y = (i * 53.0) % size.height;
      canvas.drawCircle(Offset(x, y), config.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

