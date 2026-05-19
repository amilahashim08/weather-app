import '../models/weather.dart';

/// Default city shown on launch — Rawalpindi, Pakistan (Asia/Karachi timezone).
abstract final class DefaultLocation {
  static const CityLocation rawalpindi = CityLocation(
    name: 'Rawalpindi',
    country: 'Pakistan',
    latitude: 33.6007,
    longitude: 73.0679,
  );
}
