import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/weather.dart';

/// API layer (similar to fetch/axios services in React Native).
/// Uses Open-Meteo — free, no API key required.
class WeatherService {
  static const _geocodingBase =
      'https://geocoding-api.open-meteo.com/v1/search';
  static const _forecastBase = 'https://api.open-meteo.com/v1/forecast';

  Future<List<CityLocation>> searchCities(String query) async {
    final trimmed = query.trim();
    if (trimmed.length < 2) return [];

    final uri = Uri.parse(_geocodingBase).replace(
      queryParameters: {
        'name': trimmed,
        'count': '8',
        'language': 'en',
        'format': 'json',
      },
    );

    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw WeatherServiceException('City search failed (${response.statusCode})');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final results = data['results'] as List<dynamic>? ?? [];

    return results.map((raw) {
      final item = raw as Map<String, dynamic>;
      return CityLocation(
        name: item['name'] as String? ?? 'Unknown',
        country: item['country'] as String? ?? '',
        latitude: (item['latitude'] as num).toDouble(),
        longitude: (item['longitude'] as num).toDouble(),
      );
    }).toList();
  }

  Future<WeatherBundle> fetchWeather(CityLocation location) async {
    final uri = Uri.parse(_forecastBase).replace(
      queryParameters: {
        'latitude': location.latitude.toString(),
        'longitude': location.longitude.toString(),
        'current':
            'temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m',
        'daily': 'weather_code,temperature_2m_max,temperature_2m_min',
        'timezone': 'auto',
        'forecast_days': '7',
      },
    );

    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw WeatherServiceException(
        'Weather fetch failed (${response.statusCode})',
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final current = data['current'] as Map<String, dynamic>;
    final daily = data['daily'] as Map<String, dynamic>;

    final times = (daily['time'] as List).cast<String>();
    final maxTemps = (daily['temperature_2m_max'] as List).cast<num>();
    final minTemps = (daily['temperature_2m_min'] as List).cast<num>();
    final codes = (daily['weather_code'] as List).cast<num>();

    final forecasts = <DailyForecast>[];
    for (var i = 0; i < times.length; i++) {
      forecasts.add(
        DailyForecast(
          date: DateTime.parse(times[i]),
          maxTempC: maxTemps[i].toDouble(),
          minTempC: minTemps[i].toDouble(),
          weatherCode: codes[i].toInt(),
        ),
      );
    }

    return WeatherBundle(
      location: location,
      current: CurrentWeather(
        temperatureC: (current['temperature_2m'] as num).toDouble(),
        humidity: (current['relative_humidity_2m'] as num).toInt(),
        windSpeedKmh: (current['wind_speed_10m'] as num).toDouble(),
        weatherCode: (current['weather_code'] as num).toInt(),
        time: DateTime.parse(current['time'] as String),
      ),
      daily: forecasts,
    );
  }
}

class WeatherServiceException implements Exception {
  WeatherServiceException(this.message);
  final String message;

  @override
  String toString() => message;
}
