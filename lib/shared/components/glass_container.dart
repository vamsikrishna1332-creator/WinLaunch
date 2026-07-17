import 'dart:ui';
import 'package:fluent_ui/fluent_ui.dart';
import '../../core/providers/app_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GlassContainer extends ConsumerWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? borderRadius;
  final VoidCallback? onTap;
  final bool interactive;

  const GlassContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius,
    this.onTap,
    this.interactive = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final radius = borderRadius ?? theme.cardBorderRadius;
    final glass = theme.enableGlass;
    final opacity = theme.glassOpacity;
    final tint = Color(theme.glassTint);
    final borderOp = theme.glassBorderOpacity;
    final shadow = theme.enableShadow;
    final blur = theme.blurAmount;

    Widget container = ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: glass
            ? ImageFilter.blur(sigmaX: blur, sigmaY: blur)
            : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
        child: Container(
          width: width,
          height: height,
          padding: padding ?? EdgeInsets.all(theme.cardPadding),
          decoration: BoxDecoration(
            color: glass
                ? tint.withOpacity(opacity)
                : Color(theme.cardColor).withOpacity(0.9),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: Colors.white.withOpacity(borderOp),
              width: 1.0,
            ),
            boxShadow: shadow
                ? [
                    BoxShadow(
                      color: Color(theme.shadowColor),
                      blurRadius: theme.shadowBlur,
                      offset: const Offset(0, 4),
                    ),
                    if (theme.enableGlow)
                      BoxShadow(
                        color: Color(theme.glowColor).withOpacity(0.3),
                        blurRadius: theme.glowRadius * 2,
                        spreadRadius: -2,
                      ),
                  ]
                : [],
          ),
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      container = GestureDetector(
        onTap: onTap,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: container,
        ),
      );
    }

    return Container(
      margin: margin,
      child: container,
    );
  }
}

// Minimal non-consumer glass for non-Riverpod contexts
class RawGlassContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final double blurAmount;
  final double opacity;
  final double borderRadius;
  final Color? tintColor;
  final VoidCallback? onTap;

  const RawGlassContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.blurAmount = 10,
    this.opacity = 0.15,
    this.borderRadius = 12,
    this.tintColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget container = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurAmount, sigmaY: blurAmount),
        child: Container(
          width: width,
          height: height,
          padding: padding ?? const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: (tintColor ?? Colors.white).withOpacity(opacity),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: container);
    }
    return container;
  }
}
