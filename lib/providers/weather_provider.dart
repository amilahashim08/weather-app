import 'dart:async';

import 'package:flutter/foundation.dart';

import '../constants/default_location.dart';
import '../models/weather.dart';
import '../services/location_service.dart';
import '../services/weather_service.dart';
import '../utils/human_comfort_sensor.dart';

/// State management with ChangeNotifier (Provider pattern).
class WeatherProvider extends ChangeNotifier {
  WeatherProvider({
    WeatherService? service,
    LocationService? locationService,
  })  : _service = service ?? WeatherService(),
        _locationService = locationService ??
            LocationService(weatherService: service ?? WeatherService());

  final WeatherService _service;
  final LocationService _locationService;
  Timer? _searchDebounce;

  bool _loading = false;
  bool get loading => _loading;

  bool _refreshing = false;
  bool get refreshing => _refreshing;

  String? _error;
  String? get error => _error;

  String? _searchError;
  String? get searchError => _searchError;

  WeatherBundle? _weather;
  WeatherBundle? get weather => _weather;

  DateTime? _lastUpdated;
  DateTime? get lastUpdated => _lastUpdated;

  static const _staleAfter = Duration(minutes: 10);

  List<CityLocation> _searchResults = [];
  List<CityLocation> get searchResults => _searchResults;

  String _query = '';
  String get query => _query;

  /// Set when user confirms they will follow precautions for the current alert.
  String? _acknowledgedAlertKey;

  /// True while unbearable conditions are active and user has not confirmed yet.
  bool get shouldBlinkComfortAlert {
    final bundle = _weather;
    if (bundle == null) return false;
    final reading = evaluateHumanComfort(bundle.current);
    if (!reading.isUnbearable) return false;
    return _acknowledgedAlertKey != _comfortAlertKey(bundle);
  }

  bool get precautionsConfirmed {
    final bundle = _weather;
    if (bundle == null) return false;
    return _acknowledgedAlertKey == _comfortAlertKey(bundle);
  }

  void acknowledgePrecautions() {
    final bundle = _weather;
    if (bundle == null) return;
    _acknowledgedAlertKey = _comfortAlertKey(bundle);
    notifyListeners();
  }

  String _comfortAlertKey(WeatherBundle bundle) {
    final reading = evaluateHumanComfort(bundle.current);
    return '${bundle.location.displayName}|${reading.level.name}|'
        '${bundle.current.temperatureC.round()}';
  }

  /// Fetches fresh outdoor data when user returns to the app (not while closed).
  Future<void> refreshOnResume() async {
    final bundle = _weather;
    if (bundle == null) return;
    if (_lastUpdated != null &&
        DateTime.now().difference(_lastUpdated!) < _staleAfter) {
      return;
    }
    await loadWeather(bundle.location);
  }

  /// Loads Rawalpindi, Pakistan on startup — always shows weather immediately.
  Future<void> loadInitialWeather() async {
    await loadWeather(DefaultLocation.rawalpindi);
  }

  /// Pull-to-refresh: GPS if allowed, otherwise Rawalpindi.
  Future<void> loadCurrentLocation() async {
    final updated = await _tryGpsUpdate(silent: false);
    if (!updated) {
      await loadWeather(DefaultLocation.rawalpindi);
    }
  }

  Future<bool> _tryGpsUpdate({required bool silent}) async {
    try {
      final location = await _locationService.resolveCurrentLocation();
      if (location.latitude == DefaultLocation.rawalpindi.latitude &&
          location.longitude == DefaultLocation.rawalpindi.longitude) {
        return false;
      }
      await loadWeather(location);
      return true;
    } on LocationServiceException catch (e) {
      if (!silent) {
        _error =
            '${e.message} Showing weather for Rawalpindi, Pakistan.';
        notifyListeners();
      }
      return false;
    } catch (_) {
      if (!silent) {
        _error =
            'Could not detect GPS. Showing weather for Rawalpindi, Pakistan.';
        notifyListeners();
      }
      return false;
    }
  }

  void searchCities(String query) {
    _query = query;
    _searchDebounce?.cancel();

    if (query.trim().length < 2) {
      _searchResults = [];
      _searchError = null;
      notifyListeners();
      return;
    }

    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      _performSearch(query.trim());
    });
  }

  Future<void> _performSearch(String query) async {
    if (_query.trim() != query) return;

    try {
      final results = await _service.searchCities(query);
      if (_query.trim() != query) return;
      _searchResults = results;
      _searchError =
          results.isEmpty ? 'No cities found for "$query".' : null;
    } on WeatherServiceException catch (e) {
      if (_query.trim() != query) return;
      _searchResults = [];
      _searchError = e.message;
    } catch (_) {
      if (_query.trim() != query) return;
      _searchResults = [];
      _searchError = 'Could not search cities. Check your connection.';
    }
    notifyListeners();
  }

  Future<void> loadWeather(CityLocation location) async {
    final firstLoad = _weather == null;
    if (firstLoad) {
      _loading = true;
    } else {
      _refreshing = true;
    }
    _error = null;
    clearSearch(notify: false);
    notifyListeners();

    try {
      final previousKey =
          _weather != null ? _comfortAlertKey(_weather!) : null;
      _weather = await _service.fetchWeather(location);
      _lastUpdated = DateTime.now();
      final newKey = _comfortAlertKey(_weather!);
      if (previousKey != null && previousKey != newKey) {
        _acknowledgedAlertKey = null;
      }
    } on WeatherServiceException catch (e) {
      _error = e.message;
    } catch (_) {
      _error = 'Could not load weather. Check your connection.';
    } finally {
      _loading = false;
      _refreshing = false;
      notifyListeners();
    }
  }

  void clearSearch({bool notify = true}) {
    _searchDebounce?.cancel();
    _query = '';
    _searchResults = [];
    _searchError = null;
    if (notify) notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    super.dispose();
  }
}
