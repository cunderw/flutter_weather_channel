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

    test(
      'falls back to Nominatim for US zip code when Open-Meteo fails',
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

        // First call to Open-Meteo returns empty
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

        // Second call to Nominatim returns results
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

        // Verify both APIs were called
        verify(() => mockClient.get(any())).called(1);
        verify(
          () => mockClient.get(any(), headers: any(named: 'headers')),
        ).called(1);
      },
    );

    test('throws exception when both APIs fail for zip code', () async {
      // Arrange
      const zipCode = '99999';
      final openMeteoEmptyResponse = {'generationtime_ms': 0.21648407};
      final nominatimEmptyResponse = <Map<String, dynamic>>[];

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

      when(
        () => mockClient.get(
          any(
            that: predicate<Uri>((uri) => uri.toString().contains('nominatim')),
          ),
          headers: any(named: 'headers'),
        ),
      ).thenAnswer(
        (_) async => http.Response(json.encode(nominatimEmptyResponse), 200),
      );

      // Act & Assert
      expect(() => service.search(zipCode), throwsA(isA<GeocodingException>()));
    });

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

    test('recognizes various formats as zip codes or city names', () async {
      // Arrange - Test that 5-digit inputs trigger Nominatim fallback
      const validZipCode = '12345';
      final openMeteoEmptyResponse = {'generationtime_ms': 0.21648407};
      final nominatimResponse = [
        {
          'lat': '42.8142',
          'lon': '-73.9396',
          'address': {'city': 'Schenectady', 'state': 'New York'},
        },
      ];

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

      when(
        () => mockClient.get(
          any(
            that: predicate<Uri>((uri) => uri.toString().contains('nominatim')),
          ),
          headers: any(named: 'headers'),
        ),
      ).thenAnswer(
        (_) async => http.Response(json.encode(nominatimResponse), 200),
      );

      // Act - Search with valid 5-digit zip code
      final result = await service.search(validZipCode);

      // Assert - Should successfully use Nominatim fallback
      expect(result.zip, validZipCode);
      // Verify Nominatim was called (indicating zip code was recognized)
      verify(
        () => mockClient.get(
          any(
            that: predicate<Uri>((uri) => uri.toString().contains('nominatim')),
          ),
          headers: any(named: 'headers'),
        ),
      ).called(1);
    });
  });
}
