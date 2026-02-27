import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_weather_channel/blocs/weather/weather_bloc.dart';
import 'package:flutter_weather_channel/blocs/weather/weather_event.dart';
import 'package:flutter_weather_channel/blocs/weather/weather_state.dart';
import 'package:flutter_weather_channel/services/weather_service.dart';
import 'package:flutter_weather_channel/models/weather.dart';
import 'package:flutter_weather_channel/models/forecast.dart';

class MockWeatherService extends Mock implements WeatherService {}

void main() {
  group('WeatherBloc', () {
    late WeatherService mockWeatherService;

    setUp(() {
      mockWeatherService = MockWeatherService();
    });

    test('initial state is WeatherInitial', () {
      final bloc = WeatherBloc(weatherService: mockWeatherService);
      expect(bloc.state, const WeatherInitial());
      bloc.close();
    });

    group('FetchWeather', () {
      blocTest<WeatherBloc, WeatherState>(
        'emits [WeatherLoading, WeatherLoaded] on success',
        build: () {
          final mockWeather = const Weather(
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

          final mockForecast = Forecast(
            hourly: [
              HourlyForecast(
                time: DateTime(2026, 2, 25, 12),
                temperature: 72.0,
                weatherCode: 2,
                precipitationProbability: 10,
              ),
            ],
            daily: [
              DailyForecast(
                date: DateTime(2026, 2, 25),
                high: 78.0,
                low: 58.0,
                weatherCode: 2,
                precipitationProbability: 30,
              ),
            ],
          );

          when(
            () => mockWeatherService.fetchWeather(
              lat: any(named: 'lat'),
              lon: any(named: 'lon'),
            ),
          ).thenAnswer(
            (_) async => (weather: mockWeather, forecast: mockForecast),
          );

          when(
            () => mockWeatherService.fetchRadarUrl(
              lat: any(named: 'lat'),
              lon: any(named: 'lon'),
            ),
          ).thenAnswer((_) async => 'https://example.com/radar.png');

          return WeatherBloc(weatherService: mockWeatherService);
        },
        act: (bloc) =>
            bloc.add(const FetchWeather(latitude: 39.78, longitude: -89.65)),
        expect: () => [
          const WeatherLoading(),
          isA<WeatherLoaded>()
              .having((s) => s.weather.temperature, 'temperature', 72.5)
              .having((s) => s.forecast.hourly.length, 'hourly count', 1)
              .having(
                (s) => s.radarUrl,
                'radarUrl',
                'https://example.com/radar.png',
              ),
        ],
      );

      blocTest<WeatherBloc, WeatherState>(
        'emits [WeatherLoading, WeatherError] on fetchWeather failure',
        build: () {
          when(
            () => mockWeatherService.fetchWeather(
              lat: any(named: 'lat'),
              lon: any(named: 'lon'),
            ),
          ).thenThrow(WeatherException('API error'));

          return WeatherBloc(weatherService: mockWeatherService);
        },
        act: (bloc) =>
            bloc.add(const FetchWeather(latitude: 39.78, longitude: -89.65)),
        expect: () => [
          const WeatherLoading(),
          isA<WeatherError>().having(
            (s) => s.message,
            'message',
            contains('API error'),
          ),
        ],
      );

      blocTest<WeatherBloc, WeatherState>(
        'handles null radarUrl gracefully',
        build: () {
          final mockWeather = const Weather(
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

          final mockForecast = Forecast(hourly: [], daily: []);

          when(
            () => mockWeatherService.fetchWeather(
              lat: any(named: 'lat'),
              lon: any(named: 'lon'),
            ),
          ).thenAnswer(
            (_) async => (weather: mockWeather, forecast: mockForecast),
          );

          when(
            () => mockWeatherService.fetchRadarUrl(
              lat: any(named: 'lat'),
              lon: any(named: 'lon'),
            ),
          ).thenAnswer((_) async => null);

          return WeatherBloc(weatherService: mockWeatherService);
        },
        act: (bloc) =>
            bloc.add(const FetchWeather(latitude: 39.78, longitude: -89.65)),
        expect: () => [
          const WeatherLoading(),
          isA<WeatherLoaded>().having((s) => s.radarUrl, 'radarUrl', isNull),
        ],
      );
    });

    group('RefreshWeather', () {
      test('refreshes weather data after initial fetch', () async {
        final mockWeather = const Weather(
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

        final mockForecast = Forecast(hourly: [], daily: []);

        when(
          () => mockWeatherService.fetchWeather(
            lat: any(named: 'lat'),
            lon: any(named: 'lon'),
          ),
        ).thenAnswer(
          (_) async => (weather: mockWeather, forecast: mockForecast),
        );

        when(
          () => mockWeatherService.fetchRadarUrl(
            lat: any(named: 'lat'),
            lon: any(named: 'lon'),
          ),
        ).thenAnswer((_) async => 'https://example.com/radar.png');

        final bloc = WeatherBloc(weatherService: mockWeatherService);

        // First fetch to set location
        bloc.add(const FetchWeather(latitude: 39.78, longitude: -89.65));
        await Future.delayed(const Duration(milliseconds: 200));

        // Now refresh should work
        bloc.add(const RefreshWeather());
        await Future.delayed(const Duration(milliseconds: 200));

        // Verify the service was called twice
        verify(
          () => mockWeatherService.fetchWeather(
            lat: any(named: 'lat'),
            lon: any(named: 'lon'),
          ),
        ).called(2);

        await bloc.close();
      });

      blocTest<WeatherBloc, WeatherState>(
        'does not emit error on refresh failure',
        build: () {
          final mockWeather = const Weather(
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

          final mockForecast = Forecast(hourly: [], daily: []);

          when(
            () => mockWeatherService.fetchWeather(
              lat: any(named: 'lat'),
              lon: any(named: 'lon'),
            ),
          ).thenAnswer(
            (_) async => (weather: mockWeather, forecast: mockForecast),
          );

          when(
            () => mockWeatherService.fetchRadarUrl(
              lat: any(named: 'lat'),
              lon: any(named: 'lon'),
            ),
          ).thenAnswer((_) async => 'https://example.com/radar.png');

          return WeatherBloc(weatherService: mockWeatherService);
        },
        seed: () => WeatherLoaded(
          weather: const Weather(
            temperature: 72.5,
            feelsLike: 70.0,
            humidity: 65,
            windSpeed: 8.5,
            windDirection: 225,
            pressure: 1013.0,
            uvIndex: 5.2,
            visibility: 16093.0,
            weatherCode: 2,
          ),
          forecast: Forecast(hourly: [], daily: []),
          radarUrl: 'https://example.com/old_radar.png',
        ),
        act: (bloc) {
          // Set the last location manually first
          bloc.add(const FetchWeather(latitude: 39.78, longitude: -89.65));
          return Future.delayed(const Duration(milliseconds: 100)).then((_) {
            // Now mock failure
            when(
              () => mockWeatherService.fetchWeather(
                lat: any(named: 'lat'),
                lon: any(named: 'lon'),
              ),
            ).thenThrow(WeatherException('Network error'));

            bloc.add(const RefreshWeather());
          });
        },
        skip: 2, // Skip the initial fetch states
        expect: () => [],
      );

      blocTest<WeatherBloc, WeatherState>(
        'does nothing when RefreshWeather is called before FetchWeather',
        build: () => WeatherBloc(weatherService: mockWeatherService),
        act: (bloc) => bloc.add(const RefreshWeather()),
        expect: () => [],
      );
    });
  });
}
