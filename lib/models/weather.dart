// Domain models for weather data (like TypeScript interfaces in RN).

class CityLocation {
  const CityLocation({
    required this.name,
    required this.country,
    required this.latitude,
    required this.longitude,
  });

  final String name;
  final String country;
  final double latitude;
  final double longitude;

  String get displayName =>
      country.isEmpty ? name : '$name, $country';
}

class CurrentWeather {
  const CurrentWeather({
    required this.temperatureC,
    required this.humidity,
    required this.windSpeedKmh,
    required this.weatherCode,
    required this.localTime,
    required this.timezoneAbbreviation,
  });

  final double temperatureC;
  final int humidity;
  final double windSpeedKmh;
  final int weatherCode;

  /// Current date/time in the weather location's timezone (from Open-Meteo).
  final DateTime localTime;
  final String timezoneAbbreviation;
}

class DailyForecast {
  const DailyForecast({
    required this.date,
    required this.maxTempC,
    required this.minTempC,
    required this.weatherCode,
  });

  /// Calendar date in the location's timezone.
  final DateTime date;
  final double maxTempC;
  final double minTempC;
  final int weatherCode;
}

class WeatherBundle {
  const WeatherBundle({
    required this.location,
    required this.current,
    required this.daily,
    required this.timezone,
    required this.timezoneAbbreviation,
  });

  final CityLocation location;
  final CurrentWeather current;
  final List<DailyForecast> daily;

  /// IANA timezone id, e.g. `America/New_York`.
  final String timezone;
  final String timezoneAbbreviation;
}
