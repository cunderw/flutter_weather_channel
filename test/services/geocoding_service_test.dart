import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_weather_channel/services/geocoding_service.dart';

class MockClient extends Mock implements http.Client {}

class FakeUri extends Fake implements Uri {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeUri());
  });

  group('GeocodingService', () {
    late GeocodingService service;
    late MockClient mockClient;

    setUp(() {
      mockClient = MockClient();
      service = GeocodingService(client: mockClient);
    });

    group('search', () {
      test('returns location on success', () async {
        final mockResponse = '''
        {
          "results": [
            {
              "latitude": 39.78,
              "longitude": -89.65,
              "name": "Springfield",
              "admin1": "Illinois"
            }
          ]
        }
        ''';

        when(
          () => mockClient.get(any()),
        ).thenAnswer((_) async => http.Response(mockResponse, 200));

        final location = await service.search('Springfield');

        expect(location.city, 'Springfield');
        expect(location.state, 'Illinois');
        expect(location.latitude, 39.78);
        expect(location.longitude, -89.65);
      });

      test('throws GeocodingException on non-200 status', () {
        when(
          () => mockClient.get(any()),
        ).thenAnswer((_) async => http.Response('Error', 500));

        expect(
          () => service.search('Springfield'),
          throwsA(isA<GeocodingException>()),
        );
      });

      test('throws GeocodingException when no results found', () {
        final mockResponse = '''
        {
          "results": []
        }
        ''';

        when(
          () => mockClient.get(any()),
        ).thenAnswer((_) async => http.Response(mockResponse, 200));

        expect(
          () => service.search('NonexistentCity'),
          throwsA(isA<GeocodingException>()),
        );
      });

      test('throws GeocodingException when results is null', () {
        final mockResponse = '''
        {
          "results": null
        }
        ''';

        when(
          () => mockClient.get(any()),
        ).thenAnswer((_) async => http.Response(mockResponse, 200));

        expect(
          () => service.search('NonexistentCity'),
          throwsA(isA<GeocodingException>()),
        );
      });

      test('URL encodes query parameter', () async {
        final mockResponse = '''
        {
          "results": [
            {
              "latitude": 40.71,
              "longitude": -74.01,
              "name": "New York",
              "admin1": "New York"
            }
          ]
        }
        ''';

        when(
          () => mockClient.get(any()),
        ).thenAnswer((_) async => http.Response(mockResponse, 200));

        await service.search('New York, NY');

        final captured = verify(() => mockClient.get(captureAny())).captured;
        final uri = captured[0] as Uri;
        expect(uri.queryParameters['name'], 'New York, NY');
      });
    });
  });
}
