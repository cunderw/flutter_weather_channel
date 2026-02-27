import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_weather_channel/widgets/current_conditions_panel.dart';
import 'package:flutter_weather_channel/models/weather.dart';

void main() {
  group('CurrentConditionsPanel', () {
    testWidgets('displays temperature correctly', (tester) async {
      const weather = Weather(
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

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CurrentConditionsPanel(weather: weather),
          ),
        ),
      );

      expect(find.text('73°F'), findsOneWidget); // 72.5 rounds to 73
      expect(find.text('Feels Like 70°'), findsOneWidget);
    });

    testWidgets('displays weather description', (tester) async {
      const weather = Weather(
        temperature: 72.5,
        feelsLike: 70.0,
        humidity: 65,
        windSpeed: 8.5,
        windDirection: 225,
        pressure: 1013.0,
        uvIndex: 5.2,
        visibility: 16093.0,
        weatherCode: 2, // Partly Cloudy
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CurrentConditionsPanel(weather: weather),
          ),
        ),
      );

      expect(find.text('Partly Cloudy'), findsOneWidget);
    });

    testWidgets('displays all weather metrics', (tester) async {
      const weather = Weather(
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

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CurrentConditionsPanel(weather: weather),
          ),
        ),
      );

      // Check that key metrics are displayed
      expect(find.textContaining('65%'), findsWidgets); // Humidity
      expect(find.textContaining('8'), findsWidgets); // Wind speed (approximately)
      expect(find.textContaining('SW'), findsWidgets); // Wind direction
    });

    testWidgets('handles zero values gracefully', (tester) async {
      const weather = Weather(
        temperature: 0.0,
        feelsLike: -5.0,
        humidity: 0,
        windSpeed: 0.0,
        windDirection: 0,
        pressure: 1013.0,
        uvIndex: 0.0,
        visibility: 0.0,
        weatherCode: 0,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CurrentConditionsPanel(weather: weather),
          ),
        ),
      );

      expect(find.text('0°F'), findsOneWidget);
      expect(find.text('Clear Sky'), findsOneWidget);
    });

    testWidgets('displays correct wind direction compass', (tester) async {
      const weather = Weather(
        temperature: 72.5,
        feelsLike: 70.0,
        humidity: 65,
        windSpeed: 8.5,
        windDirection: 270, // West
        pressure: 1013.0,
        uvIndex: 5.2,
        visibility: 16093.0,
        weatherCode: 2,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CurrentConditionsPanel(weather: weather),
          ),
        ),
      );

      expect(find.textContaining('W'), findsWidgets); // West wind direction
    });
  });
}
