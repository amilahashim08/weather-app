import 'package:flutter/material.dart';

import '../models/weather.dart';
import '../theme/app_theme.dart';
import '../utils/animations.dart';
import 'google_surface_card.dart';

/// White details card below the hero — humidity & wind chips.
class WeatherDetailsCard extends StatelessWidget {
  const WeatherDetailsCard({super.key, required this.bundle});

  final WeatherBundle bundle;

  @override
  Widget build(BuildContext context) {
    return FadeSlideIn(
      offsetY: 20,
      child: GoogleSurfaceCard(
        child: Row(
          children: [
            GoogleDetailChip(
              icon: Icons.water_drop_outlined,
              label: 'Humidity',
              value: '${bundle.current.humidity}%',
            ),
            const SizedBox(width: AppSpacing.sm),
            GoogleDetailChip(
              icon: Icons.air,
              label: 'Wind',
              value: '${bundle.current.windSpeedKmh.round()} km/h',
            ),
            const SizedBox(width: AppSpacing.sm),
            GoogleDetailChip(
              icon: Icons.thermostat_outlined,
              label: 'Feels',
              value: '${bundle.current.temperatureC.round()}°',
            ),
          ],
        ),
      ),
    );
  }
}
