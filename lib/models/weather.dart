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
    required this.time,
  });

  final double temperatureC;
  final int humidity;
  final double windSpeedKmh;
  final int weatherCode;
  final DateTime time;
}

class DailyForecast {
  const DailyForecast({
    required this.date,
    required this.maxTempC,
    required this.minTempC,
    required this.weatherCode,
  });

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
  });

  final CityLocation location;
  final CurrentWeather current;
  final List<DailyForecast> daily;
}
