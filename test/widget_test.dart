import 'package:flutter_test/flutter_test.dart';
import 'package:weather_app/utils/weather_codes.dart';

void main() {
  test('weather code 0 is clear sky', () {
    final info = weatherInfoFromCode(0);
    expect(info.label, 'Clear sky');
    expect(info.emoji, '☀️');
  });
}
