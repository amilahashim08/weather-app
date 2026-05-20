import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../theme/app_theme.dart';

/// Explains how outdoor sensing works (weather API, not phone sensors when closed).
class OutdoorSensorInfo extends StatelessWidget {
  const OutdoorSensorInfo({
    super.key,
    this.lastUpdated,
  });

  final DateTime? lastUpdated;

  @override
  Widget build(BuildContext context) {
    final updatedText = lastUpdated != null
        ? 'Last outdoor reading: ${DateFormat('HH:mm').format(lastUpdated!)}'
        : 'Waiting for first outdoor reading…';

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        0,
      ),
      child: Material(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline,
                size: 20,
                color: Colors.white.withValues(alpha: 0.9),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'How outdoor sensing works',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.95),
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Temperature and humidity are read from live outdoor weather '
                      'for your city (Open-Meteo), not from sensors inside your phone. '
                      'When the app is closed, nothing is measured — open the app or '
                      'pull down to refresh for a new reading.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      updatedText,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.65),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
