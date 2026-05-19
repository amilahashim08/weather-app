import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'app.dart';
import 'providers/weather_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz_data.initializeTimeZones();
  tz.setLocalLocation(tz.UTC);

  runApp(
    ChangeNotifierProvider(
      create: (_) => WeatherProvider(),
      child: const WeatherApp(),
    ),
  );
}
