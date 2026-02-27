import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_weather_channel/services/weather_service.dart';

class MockClient extends Mock implements http.Client {}

class FakeUri extends Fake implements Uri {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeUri());
  });

  group('WeatherService', () {
    late WeatherService service;
    late MockClient mockClient;

    setUp(() {
      mockClient = MockClient();
      service = WeatherService(client: mockClient);
    });

    group('fetchWeather', () {
      test('returns weather and forecast on success', () async {
        final mockResponse = '''
        {
          "current": {
            "temperature_2m": 72.5,
            "apparent_temperature": 70.0,
            "relative_humidity_2m": 65,
            "wind_speed_10m": 8.5,
            "wind_direction_10m": 225,
            "surface_pressure": 1013.0,
            "uv_index": 5.2,
            "visibility": 16093.0,
            "weather_code": 2
          },
          "hourly": {
            "time": ["2026-02-25T12:00", "2026-02-25T13:00"],
            "temperature_2m": [72.0, 74.0],
            "weather_code": [2, 3],
            "precipitation_probability": [10, 20]
          },
          "daily": {
            "time": ["2026-02-25"],
            "temperature_2m_max": [78.0],
            "temperature_2m_min": [58.0],
            "weather_code": [2],
            "precipitation_probability_max": [30]
          }
        }
        ''';

        when(
          () => mockClient.get(any()),
        ).thenAnswer((_) async => http.Response(mockResponse, 200));

        final result = await service.fetchWeather(lat: 39.78, lon: -89.65);

        expect(result.weather.temperature, 72.5);
        expect(result.weather.humidity, 65);
        expect(result.forecast.hourly.length, 2);
        expect(result.forecast.daily.length, 1);
      });

      test('throws WeatherException on non-200 status', () {
        when(
          () => mockClient.get(any()),
        ).thenAnswer((_) async => http.Response('Error', 500));

        expect(
          () => service.fetchWeather(lat: 39.78, lon: -89.65),
          throwsA(isA<WeatherException>()),
        );
      });

      test('throws WeatherException on invalid JSON', () {
        when(
          () => mockClient.get(any()),
        ).thenAnswer((_) async => http.Response('Not JSON', 200));

        expect(
          () => service.fetchWeather(lat: 39.78, lon: -89.65),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('fetchRadarUrl', () {
      test('returns radar URL on success', () async {
        final mockRadarResponse = '''
        {
          "radar": {
            "past": [
              {
                "time": 1234567890,
                "path": "/v2/radar/1234567890"
              }
            ]
          }
        }
        ''';

        when(
          () => mockClient.get(any()),
        ).thenAnswer((_) async => http.Response(mockRadarResponse, 200));

        final url = await service.fetchRadarUrl(lat: 39.78, lon: -89.65);

        expect(url, isNotNull);
        expect(url, contains('tilecache.rainviewer.com'));
        expect(url, contains('/v2/radar/1234567890'));
      });

      test('returns null on non-200 status', () async {
        when(
          () => mockClient.get(any()),
        ).thenAnswer((_) async => http.Response('Error', 500));

        final url = await service.fetchRadarUrl(lat: 39.78, lon: -89.65);

        expect(url, isNull);
      });

      test('returns null when radar data is missing', () async {
        final mockRadarResponse = '''
        {
          "radar": {
            "past": []
          }
        }
        ''';

        when(
          () => mockClient.get(any()),
        ).thenAnswer((_) async => http.Response(mockRadarResponse, 200));

        final url = await service.fetchRadarUrl(lat: 39.78, lon: -89.65);

        expect(url, isNull);
      });

      test('returns null on parse exception', () async {
        when(
          () => mockClient.get(any()),
        ).thenAnswer((_) async => http.Response('Not JSON', 200));

        final url = await service.fetchRadarUrl(lat: 39.78, lon: -89.65);

        expect(url, isNull);
      });
    });
  });
}
