import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_weather_channel/services/geocoding_service.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  late MockHttpClient mockClient;
  late GeocodingService service;

  setUp(() {
    mockClient = MockHttpClient();
    service = GeocodingService(client: mockClient);
  });

  setUpAll(() {
    registerFallbackValue(Uri());
  });

  group('GeocodingService', () {
    test('searches city name successfully using Open-Meteo', () async {
      // Arrange
      const query = 'Chicago';
      final openMeteoResponse = {
        'results': [
          {
            'latitude': 41.85,
            'longitude': -87.65,
            'name': 'Chicago',
            'admin1': 'Illinois',
          },
        ],
      };

      when(() => mockClient.get(any())).thenAnswer(
        (_) async => http.Response(json.encode(openMeteoResponse), 200),
      );

      // Act
      final result = await service.search(query);

      // Assert
      expect(result.latitude, 41.85);
      expect(result.longitude, -87.65);
      expect(result.city, 'Chicago');
      expect(result.state, 'Illinois');
    });

    test('uses Open-Meteo first for US zip codes when it succeeds', () async {
      // Arrange
      const zipCode = '66207';
      final openMeteoResponse = {
        'results': [
          {
            'latitude': 38.98,
            'longitude': -94.72,
            'name': 'Overland Park',
            'admin1': 'Kansas',
          },
        ],
      };

      when(
        () => mockClient.get(
          any(
            that: predicate<Uri>(
              (uri) => uri.toString().contains('geocoding-api'),
            ),
          ),
        ),
      ).thenAnswer(
        (_) async => http.Response(json.encode(openMeteoResponse), 200),
      );

      // Act
      final result = await service.search(zipCode);

      // Assert
      expect(result.latitude, 38.98);
      expect(result.longitude, -94.72);
      expect(result.city, 'Overland Park');
      expect(result.state, 'Kansas');
      expect(result.zip, '66207');

      // Verify Open-Meteo was called
      verify(
        () => mockClient.get(
          any(
            that: predicate<Uri>(
              (uri) => uri.toString().contains('geocoding-api'),
            ),
          ),
        ),
      ).called(1);
      // Verify Nominatim was NOT called
      verifyNever(
        () => mockClient.get(
          any(
            that: predicate<Uri>((uri) => uri.toString().contains('nominatim')),
          ),
          headers: any(named: 'headers'),
        ),
      );
    });

    test(
      'falls back to Nominatim when Open-Meteo fails for zip code',
      () async {
        // Arrange
        const zipCode = '66207';
        final openMeteoEmptyResponse = {'generationtime_ms': 0.21648407};
        final nominatimResponse = [
          {
            'lat': '38.9822',
            'lon': '-94.7151',
            'address': {'city': 'Shawnee', 'state': 'Kansas'},
          },
        ];

        // Open-Meteo returns no results
        when(
          () => mockClient.get(
            any(
              that: predicate<Uri>(
                (uri) => uri.toString().contains('geocoding-api'),
              ),
            ),
          ),
        ).thenAnswer(
          (_) async => http.Response(json.encode(openMeteoEmptyResponse), 200),
        );

        // Nominatim returns results as fallback
        when(
          () => mockClient.get(
            any(
              that: predicate<Uri>(
                (uri) => uri.toString().contains('nominatim'),
              ),
            ),
            headers: any(named: 'headers'),
          ),
        ).thenAnswer(
          (_) async => http.Response(json.encode(nominatimResponse), 200),
        );

        // Act
        final result = await service.search(zipCode);

        // Assert
        expect(result.latitude, 38.9822);
        expect(result.longitude, -94.7151);
        expect(result.city, 'Shawnee');
        expect(result.state, 'Kansas');
        expect(result.zip, '66207');

        // Verify both APIs were called (Open-Meteo first, then Nominatim)
        verify(
          () => mockClient.get(
            any(
              that: predicate<Uri>(
                (uri) => uri.toString().contains('geocoding-api'),
              ),
            ),
          ),
        ).called(1);
        verify(
          () => mockClient.get(
            any(
              that: predicate<Uri>(
                (uri) => uri.toString().contains('nominatim'),
              ),
            ),
            headers: any(named: 'headers'),
          ),
        ).called(1);
      },
    );

    test(
      'throws exception when both Open-Meteo and Nominatim fail for zip code',
      () async {
        // Arrange
        const zipCode = '99999';
        final openMeteoEmptyResponse = {'generationtime_ms': 0.21648407};
        final nominatimEmptyResponse = <Map<String, dynamic>>[];

        // Open-Meteo returns no results
        when(
          () => mockClient.get(
            any(
              that: predicate<Uri>(
                (uri) => uri.toString().contains('geocoding-api'),
              ),
            ),
          ),
        ).thenAnswer(
          (_) async => http.Response(json.encode(openMeteoEmptyResponse), 200),
        );

        // Nominatim also returns no results
        when(
          () => mockClient.get(
            any(
              that: predicate<Uri>(
                (uri) => uri.toString().contains('nominatim'),
              ),
            ),
            headers: any(named: 'headers'),
          ),
        ).thenAnswer(
          (_) async => http.Response(json.encode(nominatimEmptyResponse), 200),
        );

        // Act & Assert
        expect(
          () => service.search(zipCode),
          throwsA(isA<GeocodingException>()),
        );
      },
    );

    test('throws exception for non-zip code query with no results', () async {
      // Arrange
      const query = 'NonexistentCity';
      final openMeteoEmptyResponse = {'generationtime_ms': 0.21648407};

      when(() => mockClient.get(any())).thenAnswer(
        (_) async => http.Response(json.encode(openMeteoEmptyResponse), 200),
      );

      // Act & Assert
      expect(() => service.search(query), throwsA(isA<GeocodingException>()));
    });

    test('tries Open-Meteo first for zip codes before Nominatim', () async {
      // Arrange - Test that 5-digit inputs try Open-Meteo first
      const validZipCode = '12345';
      final openMeteoResponse = {
        'results': [
          {
            'latitude': 42.8142,
            'longitude': -73.9396,
            'name': 'Schenectady',
            'admin1': 'New York',
          },
        ],
      };

      when(
        () => mockClient.get(
          any(
            that: predicate<Uri>(
              (uri) => uri.toString().contains('geocoding-api'),
            ),
          ),
        ),
      ).thenAnswer(
        (_) async => http.Response(json.encode(openMeteoResponse), 200),
      );

      // Act - Search with valid 5-digit zip code
      final result = await service.search(validZipCode);

      // Assert - Should use Open-Meteo result and attach zip
      expect(result.zip, validZipCode);
      expect(result.latitude, 42.8142);
      expect(result.city, 'Schenectady');
      verify(
        () => mockClient.get(
          any(
            that: predicate<Uri>(
              (uri) => uri.toString().contains('geocoding-api'),
            ),
          ),
        ),
      ).called(1);
      // Verify Nominatim was NOT called since Open-Meteo succeeded
      verifyNever(
        () => mockClient.get(
          any(
            that: predicate<Uri>((uri) => uri.toString().contains('nominatim')),
          ),
          headers: any(named: 'headers'),
        ),
      );
    });

    test('handles zip codes with leading/trailing whitespace', () async {
      // Arrange - Test whitespace trimming
      const zipCodeWithWhitespace = '  66207  ';
      const expectedZipCode = '66207';
      final openMeteoResponse = {
        'results': [
          {
            'latitude': 38.9822,
            'longitude': -94.7151,
            'name': 'Overland Park',
            'admin1': 'Kansas',
          },
        ],
      };

      when(
        () => mockClient.get(
          any(
            that: predicate<Uri>(
              (uri) => uri.toString().contains('geocoding-api'),
            ),
          ),
        ),
      ).thenAnswer(
        (_) async => http.Response(json.encode(openMeteoResponse), 200),
      );

      // Act
      final result = await service.search(zipCodeWithWhitespace);

      // Assert - whitespace should be trimmed
      expect(result.latitude, 38.9822);
      expect(result.longitude, -94.7151);
      expect(result.zip, expectedZipCode);
    });
  });
}
