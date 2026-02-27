import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_weather_channel/models/weather.dart';

void main() {
  group('Weather', () {
    group('fromJson', () {
      test('parses all current weather fields', () {
        final json = {
          'current': {
            'temperature_2m': 72.5,
            'apparent_temperature': 70.0,
            'relative_humidity_2m': 65,
            'wind_speed_10m': 8.5,
            'wind_direction_10m': 225,
            'surface_pressure': 1013.0,
            'uv_index': 5.2,
            'visibility': 16093.0,
            'weather_code': 2,
          },
        };
        final weather = Weather.fromJson(json);

        expect(weather.temperature, 72.5);
        expect(weather.feelsLike, 70.0);
        expect(weather.humidity, 65);
        expect(weather.windSpeed, 8.5);
        expect(weather.windDirection, 225);
        expect(weather.pressure, 1013.0);
        expect(weather.uvIndex, 5.2);
        expect(weather.visibility, 16093.0);
        expect(weather.weatherCode, 2);
      });

      test('handles integer temperature values', () {
        final json = {
          'current': {
            'temperature_2m': 72,
            'apparent_temperature': 70,
            'relative_humidity_2m': 65,
            'wind_speed_10m': 8,
            'wind_direction_10m': 225,
            'surface_pressure': 1013,
            'uv_index': 5,
            'visibility': 16093,
            'weather_code': 2,
          },
        };
        final weather = Weather.fromJson(json);

        expect(weather.temperature, 72.0);
        expect(weather.feelsLike, 70.0);
      });
    });

    group('visibilityMiles', () {
      test('converts meters to miles correctly', () {
        const weather = Weather(
          temperature: 72.0,
          feelsLike: 70.0,
          humidity: 65,
          windSpeed: 8.5,
          windDirection: 225,
          pressure: 1013.0,
          uvIndex: 5.2,
          visibility: 16093.0, // approximately 10 miles
          weatherCode: 2,
        );

        expect(weather.visibilityMiles, closeTo(10.0, 0.1));
      });

      test('handles zero visibility', () {
        const weather = Weather(
          temperature: 72.0,
          feelsLike: 70.0,
          humidity: 65,
          windSpeed: 8.5,
          windDirection: 225,
          pressure: 1013.0,
          uvIndex: 5.2,
          visibility: 0.0,
          weatherCode: 2,
        );

        expect(weather.visibilityMiles, 0.0);
      });
    });

    group('windDirectionCompass', () {
      test('returns correct compass directions', () {
        const testCases = {
          0: 'N',
          45: 'NE',
          90: 'E',
          135: 'SE',
          180: 'S',
          225: 'SW',
          270: 'W',
          315: 'NW',
          360: 'N',
        };

        testCases.forEach((degrees, expected) {
          final weather = Weather(
            temperature: 72.0,
            feelsLike: 70.0,
            humidity: 65,
            windSpeed: 8.5,
            windDirection: degrees,
            pressure: 1013.0,
            uvIndex: 5.2,
            visibility: 16093.0,
            weatherCode: 2,
          );

          expect(
            weather.windDirectionCompass,
            expected,
            reason: '$degrees degrees should be $expected',
          );
        });
      });

      test('handles edge cases near boundaries', () {
        final weather1 = Weather(
          temperature: 72.0,
          feelsLike: 70.0,
          humidity: 65,
          windSpeed: 8.5,
          windDirection: 11, // Just past N threshold
          pressure: 1013.0,
          uvIndex: 5.2,
          visibility: 16093.0,
          weatherCode: 2,
        );

        expect(weather1.windDirectionCompass, 'N');

        final weather2 = Weather(
          temperature: 72.0,
          feelsLike: 70.0,
          humidity: 65,
          windSpeed: 8.5,
          windDirection: 22, // Should be NNE
          pressure: 1013.0,
          uvIndex: 5.2,
          visibility: 16093.0,
          weatherCode: 2,
        );

        expect(weather2.windDirectionCompass, 'NNE');
      });
    });

    group('equality', () {
      test('same values are equal', () {
        const weather1 = Weather(
          temperature: 72.5,
          feelsLike: 70.0,
          humidity: 65,
          windSpeed: 8.5,
          windDirection: 225,
          pressure: 1013.0,
          uvIndex: 5.2,
          visibility: 16093.0,
          weatherCode: 2,
        );
        const weather2 = Weather(
          temperature: 72.5,
          feelsLike: 70.0,
          humidity: 65,
          windSpeed: 8.5,
          windDirection: 225,
          pressure: 1013.0,
          uvIndex: 5.2,
          visibility: 16093.0,
          weatherCode: 2,
        );

        expect(weather1, weather2);
      });

      test('different values are not equal', () {
        const weather1 = Weather(
          temperature: 72.5,
          feelsLike: 70.0,
          humidity: 65,
          windSpeed: 8.5,
          windDirection: 225,
          pressure: 1013.0,
          uvIndex: 5.2,
          visibility: 16093.0,
          weatherCode: 2,
        );
        const weather2 = Weather(
          temperature: 75.0,
          feelsLike: 73.0,
          humidity: 70,
          windSpeed: 10.0,
          windDirection: 180,
          pressure: 1015.0,
          uvIndex: 6.0,
          visibility: 20000.0,
          weatherCode: 1,
        );

        expect(weather1, isNot(weather2));
      });
    });
  });
}
