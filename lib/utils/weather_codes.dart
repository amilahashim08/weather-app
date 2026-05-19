// WMO weather interpretation codes (Open-Meteo).
// Maps numeric codes to labels and emoji for simple UI (no asset bundle needed).

class WeatherInfo {
  const WeatherInfo({required this.label, required this.emoji});

  final String label;
  final String emoji;
}

WeatherInfo weatherInfoFromCode(int code) {
  if (code == 0) {
    return const WeatherInfo(label: 'Clear sky', emoji: '☀️');
  }
  if (code <= 3) {
    return const WeatherInfo(label: 'Partly cloudy', emoji: '⛅');
  }
  if (code <= 48) {
    return const WeatherInfo(label: 'Foggy', emoji: '🌫️');
  }
  if (code <= 57) {
    return const WeatherInfo(label: 'Drizzle', emoji: '🌦️');
  }
  if (code <= 67) {
    return const WeatherInfo(label: 'Rain', emoji: '🌧️');
  }
  if (code <= 77) {
    return const WeatherInfo(label: 'Snow', emoji: '❄️');
  }
  if (code <= 82) {
    return const WeatherInfo(label: 'Rain showers', emoji: '🌧️');
  }
  if (code <= 86) {
    return const WeatherInfo(label: 'Snow showers', emoji: '🌨️');
  }
  if (code <= 99) {
    return const WeatherInfo(label: 'Thunderstorm', emoji: '⛈️');
  }
  return const WeatherInfo(label: 'Unknown', emoji: '🌡️');
}
