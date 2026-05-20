import 'package:flutter/material.dart';

import '../utils/human_comfort_sensor.dart';

/// Full-screen soft red pulse when outdoor air is unbearable (sensor alert).
class TemperatureAlertOverlay extends StatefulWidget {
  const TemperatureAlertOverlay({
    super.key,
    required this.level,
    this.active = true,
  });

  final ComfortLevel level;
  final bool active;

  @override
  State<TemperatureAlertOverlay> createState() => _TemperatureAlertOverlayState();
}

class _TemperatureAlertOverlayState extends State<TemperatureAlertOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _blink;

  @override
  void initState() {
    super.initState();
    _blink = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _blink.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.active || !widget.level.shouldBlinkAlert) {
      return const SizedBox.shrink();
    }

    final color = widget.level == ComfortLevel.danger
        ? const Color(0xFFD32F2F)
        : const Color(0xFFE65100);

    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _blink,
        builder: (context, child) {
          final t = _blink.value;
          return Stack(
            children: [
              // Edge glow — "blinking light" around the screen
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 1.1,
                      colors: [
                        Colors.transparent,
                        color.withValues(alpha: 0.08 + t * 0.18),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 6,
                child: ColoredBox(
                  color: color.withValues(alpha: 0.35 + t * 0.55),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: 6,
                child: ColoredBox(
                  color: color.withValues(alpha: 0.35 + t * 0.55),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Blinking LED dot + label for the comfort sensor.
class BlinkingSensorLed extends StatefulWidget {
  const BlinkingSensorLed({
    super.key,
    required this.active,
    required this.color,
    this.label = 'SENSING',
  });

  final bool active;
  final Color color;
  final String label;

  @override
  State<BlinkingSensorLed> createState() => _BlinkingSensorLedState();
}

class _BlinkingSensorLedState extends State<BlinkingSensorLed>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _updatePulse();
  }

  @override
  void didUpdateWidget(BlinkingSensorLed oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updatePulse();
  }

  void _updatePulse() {
    if (widget.active) {
      _pulse.repeat(reverse: true);
    } else {
      _pulse.stop();
      _pulse.value = 1;
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, _) {
        final glow = widget.active ? 0.4 + _pulse.value * 0.6 : 0.3;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color.withValues(alpha: glow),
                boxShadow: widget.active
                    ? [
                        BoxShadow(
                          color: widget.color.withValues(alpha: glow),
                          blurRadius: 8 + _pulse.value * 6,
                          spreadRadius: 1 + _pulse.value * 2,
                        ),
                      ]
                    : null,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              widget.label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: widget.color,
              ),
            ),
          ],
        );
      },
    );
  }
}
