import 'dart:math' as math;

import '../models/weather.dart';

/// How harsh outdoor conditions are for the human body.
enum ComfortLevel { comfortable, caution, warning, danger }

/// "Sensor" reading derived from live outdoor weather (temp, humidity, wind).
class HumanComfortReading {
  const HumanComfortReading({
    required this.level,
    required this.title,
    required this.summary,
    required this.precautions,
    required this.temperatureC,
    required this.apparentTemperatureC,
    required this.humidity,
    required this.windSpeedKmh,
  });

  final ComfortLevel level;
  final String title;
  final String summary;
  final List<String> precautions;
  final double temperatureC;
  final double apparentTemperatureC;
  final int humidity;
  final double windSpeedKmh;

  bool get needsPrecautions => level != ComfortLevel.comfortable;

  /// True when outdoor air is hard or unsafe to bear (blinks app alert).
  bool get isUnbearable =>
      level == ComfortLevel.warning || level == ComfortLevel.danger;
}

extension ComfortLevelX on ComfortLevel {
  bool get shouldBlinkAlert =>
      this == ComfortLevel.warning || this == ComfortLevel.danger;
}

/// Evaluates outside weather as if from a comfort & safety sensor.
HumanComfortReading evaluateHumanComfort(CurrentWeather current) {
  final temp = current.temperatureC;
  final humidity = current.humidity;
  final wind = current.windSpeedKmh;
  final apparent = _apparentTemperature(temp, humidity, wind);

  if (apparent >= 45 || temp >= 46) {
    return _reading(
      level: ComfortLevel.danger,
      title: 'Extreme heat — stay indoors',
      summary:
          'Outdoor air is far too hot for normal activity (${temp.round()}°C sensed).',
      precautions: _extremeHeatPrecautions,
      temp: temp,
      apparent: apparent,
      humidity: humidity,
      wind: wind,
    );
  }

  if (apparent >= 39 || temp >= 40) {
    return _reading(
      level: ComfortLevel.danger,
      title: 'Dangerous heat',
      summary:
          'Heat can cause heatstroke quickly. Felt temperature ~${apparent.round()}°C.',
      precautions: _highHeatPrecautions,
      temp: temp,
      apparent: apparent,
      humidity: humidity,
      wind: wind,
    );
  }

  if (apparent >= 32 || (temp >= 35 && humidity >= 60)) {
    return _reading(
      level: ComfortLevel.warning,
      title: 'Very hot — limit time outside',
      summary:
          'Air feels heavy and hot (~${apparent.round()}°C). Not ideal for long exposure.',
      precautions: _moderateHeatPrecautions,
      temp: temp,
      apparent: apparent,
      humidity: humidity,
      wind: wind,
    );
  }

  if (apparent <= -25 || temp <= -20) {
    return _reading(
      level: ComfortLevel.danger,
      title: 'Extreme cold — frostbite risk',
      summary:
          'Freezing conditions (${temp.round()}°C). Skin can freeze in minutes.',
      precautions: _extremeColdPrecautions,
      temp: temp,
      apparent: apparent,
      humidity: humidity,
      wind: wind,
    );
  }

  if (apparent <= -15 || temp <= -10) {
    return _reading(
      level: ComfortLevel.danger,
      title: 'Severe cold',
      summary:
          'Wind-chill ~${apparent.round()}°C. Avoid long outdoor exposure.',
      precautions: _severeColdPrecautions,
      temp: temp,
      apparent: apparent,
      humidity: humidity,
      wind: wind,
    );
  }

  if (apparent <= 0 || temp <= 2) {
    return _reading(
      level: ComfortLevel.warning,
      title: 'Cold — dress warmly',
      summary:
          'Temperature ${temp.round()}°C feels like ${apparent.round()}°C with wind.',
      precautions: _coldPrecautions,
      temp: temp,
      apparent: apparent,
      humidity: humidity,
      wind: wind,
    );
  }

  if (temp <= 10) {
    return _reading(
      level: ComfortLevel.caution,
      title: 'Cool air — light layers advised',
      summary:
          'Mild chill (${temp.round()}°C). Fine for short walks, not for thin clothing.',
      precautions: _coolPrecautions,
      temp: temp,
      apparent: apparent,
      humidity: humidity,
      wind: wind,
    );
  }

  if (temp >= 28 && temp < 32) {
    return _reading(
      level: ComfortLevel.caution,
      title: 'Warm — stay hydrated',
      summary:
          '${temp.round()}°C outside. Comfortable for most; drink water if active.',
      precautions: _warmPrecautions,
      temp: temp,
      apparent: apparent,
      humidity: humidity,
      wind: wind,
    );
  }

  if (wind >= 50) {
    return _reading(
      level: ComfortLevel.warning,
      title: 'Strong wind alert',
      summary:
          'Wind ${wind.round()} km/h can make breathing and balance harder outdoors.',
      precautions: _windPrecautions,
      temp: temp,
      apparent: apparent,
      humidity: humidity,
      wind: wind,
    );
  }

  if (humidity >= 90 && temp >= 24) {
    return _reading(
      level: ComfortLevel.caution,
      title: 'Very humid air',
      summary:
          'High humidity ($humidity%) makes air feel stuffy and harder to cool down.',
      precautions: _humidityPrecautions,
      temp: temp,
      apparent: apparent,
      humidity: humidity,
      wind: wind,
    );
  }

  return _reading(
    level: ComfortLevel.comfortable,
    title: 'Comfortable for humans',
    summary:
        'Outdoor conditions (~${temp.round()}°C) are generally fine for normal activity.',
    precautions: const [
      'Enjoy outdoor time with normal sun protection if sunny.',
      'Drink water regularly during exercise.',
    ],
    temp: temp,
    apparent: apparent,
    humidity: humidity,
    wind: wind,
  );
}

