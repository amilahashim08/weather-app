import 'package:timezone/timezone.dart' as tz;

/// Parses Open-Meteo local timestamps (no offset suffix) in the location timezone.
tz.TZDateTime parseLocationDateTime(String isoLocal, String timezoneId) {
  final location = tz.getLocation(timezoneId);
  final parts = isoLocal.split('T');
  final date = parts[0].split('-').map(int.parse).toList();
  final time = parts.length > 1
      ? parts[1].split(':').map(int.parse).toList()
      : <int>[0, 0];

  return tz.TZDateTime(
    location,
    date[0],
    date[1],
    date[2],
    time[0],
    time.length > 1 ? time[1] : 0,
  );
}

/// Calendar date only (daily forecast rows).
tz.TZDateTime parseLocationDate(String isoDate, String timezoneId) {
  final location = tz.getLocation(timezoneId);
  final date = isoDate.split('-').map(int.parse).toList();
  return tz.TZDateTime(location, date[0], date[1], date[2]);
}

bool isTodayInTimezone(tz.TZDateTime date, String timezoneId) {
  final location = tz.getLocation(timezoneId);
  final now = tz.TZDateTime.now(location);
  return date.year == now.year &&
      date.month == now.month &&
      date.day == now.day;
}
