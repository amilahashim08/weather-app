import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/weather.dart';
import '../providers/weather_provider.dart';
import '../theme/app_theme.dart';
import '../utils/animations.dart';
import '../utils/human_comfort_sensor.dart';
import 'google_surface_card.dart';
import 'temperature_alert_overlay.dart';

/// Outdoor comfort sensor — blinks until user confirms precautions.
class ComfortAdvisoryCard extends StatefulWidget {
  const ComfortAdvisoryCard({super.key, required this.bundle});

  final WeatherBundle bundle;

  @override
  State<ComfortAdvisoryCard> createState() => _ComfortAdvisoryCardState();
}

class _ComfortAdvisoryCardState extends State<ComfortAdvisoryCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _borderBlink;

  @override
  void initState() {
    super.initState();
    _borderBlink = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
  }

  @override
  void dispose() {
    _borderBlink.dispose();
    super.dispose();
  }

  void _syncBlink(bool shouldBlink) {
    if (shouldBlink) {
      if (!_borderBlink.isAnimating) {
        _borderBlink.repeat(reverse: true);
      }
    } else {
      _borderBlink.stop();
      _borderBlink.value = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherProvider>(
      builder: (context, provider, _) {
        final reading = evaluateHumanComfort(widget.bundle.current);
        final colors = _colorsFor(reading.level);
        final shouldBlink =
            reading.isUnbearable && provider.shouldBlinkComfortAlert;
        final confirmed =
            reading.isUnbearable && provider.precautionsConfirmed;

        _syncBlink(shouldBlink);

        return FadeSlideIn(
          delay: AppMotion.staggerStep * 2,
          offsetY: 16,
          child: Padding(
            padding: const EdgeInsets.only(top: AppSpacing.md),
            child: AnimatedBuilder(
              animation: _borderBlink,
              builder: (context, child) {
                final pulse =
                    shouldBlink ? 0.5 + _borderBlink.value * 0.5 : 0.0;
                return Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  decoration: shouldBlink
                      ? BoxDecoration(
                          borderRadius: BorderRadius.circular(26),
                          border: Border.all(
                            color: colors.foreground.withValues(alpha: pulse),
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: colors.foreground
                                  .withValues(alpha: pulse * 0.45),
                              blurRadius: 16 + _borderBlink.value * 12,
                              spreadRadius: 1,
                            ),
                          ],
                        )
                      : null,
                  child: child,
                );
              },
              child: GoogleSurfaceCard(
                margin: EdgeInsets.zero,
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _PulsingIcon(
                          active: shouldBlink,
                          color: colors.foreground,
                          icon: _iconFor(reading.level),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  BlinkingSensorLed(
                                    active: shouldBlink,
                                    color: colors.foreground,
                                    label: confirmed
                                        ? 'CONFIRMED'
                                        : shouldBlink
                                            ? 'SENSOR ALERT'
                                            : 'SENSOR OK',
                                  ),
                                  const Spacer(),
                                  Text(
                                    'Outdoor sensor',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(fontSize: 11),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                reading.title,
                                style: TextStyle(
                                  color: colors.foreground,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (confirmed) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF2E7D32)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.verified, color: Color(0xFF2E7D32)),
                            SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(
                                'You confirmed precautions. Alert stopped.',
                                style: TextStyle(
                                  color: Color(0xFF2E7D32),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (shouldBlink) ...[
                      const SizedBox(height: AppSpacing.sm),
                      _UnbearableBanner(
                        temperature: reading.temperatureC.round(),
                        apparent: reading.apparentTemperatureC.round(),
                        color: colors.foreground,
                        pulse: _borderBlink.value,
                      ),
                    ],
                    const SizedBox(height: AppSpacing.sm),
                    _SensorRow(
                      label: 'Sensed temperature',
                      value: '${reading.temperatureC.round()}°C',
                      highlight: shouldBlink,
                      highlightColor: colors.foreground,
                    ),
                    _SensorRow(
                      label: 'Feels like to body',
                      value: '${reading.apparentTemperatureC.round()}°C',
                    ),
                    _SensorRow(
                      label: 'Outdoor humidity · Wind',
                      value:
                          '${reading.humidity}% · ${reading.windSpeedKmh.round()} km/h',
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 4, bottom: 4),
                      child: Text(
                        'Outdoor values from weather service at your city — '
                        'not from the phone’s internal sensor.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontSize: 11,
                              fontStyle: FontStyle.italic,
                            ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      reading.summary,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: shouldBlink ? FontWeight.w500 : null,
                          ),
                    ),
                    if (reading.needsPrecautions) ...[
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Precautions to follow',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: colors.foreground,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      ...reading.precautions.map(
                        (tip) => Padding(
                          padding:
                              const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                size: 18,
                                color: colors.foreground,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Text(
                                  tip,
                                  style: const TextStyle(
                                    color: AppColors.onSurface,
                                    fontSize: 14,
                                    height: 1.35,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (shouldBlink) ...[
                        const SizedBox(height: AppSpacing.md),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: provider.acknowledgePrecautions,
                            style: FilledButton.styleFrom(
                              backgroundColor: colors.foreground,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            icon: const Icon(Icons.check_circle),
                            label: const Text(
                              'I will follow these precautions',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  IconData _iconFor(ComfortLevel level) => switch (level) {
        ComfortLevel.comfortable => Icons.sentiment_satisfied_alt_outlined,
        ComfortLevel.caution => Icons.warning_amber_rounded,
        ComfortLevel.warning => Icons.error_outline,
        ComfortLevel.danger => Icons.health_and_safety_outlined,
      };

  _ComfortColors _colorsFor(ComfortLevel level) => switch (level) {
        ComfortLevel.comfortable => const _ComfortColors(
            Color(0xFFE8F5E9),
            Color(0xFF2E7D32),
          ),
        ComfortLevel.caution => const _ComfortColors(
            Color(0xFFFFF8E1),
            Color(0xFFF57F17),
          ),
        ComfortLevel.warning => const _ComfortColors(
            Color(0xFFFFF3E0),
            Color(0xFFE65100),
          ),
        ComfortLevel.danger => const _ComfortColors(
            Color(0xFFFFEBEE),
            Color(0xFFC62828),
          ),
      };
}

class _UnbearableBanner extends StatelessWidget {
  const _UnbearableBanner({
    required this.temperature,
    required this.apparent,
    required this.color,
    required this.pulse,
  });

  final int temperature;
  final int apparent;
  final Color color;
  final double pulse;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12 + pulse * 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.4 + pulse * 0.4),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.sensors, color: color, size: 28),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'NOT BEARABLE — $temperature°C outside is unsafe for your body'
              '${apparent != temperature ? ' (feels $apparent°C)' : ''}.',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 14,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PulsingIcon extends StatefulWidget {
  const _PulsingIcon({
    required this.active,
    required this.color,
    required this.icon,
  });

  final bool active;
  final Color color;
  final IconData icon;

  @override
  State<_PulsingIcon> createState() => _PulsingIconState();
}

class _PulsingIconState extends State<_PulsingIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    if (widget.active) _c.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(_PulsingIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active) {
      if (!_c.isAnimating) _c.repeat(reverse: true);
    } else {
      _c.stop();
      _c.value = 0;
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final t = widget.active ? _c.value : 0.0;
        return Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: widget.color.withValues(alpha: 0.15 + t * 0.2),
            borderRadius: BorderRadius.circular(14),
            boxShadow: widget.active
                ? [
                    BoxShadow(
                      color: widget.color.withValues(alpha: 0.3 + t * 0.4),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: Icon(widget.icon, color: widget.color, size: 28),
        );
      },
    );
  }
}

class _SensorRow extends StatelessWidget {
  const _SensorRow({
    required this.label,
    required this.value,
    this.highlight = false,
    this.highlightColor,
  });

  final String label;
  final String value;
  final bool highlight;
  final Color? highlightColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(
            value,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: highlight ? highlightColor : null,
                  fontWeight: highlight ? FontWeight.w800 : FontWeight.w600,
                  fontSize: highlight ? 16 : null,
                ),
          ),
        ],
      ),
    );
  }
}

class _ComfortColors {
  const _ComfortColors(this.background, this.foreground);
  final Color background;
  final Color foreground;
}