double _apparentTemperature(double tempC, int humidity, double windKmh) {
  if (tempC >= 27 && humidity >= 40) {
    final e = 6.11 * math.pow(10, (7.5 * tempC) / (237.7 + tempC));
    return tempC + 0.5555 * ((e * humidity / 100) - 10);
  }
  if (tempC <= 10 && windKmh > 4.8) {
    return 13.12 +
        0.6215 * tempC -
        11.37 * math.pow(windKmh, 0.16) +
        0.3965 * tempC * math.pow(windKmh, 0.16);
  }
  return tempC;
}

HumanComfortReading _reading({
  required ComfortLevel level,
  required String title,
  required String summary,
  required List<String> precautions,
  required double temp,
  required double apparent,
  required int humidity,
  required double wind,
}) {
  return HumanComfortReading(
    level: level,
    title: title,
    summary: summary,
    precautions: precautions,
    temperatureC: temp,
    apparentTemperatureC: apparent,
    humidity: humidity,
    windSpeedKmh: wind,
  );
}

const _extremeHeatPrecautions = [
  'Do not stay outside unless absolutely necessary.',
  'Stay in air-conditioned or shaded indoor spaces.',
  'Drink water every 15–20 minutes; avoid alcohol and caffeine.',
  'Check on elderly people, children, and pets.',
  'Wear loose, light cotton clothing if you must go out.',
  'Seek medical help if you feel dizzy, confused, or stop sweating.',
];

const _highHeatPrecautions = [
  'Avoid outdoor work between 11 AM and 4 PM.',
  'Wear a hat, sunglasses, and light-colored clothes.',
  'Drink at least 2–3 liters of water today.',
  'Take breaks in shade every 20–30 minutes.',
  'Never leave children or pets in a parked car.',
];

const _moderateHeatPrecautions = [
  'Limit strenuous outdoor activity.',
  'Use sunscreen and reapply every 2 hours.',
  'Carry a water bottle when leaving home.',
  'Prefer light meals; avoid heavy hot food at midday.',
];

const _extremeColdPrecautions = [
  'Stay indoors; cover all exposed skin if you must go out.',
  'Wear thermal layers, gloves, hat, and warm boots.',
  'Watch for numb fingers, toes, or pale skin (frostbite).',
  'Keep emergency blankets and hot drinks ready.',
];

const _severeColdPrecautions = [
  'Wear a warm coat, scarf, gloves, and closed shoes.',
  'Limit outdoor time to essential trips only.',
  'Keep home heating on; check gas heaters are ventilated.',
  'Help neighbors who may be at risk in cold weather.',
];

const _coldPrecautions = [
  'Wear a jacket or sweater when going outside.',
  'Cover head and hands in windy conditions.',
  'Warm up with hot drinks after being outdoors.',
];

const _coolPrecautions = [
  'Wear a light jacket, especially in the morning and evening.',
  'Children and older adults may need an extra layer.',
];

const _warmPrecautions = [
  'Drink water before you feel thirsty.',
  'Take shade breaks if walking or exercising outside.',
];

const _windPrecautions = [
  'Secure loose objects on balconies and roofs.',
  'Avoid standing under trees or weak structures.',
  'Drivers: reduce speed and hold the steering wheel firmly.',
];

const _humidityPrecautions = [
  'Prefer loose, breathable cotton clothing.',
  'Use fans or ventilation indoors.',
  'Shower and change clothes if you feel sticky or tired.',
];
