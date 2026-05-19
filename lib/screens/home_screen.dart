import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';

import '../providers/weather_provider.dart';
import '../theme/app_theme.dart';
import '../utils/animations.dart';
import '../widgets/animated_loading.dart';
import '../widgets/forecast_sliver_list.dart';
import '../widgets/search_field.dart';
import '../widgets/weather_details_card.dart';
import '../widgets/google_surface_card.dart';
import '../widgets/weather_hero_header.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WeatherProvider>().loadInitialWeather();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.skyMid,
      body: AnimatedGradientBackground(
        child: Consumer<WeatherProvider>(
          builder: (context, provider, _) {
            return RefreshIndicator(
              onRefresh: () => _onRefresh(provider),
              color: AppColors.googleBlue,
              backgroundColor: AppColors.surface,
              displacement: 48,
              edgeOffset: MediaQuery.paddingOf(context).top,
              child: ScrollConfiguration(
                behavior: const _SmoothScrollBehavior(),
                child: CustomScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(
                      decelerationRate: ScrollDecelerationRate.fast,
                    ),
                  ),
                  cacheExtent: 600,
                  slivers: [
                    SliverAppBar(
                      pinned: true,
                      floating: true,
                      snap: true,
                      elevation: 0,
                      scrolledUnderElevation: 0,
                      backgroundColor: Colors.transparent,
                      surfaceTintColor: Colors.transparent,
                      expandedHeight: 56,
                      toolbarHeight: 56,
                      title: FadeSlideIn(
                        duration: AppMotion.fast,
                        offsetY: 8,
                        child: const Text(
                          'Weather',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      centerTitle: false,
                    ),
                    SliverToBoxAdapter(
                      child: FadeSlideIn(
                        delay: AppMotion.staggerStep,
                        offsetY: 12,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.md,
                            0,
                            AppSpacing.md,
                            AppSpacing.sm,
                          ),
                          child: const SearchField(),
                        ),
                      ),
                    ),
                    if (provider.refreshing)
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                          ),
                          child: LinearProgressIndicator(
                            color: AppColors.googleBlue,
                            backgroundColor: Colors.white24,
                            borderRadius: BorderRadius.all(
                              Radius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ..._buildWeatherSlivers(context, provider),
                    const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _onRefresh(WeatherProvider provider) async {
    final w = provider.weather;
    if (w != null) {
      await provider.loadWeather(w.location);
    } else {
      await provider.loadCurrentLocation();
    }
  }

  List<Widget> _buildWeatherSlivers(
    BuildContext context,
    WeatherProvider provider,
  ) {
    if (provider.loading && provider.weather == null) {
      return [
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: WeatherLoadingPlaceholder(),
          ),
        ),
      ];
    }

    if (provider.error != null && provider.weather == null) {
      return [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: _ErrorBanner(
              message: provider.error!,
              onRetry: provider.loadInitialWeather,
            ),
          ),
        ),
      ];
    }

    if (provider.weather == null) {
      return const [SliverToBoxAdapter(child: SizedBox.shrink())];
    }

    final bundle = provider.weather!;

    return [
      if (provider.error != null)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              0,
            ),
            child: _ErrorBanner(
              message: provider.error!,
              onRetry: () => provider.loadWeather(bundle.location),
            ),
          ),
        ),
      SliverToBoxAdapter(
        child: WeatherHeroHeader(
          key: ValueKey('hero-${bundle.location.displayName}'),
          bundle: bundle,
        ),
      ),
      SliverToBoxAdapter(
        child: WeatherDetailsCard(bundle: bundle),
      ),
      const SliverPadding(padding: EdgeInsets.only(top: AppSpacing.lg)),
      const ForecastSectionHeader(),
      ForecastSliverList(
        key: ValueKey('forecast-${bundle.location.displayName}'),
        daily: bundle.daily,
        timezone: bundle.timezone,
      ),
    ];
  }
}

/// Smoother touch scrolling on all platforms.
class _SmoothScrollBehavior extends MaterialScrollBehavior {
  const _SmoothScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
      };

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics(
      parent: AlwaysScrollableScrollPhysics(),
      decelerationRate: ScrollDecelerationRate.fast,
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return FadeSlideIn(
      child: GoogleSurfaceCard(
        margin: EdgeInsets.zero,
        child: Column(
          children: [
            Text(
              message,
              style: const TextStyle(color: AppColors.onSurface),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
