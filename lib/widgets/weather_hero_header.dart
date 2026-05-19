import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

import '../models/weather.dart';
import '../theme/app_theme.dart';
import '../utils/animations.dart';
import '../utils/weather_codes.dart';

/// Hero with live local clock for the weather region (e.g. Asia/Karachi).
class WeatherHeroHeader extends StatefulWidget {
  const WeatherHeroHeader({super.key, required this.bundle});

  final WeatherBundle bundle;

  @override
  State<WeatherHeroHeader> createState() => _WeatherHeroHeaderState();
}

class _WeatherHeroHeaderState extends State<WeatherHeroHeader> {
  Timer? _clockTimer;
  late tz.Location _tzLocation;

  @override
  void initState() {
    super.initState();
    _tzLocation = tz.getLocation(widget.bundle.timezone);
    _clockTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void didUpdateWidget(WeatherHeroHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.bundle.timezone != widget.bundle.timezone) {
      _tzLocation = tz.getLocation(widget.bundle.timezone);
    }
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bundle = widget.bundle;
    final info = weatherInfoFromCode(bundle.current.weatherCode);
    final now = tz.TZDateTime.now(_tzLocation);
    final dateFormat = DateFormat('EEEE, MMM d');
    final timeFormat = DateFormat('HH:mm:ss');
    final tzLabel = bundle.timezoneAbbreviation;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.location_on,
                size: 18,
                color: Colors.white.withValues(alpha: 0.9),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: SmoothSwitcher(
                  transitionKey: bundle.location.displayName,
                  child: Text(
                    bundle.location.displayName,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dateFormat.format(now),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${timeFormat.format(now)}'
                '${tzLabel.isNotEmpty ? ' $tzLabel' : ''}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                'Local time · ${bundle.timezone}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.65),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SmoothSwitcher(
                transitionKey: info.emoji,
                child: FloatingEmoji(emoji: info.emoji, size: 80),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SmoothSwitcher(
                      transitionKey: bundle.current.temperatureC.round(),
                      child: TweenAnimationBuilder<double>(
                        key: ValueKey(bundle.current.temperatureC),
                        tween: Tween(
                          begin: 0,
                          end: bundle.current.temperatureC,
                        ),
                        duration: AppMotion.slow,
                        curve: AppMotion.enter,
                        builder: (context, value, _) {
                          return Text(
                            '${value.round()}°',
                            style: Theme.of(context).textTheme.headlineLarge,
                          );
                        },
                      ),
                    ),
                    SmoothSwitcher(
                      transitionKey: info.label,
                      child: Text(
                        info.label,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.92),
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
