import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_weather_channel/models/location.dart';

void main() {
  group('Location', () {
    group('fromJson', () {
      test('parses all fields correctly', () {
        final json = {
          'latitude': 39.78,
          'longitude': -89.65,
          'name': 'Springfield',
          'admin1': 'Illinois',
          'zip': '62701',
        };
        final location = Location.fromJson(json);

        expect(location.latitude, 39.78);
        expect(location.longitude, -89.65);
        expect(location.city, 'Springfield');
        expect(location.state, 'Illinois');
        expect(location.zip, '62701');
      });

      test('handles missing optional fields', () {
        final json = {
          'latitude': 39.78,
          'longitude': -89.65,
          'name': 'Springfield',
        };
        final location = Location.fromJson(json);

        expect(location.city, 'Springfield');
        expect(location.state, '');
        expect(location.zip, isNull);
      });

      test('uses "Unknown" when name is missing', () {
        final json = {'latitude': 0.0, 'longitude': 0.0};
        final location = Location.fromJson(json);

        expect(location.city, 'Unknown');
      });
    });

    group('displayName', () {
      test('returns city and state when state is present', () {
        const location = Location(
          latitude: 39.78,
          longitude: -89.65,
          city: 'Springfield',
          state: 'Illinois',
        );

        expect(location.displayName, 'Springfield, Illinois');
      });

      test('returns only city when state is empty', () {
        const location = Location(
          latitude: 39.78,
          longitude: -89.65,
          city: 'Springfield',
          state: '',
        );

        expect(location.displayName, 'Springfield');
      });

      test('returns only city when state is not provided', () {
        const location = Location(latitude: 0, longitude: 0, city: 'TestCity');

        expect(location.displayName, 'TestCity');
      });
    });

    group('equality', () {
      test('same values are equal', () {
        const location1 = Location(
          latitude: 39.78,
          longitude: -89.65,
          city: 'Springfield',
          state: 'Illinois',
        );
        const location2 = Location(
          latitude: 39.78,
          longitude: -89.65,
          city: 'Springfield',
          state: 'Illinois',
        );

        expect(location1, location2);
      });

      test('different values are not equal', () {
        const location1 = Location(
          latitude: 39.78,
          longitude: -89.65,
          city: 'Springfield',
          state: 'Illinois',
        );
        const location2 = Location(
          latitude: 40.71,
          longitude: -74.01,
          city: 'New York',
          state: 'New York',
        );

        expect(location1, isNot(location2));
      });
    });
  });
}
