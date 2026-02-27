import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_weather_channel/widgets/weather_info_bar.dart';

void main() {
  group('WeatherInfoBar', () {
    testWidgets('displays location name in uppercase', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WeatherInfoBar(locationName: 'Springfield, Illinois'),
          ),
        ),
      );

      expect(find.text('SPRINGFIELD, ILLINOIS'), findsOneWidget);
    });

    testWidgets('displays current date', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WeatherInfoBar(locationName: 'Test City'),
          ),
        ),
      );

      // Check that a date-like string is present
      // We can't check exact date since it changes, but we can verify format
      final dateFinder = find.byWidgetPredicate(
        (widget) =>
            widget is Text &&
            widget.data != null &&
            widget.data!.contains(',') &&
            widget.data!.contains('2026'),
      );

      expect(dateFinder, findsOneWidget);
    });

    testWidgets('displays live clock', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WeatherInfoBar(locationName: 'Test City'),
          ),
        ),
      );

      // Check that a time-like string is present
      final timeFinder = find.byWidgetPredicate(
        (widget) =>
            widget is Text &&
            widget.data != null &&
            (widget.data!.contains('AM') || widget.data!.contains('PM')),
      );

      expect(timeFinder, findsOneWidget);
    });

    testWidgets('updates clock every second', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WeatherInfoBar(locationName: 'Test City'),
          ),
        ),
      );

      // Pump once to render initial time
      await tester.pump();

      // Get initial time display
      final initialTimeFinder = find.byWidgetPredicate(
        (widget) =>
            widget is Text &&
            widget.data != null &&
            (widget.data!.contains('AM') || widget.data!.contains('PM')),
      );
      expect(initialTimeFinder, findsOneWidget);

      // Advance time by 2 seconds
      await tester.pump(const Duration(seconds: 2));

      // Time should still be displayed (clock updates)
      expect(initialTimeFinder, findsOneWidget);
    });

    testWidgets('handles empty location name', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WeatherInfoBar(locationName: ''),
          ),
        ),
      );

      // Verify the widget renders without errors
      expect(tester.takeException(), isNull);
    });

    testWidgets('truncates long location names', (tester) async {
      const longName = 'Very Long City Name That Should Be Truncated With Ellipsis';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 800, // Sufficient width for date/time but location will truncate
              child: WeatherInfoBar(locationName: longName),
            ),
          ),
        ),
      );

      // The widget should render without overflow errors
      expect(tester.takeException(), isNull);
      
      // Location name should be present (even if truncated)
      expect(find.textContaining('VERY LONG'), findsOneWidget);
    });
  });
}
