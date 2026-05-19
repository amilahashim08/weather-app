import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/weather.dart';
import '../utils/timezone_utils.dart';

/// API layer — uses Open-Meteo (free, no API key required).
class WeatherService {
  static const _geocodingBase =
      'https://geocoding-api.open-meteo.com/v1/search';
  static const _reverseGeocodingBase =
      'https://geocoding-api.open-meteo.com/v1/reverse';
  static const _forecastBase = 'https://api.open-meteo.com/v1/forecast';
  static const _timeout = Duration(seconds: 20);

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

    final response = await _get(uri);
    if (response.statusCode != 200) {
      throw WeatherServiceException(
        'City search failed (${response.statusCode})',
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final results = data['results'] as List<dynamic>? ?? [];

    return results.map((raw) => _cityFromJson(raw as Map<String, dynamic>)).toList();
  }

  Future<CityLocation> reverseGeocode({
    required double latitude,
    required double longitude,
  }) async {
    final uri = Uri.parse(_reverseGeocodingBase).replace(
      queryParameters: {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'language': 'en',
        'format': 'json',
      },
    );

    final response = await _get(uri);
    if (response.statusCode != 200) {
      throw WeatherServiceException(
        'Could not resolve your location (${response.statusCode})',
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final results = data['results'] as List<dynamic>? ?? [];

    if (results.isEmpty) {
      return CityLocation(
        name: 'Current location',
        country: '',
        latitude: latitude,
        longitude: longitude,
      );
    }

    return _cityFromJson(results.first as Map<String, dynamic>);
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

    final response = await _get(uri);
    if (response.statusCode != 200) {
      throw WeatherServiceException(
        'Weather fetch failed (${response.statusCode})',
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final current = data['current'] as Map<String, dynamic>?;
    final daily = data['daily'] as Map<String, dynamic>?;
    final timezone = data['timezone'] as String?;
    final timezoneAbbreviation =
        data['timezone_abbreviation'] as String? ?? '';

    if (current == null || daily == null || timezone == null) {
      throw WeatherServiceException('Unexpected response from weather API.');
    }

    final localTime = parseLocationDateTime(
      current['time'] as String,
      timezone,
    );

    final times = (daily['time'] as List).cast<String>();
    final maxTemps = (daily['temperature_2m_max'] as List).cast<num>();
    final minTemps = (daily['temperature_2m_min'] as List).cast<num>();
    final codes = (daily['weather_code'] as List).cast<num>();

    final forecasts = <DailyForecast>[];
    for (var i = 0; i < times.length; i++) {
      final date = parseLocationDate(times[i], timezone);
      forecasts.add(
        DailyForecast(
          date: date,
          maxTempC: maxTemps[i].toDouble(),
          minTempC: minTemps[i].toDouble(),
          weatherCode: codes[i].toInt(),
        ),
      );
    }

    return WeatherBundle(
      location: location,
      timezone: timezone,
      timezoneAbbreviation: timezoneAbbreviation,
      current: CurrentWeather(
        temperatureC: (current['temperature_2m'] as num).toDouble(),
        humidity: (current['relative_humidity_2m'] as num).toInt(),
        windSpeedKmh: (current['wind_speed_10m'] as num).toDouble(),
        weatherCode: (current['weather_code'] as num).toInt(),
        localTime: localTime,
        timezoneAbbreviation: timezoneAbbreviation,
      ),
      daily: forecasts,
    );
  }

  CityLocation _cityFromJson(Map<String, dynamic> item) {
    return CityLocation(
      name: item['name'] as String? ?? 'Unknown',
      country: item['country'] as String? ?? '',
      latitude: (item['latitude'] as num).toDouble(),
      longitude: (item['longitude'] as num).toDouble(),
    );
  }

  Future<http.Response> _get(Uri uri) async {
    try {
      return await http.get(uri).timeout(_timeout);
    } on TimeoutException {
      throw WeatherServiceException(
        'Request timed out. Check your internet connection.',
      );
    } on SocketException {
      throw WeatherServiceException(
        'No internet connection. Check your network and try again.',
      );
    } on HttpException {
      throw WeatherServiceException(
        'Network error while contacting the weather service.',
      );
    }
  }
}

class WeatherServiceException implements Exception {
  WeatherServiceException(this.message);
  final String message;

  @override
  String toString() => message;
}
