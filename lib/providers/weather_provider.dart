import 'package:flutter/foundation.dart';

import '../models/weather.dart';
import '../services/weather_service.dart';

/// State management with ChangeNotifier (Provider pattern).
/// Comparable to Redux/Zustand/Context in React Native.
class WeatherProvider extends ChangeNotifier {
  WeatherProvider({WeatherService? service})
      : _service = service ?? WeatherService();

  final WeatherService _service;

  bool _loading = false;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;

  WeatherBundle? _weather;
  WeatherBundle? get weather => _weather;

  List<CityLocation> _searchResults = [];
  List<CityLocation> get searchResults => _searchResults;

  String _query = '';
  String get query => _query;

  Future<void> searchCities(String query) async {
    _query = query;
    if (query.trim().length < 2) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    try {
      _searchResults = await _service.searchCities(query);
      _error = null;
    } on WeatherServiceException catch (e) {
      _searchResults = [];
      _error = e.message;
    } catch (_) {
      _searchResults = [];
      _error = 'Could not search cities. Check your connection.';
    }
    notifyListeners();
  }

  Future<void> loadWeather(CityLocation location) async {
    _loading = true;
    _error = null;
    _searchResults = [];
    notifyListeners();

    try {
      _weather = await _service.fetchWeather(location);
    } on WeatherServiceException catch (e) {
      _error = e.message;
    } catch (_) {
      _error = 'Could not load weather. Check your connection.';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> loadDefaultCity() async {
    await loadWeather(
      const CityLocation(
        name: 'London',
        country: 'United Kingdom',
        latitude: 51.5074,
        longitude: -0.1278,
      ),
    );
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
