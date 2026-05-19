import 'package:flutter/material.dart';

/// Shared curves and durations for consistent motion across the app.
abstract final class AppMotion {
  static const Duration fast = Duration(milliseconds: 280);
  static const Duration medium = Duration(milliseconds: 450);
  static const Duration slow = Duration(milliseconds: 650);
  static const Duration staggerStep = Duration(milliseconds: 70);

  static const Curve smooth = Curves.easeOutCubic;
  static const Curve enter = Curves.easeOutBack;
  static const Curve exit = Curves.easeInCubic;
}

/// Fades and slides a child in on first build (optional delay for stagger).
class FadeSlideIn extends StatefulWidget {
  const FadeSlideIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = AppMotion.medium,
    this.offsetY = 24,
    this.curve = AppMotion.smooth,
  });

  final Widget child;
  final Duration delay;
  final Duration duration;
  final double offsetY;
  final Curve curve;

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _fade = CurvedAnimation(parent: _controller, curve: widget.curve);
    _slide = Tween<Offset>(
      begin: Offset(0, widget.offsetY / 200),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));

    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future<void>.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}

/// Gentle floating motion for weather emoji icons.
class FloatingEmoji extends StatefulWidget {
  const FloatingEmoji({
    super.key,
    required this.emoji,
    this.size = 72,
  });

  final String emoji;
  final double size;

  @override
  State<FloatingEmoji> createState() => _FloatingEmojiState();
}

class _FloatingEmojiState extends State<FloatingEmoji>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _offset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);
    _offset = Tween<double>(begin: 0, end: -10).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _offset,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _offset.value),
          child: child,
        );
      },
      child: Text(widget.emoji, style: TextStyle(fontSize: widget.size)),
    );
  }
}

/// Slowly shifting gradient backdrop.
class AnimatedGradientBackground extends StatefulWidget {
  const AnimatedGradientBackground({super.key, required this.child});

  final Widget child;

  @override
  State<AnimatedGradientBackground> createState() =>
      _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<AnimatedGradientBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  static const _colors = [
    Color(0xFF3D7EC9),
    Color(0xFF4A90D9),
    Color(0xFF5BA3E8),
    Color(0xFF7BB8EE),
    Color(0xFF5BA3E8),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(
                -1 + _controller.value * 0.6,
                -1,
              ),
              end: Alignment(
                1 - _controller.value * 0.4,
                1,
              ),
              colors: _colors,
            ),
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// Cross-fades between children with a subtle scale.
class SmoothSwitcher extends StatelessWidget {
  const SmoothSwitcher({
    super.key,
    required this.child,
    required this.transitionKey,
    this.duration = AppMotion.medium,
  });

  final Widget child;
  final Object transitionKey;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      switchInCurve: AppMotion.smooth,
      switchOutCurve: AppMotion.exit,
      transitionBuilder: (child, animation) {
        final slide = Tween<Offset>(
          begin: const Offset(0, 0.06),
          end: Offset.zero,
        ).animate(animation);
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(position: slide, child: child),
        );
      },
      child: KeyedSubtree(
        key: ValueKey(transitionKey),
        child: child,
      ),
    );
  }
}
