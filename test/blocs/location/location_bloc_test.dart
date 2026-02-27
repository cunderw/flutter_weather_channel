import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_weather_channel/blocs/location/location_bloc.dart';
import 'package:flutter_weather_channel/blocs/location/location_event.dart';
import 'package:flutter_weather_channel/blocs/location/location_state.dart';
import 'package:flutter_weather_channel/services/geocoding_service.dart';
import 'package:flutter_weather_channel/models/location.dart';

class MockGeocodingService extends Mock implements GeocodingService {}

void main() {
  group('LocationBloc', () {
    late GeocodingService mockGeocodingService;

    setUp(() {
      mockGeocodingService = MockGeocodingService();
    });

    test('initial state is LocationInitial', () {
      final bloc = LocationBloc(geocodingService: mockGeocodingService);
      expect(bloc.state, const LocationInitial());
      bloc.close();
    });

    group('ZipCodeSubmitted', () {
      blocTest<LocationBloc, LocationState>(
        'emits [LocationLoading, LocationLoaded] on success',
        build: () {
          final mockLocation = const Location(
            latitude: 39.78,
            longitude: -89.65,
            city: 'Springfield',
            state: 'Illinois',
            zip: '62701',
          );

          when(() => mockGeocodingService.search(any()))
              .thenAnswer((_) async => mockLocation);

          return LocationBloc(geocodingService: mockGeocodingService);
        },
        act: (bloc) => bloc.add(const ZipCodeSubmitted('62701')),
        expect: () => [
          const LocationLoading(),
          isA<LocationLoaded>()
              .having((s) => s.location.city, 'city', 'Springfield')
              .having((s) => s.location.state, 'state', 'Illinois'),
        ],
      );

      blocTest<LocationBloc, LocationState>(
        'emits [LocationLoading, LocationError] on failure',
        build: () {
          when(() => mockGeocodingService.search(any()))
              .thenThrow(GeocodingException('No results found'));

          return LocationBloc(geocodingService: mockGeocodingService);
        },
        act: (bloc) => bloc.add(const ZipCodeSubmitted('99999')),
        expect: () => [
          const LocationLoading(),
          isA<LocationError>()
              .having((s) => s.message, 'message', contains('No results found')),
        ],
      );

      blocTest<LocationBloc, LocationState>(
        'passes query to geocoding service',
        build: () {
          final mockLocation = const Location(
            latitude: 40.71,
            longitude: -74.01,
            city: 'New York',
            state: 'New York',
          );

          when(() => mockGeocodingService.search(any()))
              .thenAnswer((_) async => mockLocation);

          return LocationBloc(geocodingService: mockGeocodingService);
        },
        act: (bloc) => bloc.add(const ZipCodeSubmitted('New York')),
        verify: (_) {
          verify(() => mockGeocodingService.search('New York')).called(1);
        },
      );
    });
  });
}
