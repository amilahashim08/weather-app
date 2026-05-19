import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'package:weather_app/constants/default_location.dart';
import 'package:weather_app/models/weather.dart';
import 'package:weather_app/providers/weather_provider.dart';
import 'package:weather_app/services/location_service.dart';
import 'package:weather_app/services/weather_service.dart';

void main() {
  setUpAll(() {
    tz_data.initializeTimeZones();
  });

  test('loadInitialWeather loads Rawalpindi Pakistan by default', () async {
    final provider = WeatherProvider(
      service: _FakeWeatherService(),
      locationService: _FakeLocationService(),
    );

    await provider.loadInitialWeather();

    expect(provider.weather, isNotNull);
    expect(provider.weather!.location.name, 'Rawalpindi');
    expect(provider.weather!.location.country, 'Pakistan');
    expect(provider.weather!.timezone, 'Asia/Karachi');
    expect(provider.error, isNull);
  });

  test('search errors do not set main weather error', () async {
    final provider = WeatherProvider(
      service: _FakeWeatherService(throwOnSearch: true),
      locationService: _FakeLocationService(),
    );

    provider.searchCities('Lon');
    await Future<void>.delayed(const Duration(milliseconds: 500));

    expect(provider.error, isNull);
    expect(provider.searchError, isNotNull);
  });

  test('loadWeather sets weather on success', () async {
    final provider = WeatherProvider(
      service: _FakeWeatherService(),
      locationService: _FakeLocationService(),
    );
    const city = CityLocation(
      name: 'Paris',
      country: 'France',
      latitude: 48.85,
      longitude: 2.35,
    );

    await provider.loadWeather(city);

    expect(provider.weather, isNotNull);
    expect(provider.weather!.location.name, 'Paris');
    expect(provider.error, isNull);
    expect(provider.loading, isFalse);
  });

  test('loadCurrentLocation falls back to Rawalpindi when GPS fails', () async {
    final provider = WeatherProvider(
      service: _FakeWeatherService(),
      locationService: _FakeLocationService(throwOnResolve: true),
    );

    await provider.loadCurrentLocation();

    expect(provider.weather, isNotNull);
    expect(provider.weather!.location.name, 'Rawalpindi');
    expect(provider.error, isNull);
  });
}

class _FakeLocationService extends LocationService {
  _FakeLocationService({
    this.location = DefaultLocation.rawalpindi,
    this.throwOnResolve = false,
  }) : super(weatherService: _FakeWeatherService());

  final CityLocation location;
  final bool throwOnResolve;

  @override
  Future<CityLocation> resolveCurrentLocation() async {
    if (throwOnResolve) {
      throw LocationServiceException('Location permission denied.');
    }
    await Future<void>.delayed(const Duration(milliseconds: 10));
    return location;
  }
}

class _FakeWeatherService extends WeatherService {
  _FakeWeatherService({this.throwOnSearch = false});

  final bool throwOnSearch;

  @override
  Future<List<CityLocation>> searchCities(String query) async {
    if (throwOnSearch) {
      throw WeatherServiceException('Search failed');
    }
    await Future<void>.delayed(const Duration(milliseconds: 10));
    return const [];
  }

  @override
  Future<WeatherBundle> fetchWeather(CityLocation location) async {
    final karachi = tz.getLocation('Asia/Karachi');
    final localTime = tz.TZDateTime(karachi, 2026, 5, 19, 19, 45, 30);

    final timezone = location.name == 'Paris' ? 'Europe/Paris' : 'Asia/Karachi';
    final abbr = location.name == 'Paris' ? 'CEST' : 'PKT';

    return WeatherBundle(
      location: location,
      timezone: timezone,
      timezoneAbbreviation: abbr,
      current: CurrentWeather(
        temperatureC: 28,
        humidity: 55,
        windSpeedKmh: 12,
        weatherCode: 1,
        localTime: localTime,
        timezoneAbbreviation: abbr,
      ),
      daily: [
        DailyForecast(
          date: tz.TZDateTime(karachi, 2026, 5, 19),
          maxTempC: 32,
          minTempC: 22,
          weatherCode: 1,
        ),
      ],
    );
  }
}
