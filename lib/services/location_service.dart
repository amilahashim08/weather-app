import 'package:geolocator/geolocator.dart';

import '../models/weather.dart';
import 'weather_service.dart';

/// Resolves the device GPS position to a city via Open-Meteo reverse geocoding.
class LocationService {
  LocationService({WeatherService? weatherService})
      : _weatherService = weatherService ?? WeatherService();

  final WeatherService _weatherService;

  Future<CityLocation> resolveCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw LocationServiceException(
        'Location services are off. Enable GPS in your device settings.',
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw LocationServiceException(
        'Location permission denied. Allow location access to see local weather.',
      );
    }

    if (permission == LocationPermission.deniedForever) {
      throw LocationServiceException(
        'Location permission permanently denied. Enable it in app settings.',
      );
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
        timeLimit: Duration(seconds: 10),
      ),
    ).timeout(
      const Duration(seconds: 12),
      onTimeout: () => throw LocationServiceException(
        'GPS timed out. Enable location or use default city.',
      ),
    );

    return _weatherService.reverseGeocode(
      latitude: position.latitude,
      longitude: position.longitude,
    );
  }
}

class LocationServiceException implements Exception {
  LocationServiceException(this.message);
  final String message;

  @override
  String toString() => message;
}
