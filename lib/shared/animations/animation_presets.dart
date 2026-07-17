import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

// ─── Extension helpers ────────────────────────────────────────────────────────

extension AnimationExtensions on Widget {
  Widget fadeSlideIn({Duration delay = Duration.zero}) {
    return animate()
        .fadeIn(delay: delay, duration: 400.ms, curve: Curves.easeOut)
        .slideY(begin: 0.2, delay: delay, duration: 400.ms, curve: Curves.easeOut);
  }

  Widget fadeScaleIn({Duration delay = Duration.zero}) {
    return animate()
        .fadeIn(delay: delay, duration: 350.ms)
        .scale(
          begin: const Offset(0.9, 0.9),
          delay: delay,
          duration: 350.ms,
          curve: Curves.easeOut,
        );
  }

  Widget slideInFromLeft({Duration delay = Duration.zero}) {
    return animate()
        .fadeIn(delay: delay, duration: 400.ms)
        .slideX(begin: -0.3, delay: delay, duration: 400.ms, curve: Curves.easeOut);
  }

  Widget slideInFromRight({Duration delay = Duration.zero}) {
    return animate()
        .fadeIn(delay: delay, duration: 400.ms)
        .slideX(begin: 0.3, delay: delay, duration: 400.ms, curve: Curves.easeOut);
  }

  Widget staggerIn(int index, {int baseDelayMs = 50}) {
    final delay = Duration(milliseconds: baseDelayMs * index);
    return fadeSlideIn(delay: delay);
  }

  Widget pulse() {
    return animate(onPlay: (c) => c.repeat(reverse: true))
        .scaleXY(end: 1.05, duration: 1200.ms, curve: Curves.easeInOut);
  }

  Widget shimmer() {
    return animate(onPlay: (c) => c.repeat())
        .shimmer(duration: 2000.ms, color: Colors.white24);
  }
}

// ─── Page transitions ─────────────────────────────────────────────────────────

class FadeSlideTransition extends PageTransitionsBuilder {
  const FadeSlideTransition();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.04),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
        child: child,
      ),
    );
  }
}

// ─── Animated counter ─────────────────────────────────────────────────────────

class AnimatedCounter extends StatefulWidget {
  final double value;
  final String suffix;
  final TextStyle? style;
  final int decimalPlaces;

  const AnimatedCounter({
    super.key,
    required this.value,
    this.suffix = '',
    this.style,
    this.decimalPlaces = 0,
  });

  @override
  State<AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  double _prev = 0;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
    _anim = Tween<double>(begin: 0, end: widget.value).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void didUpdateWidget(AnimatedCounter old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value) {
      _prev = old.value;
      _anim = Tween<double>(begin: _prev, end: widget.value).animate(
          CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) {
        final v = _anim.value;
        final text = widget.decimalPlaces == 0
            ? '${v.round()}${widget.suffix}'
            : '${v.toStringAsFixed(widget.decimalPlaces)}${widget.suffix}';
        return Text(text, style: widget.style);
      },
    );
  }
}

// ─── Hover scale ─────────────────────────────────────────────────────────────

class HoverScaleWidget extends StatefulWidget {
  final Widget child;
  final double scale;
  final Duration duration;

  const HoverScaleWidget({
    super.key,
    required this.child,
    this.scale = 1.05,
    this.duration = const Duration(milliseconds: 150),
  });

  @override
  State<HoverScaleWidget> createState() => _HoverScaleWidgetState();
}

class _HoverScaleWidgetState extends State<HoverScaleWidget> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedScale(
        scale: _hovered ? widget.scale : 1.0,
        duration: widget.duration,
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
