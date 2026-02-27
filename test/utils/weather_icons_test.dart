import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_weather_channel/utils/weather_icons.dart';

void main() {
  group('WeatherIcons', () {
    group('description', () {
      test('returns correct descriptions for common WMO codes', () {
        expect(WeatherIcons.description(0), 'Clear Sky');
        expect(WeatherIcons.description(1), 'Mainly Clear');
        expect(WeatherIcons.description(2), 'Partly Cloudy');
        expect(WeatherIcons.description(3), 'Overcast');
        expect(WeatherIcons.description(45), 'Foggy');
        expect(WeatherIcons.description(61), 'Slight Rain');
        expect(WeatherIcons.description(71), 'Slight Snowfall');
        expect(WeatherIcons.description(95), 'Thunderstorm');
      });

      test('returns "Unknown" for unrecognized codes', () {
        expect(WeatherIcons.description(999), 'Unknown');
        expect(WeatherIcons.description(-1), 'Unknown');
        expect(WeatherIcons.description(100), 'Unknown');
      });

      test('covers all documented WMO codes', () {
        // Test a representative sample of all code categories
        final testCodes = [
          0, 1, 2, 3, // Clear to overcast
          45, 48, // Fog
          51, 53, 55, 56, 57, // Drizzle
          61, 63, 65, 66, 67, // Rain
          71, 73, 75, 77, // Snow
          80, 81, 82, // Rain showers
          85, 86, // Snow showers
          95, 96, 99, // Thunderstorms
        ];

        for (final code in testCodes) {
          final description = WeatherIcons.description(code);
          expect(
            description,
            isNot('Unknown'),
            reason: 'Code $code should have a description',
          );
          expect(description, isNotEmpty);
        }
      });
    });

    group('icon', () {
      test('returns IconData for common WMO codes', () {
        expect(WeatherIcons.icon(0), isA<IconData>());
        expect(WeatherIcons.icon(2), isA<IconData>());
        expect(WeatherIcons.icon(61), isA<IconData>());
        expect(WeatherIcons.icon(95), isA<IconData>());
      });

      test('returns help_outline for unrecognized codes', () {
        expect(WeatherIcons.icon(999), Icons.help_outline);
        expect(WeatherIcons.icon(-1), Icons.help_outline);
      });

      test('returns different icons for different weather types', () {
        final clearIcon = WeatherIcons.icon(0);
        final cloudyIcon = WeatherIcons.icon(3);
        final rainIcon = WeatherIcons.icon(61);
        final snowIcon = WeatherIcons.icon(71);
        final thunderIcon = WeatherIcons.icon(95);

        // Icons should be distinct for different weather types
        final icons = {clearIcon, cloudyIcon, rainIcon, snowIcon, thunderIcon};
        expect(
          icons.length,
          greaterThan(1),
          reason: 'Different weather types should have different icons',
        );
      });
    });
  });
}
