import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'package:weather_app/models/weather.dart';
import 'package:weather_app/utils/human_comfort_sensor.dart';

CurrentWeather _weather({
  required double temp,
  int humidity = 50,
  double wind = 10,
}) {
  return CurrentWeather(
    temperatureC: temp,
    humidity: humidity,
    windSpeedKmh: wind,
    weatherCode: 0,
    localTime: tz.TZDateTime(tz.getLocation('Asia/Karachi'), 2026, 6, 1, 12),
    timezoneAbbreviation: 'PKT',
  );
}

void main() {
  setUpAll(tz_data.initializeTimeZones);

  test('comfortable range around 22C', () {
    final r = evaluateHumanComfort(_weather(temp: 22));
    expect(r.level, ComfortLevel.comfortable);
  });

  test('dangerous extreme heat', () {
    final r = evaluateHumanComfort(_weather(temp: 46, humidity: 40));
    expect(r.level, ComfortLevel.danger);
    expect(r.precautions, isNotEmpty);
  });

  test('warning for very hot Rawalpindi-like summer', () {
    final r = evaluateHumanComfort(_weather(temp: 38, humidity: 55));
    expect(r.level, isIn([ComfortLevel.warning, ComfortLevel.danger]));
    expect(r.precautions.length, greaterThan(2));
  });

  test('severe cold precautions', () {
    final r = evaluateHumanComfort(_weather(temp: -12, wind: 25));
    expect(r.level, ComfortLevel.danger);
    expect(r.title, contains('cold'));
  });
}
