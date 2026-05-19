import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

import '../models/weather.dart';
import '../theme/app_theme.dart';
import '../utils/animations.dart';
import '../utils/timezone_utils.dart';
import '../utils/weather_codes.dart';
import 'google_surface_card.dart';

/// 7-day forecast as sliver list inside a Google-style white card.
class ForecastSliverList extends StatelessWidget {
  const ForecastSliverList({
    super.key,
    required this.daily,
    required this.timezone,
  });

  final List<DailyForecast> daily;
  final String timezone;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      sliver: SliverToBoxAdapter(
        child: FadeSlideIn(
          delay: AppMotion.staggerStep * 2,
          child: GoogleSurfaceCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: List.generate(daily.length, (index) {
                final day = daily[index];
                final isLast = index == daily.length - 1;
                return _ForecastRow(
                  day: day,
                  index: index,
                  timezone: timezone,
                  showDivider: !isLast,
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _ForecastRow extends StatelessWidget {
  const _ForecastRow({
    required this.day,
    required this.index,
    required this.timezone,
    required this.showDivider,
  });

  final DailyForecast day;
  final int index;
  final String timezone;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final info = weatherInfoFromCode(day.weatherCode);
    final dayFormat = DateFormat('EEE');
    final isToday = isTodayInTimezone(day.date as tz.TZDateTime, timezone);

    return FadeSlideIn(
      delay: AppMotion.staggerStep * (index + 1),
      duration: AppMotion.fast,
      offsetY: 12,
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.vertical(
                top: index == 0 ? const Radius.circular(24) : Radius.zero,
                bottom: !showDivider ? const Radius.circular(24) : Radius.zero,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 52,
                      child: Text(
                        isToday ? 'Today' : dayFormat.format(day.date),
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: isToday
                                  ? AppColors.googleBlue
                                  : AppColors.onSurface,
                              fontWeight:
                                  isToday ? FontWeight.w600 : FontWeight.w500,
                            ),
                      ),
                    ),
                    Text(info.emoji, style: const TextStyle(fontSize: 26)),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        info.label,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    Text(
                      '${day.maxTempC.round()}°',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      '${day.minTempC.round()}°',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (showDivider)
            const Divider(
              height: 1,
              thickness: 1,
              indent: AppSpacing.md,
              endIndent: AppSpacing.md,
              color: AppColors.divider,
            ),
        ],
      ),
    );
  }

}

/// Sticky section header while scrolling forecast.
class ForecastSectionHeader extends StatelessWidget {
  const ForecastSectionHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _ForecastHeaderDelegate(),
    );
  }
}

class _ForecastHeaderDelegate extends SliverPersistentHeaderDelegate {
  @override
  double get minExtent => 52;

  @override
  double get maxExtent => 52;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final pinned = shrinkOffset > 0;
    return AnimatedContainer(
      duration: AppMotion.fast,
      curve: AppMotion.smooth,
      color: pinned
          ? AppColors.surface.withValues(alpha: 0.95)
          : Colors.transparent,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Text(
        '7-day forecast',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: pinned ? AppColors.onSurface : Colors.white,
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      false;
}
