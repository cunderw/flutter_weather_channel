import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_weather_channel/widgets/forecast_ticker.dart';
import 'package:flutter_weather_channel/models/forecast.dart';

void main() {
  group('ForecastTicker', () {
    testWidgets('displays hourly forecast data', (tester) async {
      final hourlyForecasts = [
        HourlyForecast(
          time: DateTime(2026, 2, 25, 12),
          temperature: 72.0,
          weatherCode: 2,
          precipitationProbability: 10,
        ),
        HourlyForecast(
          time: DateTime(2026, 2, 25, 13),
          temperature: 74.0,
          weatherCode: 3,
          precipitationProbability: 20,
        ),
        HourlyForecast(
          time: DateTime(2026, 2, 25, 14),
          temperature: 76.0,
          weatherCode: 1,
          precipitationProbability: 5,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ForecastTicker(hourlyForecasts: hourlyForecasts),
          ),
        ),
      );

      // Check that forecast data is rendered
      expect(find.textContaining('72°'), findsWidgets);
      expect(find.textContaining('74°'), findsWidgets);
      expect(find.textContaining('76°'), findsWidgets);
    });

    testWidgets('handles empty forecast list', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ForecastTicker(hourlyForecasts: []),
          ),
        ),
      );

      // Should render without errors
      expect(tester.takeException(), isNull);
    });

    testWidgets('displays time for each forecast', (tester) async {
      final hourlyForecasts = [
        HourlyForecast(
          time: DateTime(2026, 2, 25, 12),
          temperature: 72.0,
          weatherCode: 2,
          precipitationProbability: 10,
        ),
        HourlyForecast(
          time: DateTime(2026, 2, 25, 15),
          temperature: 75.0,
          weatherCode: 1,
          precipitationProbability: 5,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ForecastTicker(hourlyForecasts: hourlyForecasts),
          ),
        ),
      );

      // Check that times are displayed (12 PM and 3 PM)
      expect(find.textContaining('12'), findsWidgets);
      expect(find.textContaining('PM'), findsWidgets);
    });

    testWidgets('shows weather icons', (tester) async {
      final hourlyForecasts = [
        HourlyForecast(
          time: DateTime(2026, 2, 25, 12),
          temperature: 72.0,
          weatherCode: 0, // Clear sky
          precipitationProbability: 0,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ForecastTicker(hourlyForecasts: hourlyForecasts),
          ),
        ),
      );

      // Check that an icon is rendered
      expect(find.byType(Icon), findsWidgets);
    });

    testWidgets('renders in a scrollable container', (tester) async {
      final hourlyForecasts = List.generate(
        24,
        (i) => HourlyForecast(
          time: DateTime(2026, 2, 25, i),
          temperature: 70.0 + i,
          weatherCode: 2,
          precipitationProbability: 10,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ForecastTicker(hourlyForecasts: hourlyForecasts),
          ),
        ),
      );

      // Should have a scroll controller
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });
  });
}
