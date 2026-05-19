import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/weather_provider.dart';
import '../widgets/current_weather_card.dart';
import '../widgets/forecast_list.dart';
import '../widgets/search_field.dart';

/// StatefulWidget screen — owns lifecycle (like useEffect on mount).
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WeatherProvider>().loadDefaultCity();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A237E),
              Color(0xFF3949AB),
              Color(0xFF5C6BC0),
            ],
          ),
        ),
        child: SafeArea(
          child: Consumer<WeatherProvider>(
            builder: (context, provider, _) {
              return RefreshIndicator(
                onRefresh: () async {
                  final w = provider.weather;
                  if (w != null) {
                    await provider.loadWeather(w.location);
                  } else {
                    await provider.loadDefaultCity();
                  }
                },
                color: Colors.white,
                backgroundColor: const Color(0xFF3949AB),
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          Text(
                            'Weather',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Flutter demo · Provider · Open-Meteo API',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.65),
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 20),
                          const SearchField(),
                          const SizedBox(height: 24),
                          if (provider.loading)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(48),
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              ),
                            )
                          else if (provider.error != null)
                            _ErrorBanner(
                              message: provider.error!,
                              onRetry: provider.loadDefaultCity,
                            )
                          else if (provider.weather != null) ...[
                            CurrentWeatherCard(bundle: provider.weather!),
                            const SizedBox(height: 24),
                            ForecastList(daily: provider.weather!.daily),
                          ],
                        ]),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          Text(message, style: const TextStyle(color: Colors.white)),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
