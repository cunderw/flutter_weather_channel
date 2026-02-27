import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_weather_channel/models/forecast.dart';

void main() {
  group('HourlyForecast', () {
    test('creates instance with all fields', () {
      final forecast = HourlyForecast(
        time: DateTime(2026, 2, 25, 12),
        temperature: 72.0,
        weatherCode: 2,
        precipitationProbability: 10,
      );

      expect(forecast.time, DateTime(2026, 2, 25, 12));
      expect(forecast.temperature, 72.0);
      expect(forecast.weatherCode, 2);
      expect(forecast.precipitationProbability, 10);
    });

    test('equality works correctly', () {
      final forecast1 = HourlyForecast(
        time: DateTime(2026, 2, 25, 12),
        temperature: 72.0,
        weatherCode: 2,
        precipitationProbability: 10,
      );
      final forecast2 = HourlyForecast(
        time: DateTime(2026, 2, 25, 12),
        temperature: 72.0,
        weatherCode: 2,
        precipitationProbability: 10,
      );

      expect(forecast1, forecast2);
    });
  });

  group('DailyForecast', () {
    test('creates instance with all fields', () {
      final forecast = DailyForecast(
        date: DateTime(2026, 2, 25),
        high: 78.0,
        low: 58.0,
        weatherCode: 2,
        precipitationProbability: 30,
      );

      expect(forecast.date, DateTime(2026, 2, 25));
      expect(forecast.high, 78.0);
      expect(forecast.low, 58.0);
      expect(forecast.weatherCode, 2);
      expect(forecast.precipitationProbability, 30);
    });

    test('equality works correctly', () {
      final forecast1 = DailyForecast(
        date: DateTime(2026, 2, 25),
        high: 78.0,
        low: 58.0,
        weatherCode: 2,
        precipitationProbability: 30,
      );
      final forecast2 = DailyForecast(
        date: DateTime(2026, 2, 25),
        high: 78.0,
        low: 58.0,
        weatherCode: 2,
        precipitationProbability: 30,
      );

      expect(forecast1, forecast2);
    });
  });

  group('Forecast', () {
    group('fromJson', () {
      test('parses hourly and daily data correctly', () {
        final json = {
          'hourly': {
            'time': [
              '2026-02-25T12:00',
              '2026-02-25T13:00',
              '2026-02-25T14:00',
            ],
            'temperature_2m': [72.0, 74.0, 76.0],
            'weather_code': [2, 3, 1],
            'precipitation_probability': [10, 20, 5],
          },
          'daily': {
            'time': ['2026-02-25', '2026-02-26'],
            'temperature_2m_max': [78.0, 80.0],
            'temperature_2m_min': [58.0, 60.0],
            'weather_code': [2, 1],
            'precipitation_probability_max': [30, 15],
          },
        };

        final forecast = Forecast.fromJson(json);

        expect(forecast.hourly.length, 3);
        expect(forecast.hourly[0].temperature, 72.0);
        expect(forecast.hourly[0].weatherCode, 2);
        expect(forecast.hourly[1].temperature, 74.0);
        expect(forecast.hourly[2].temperature, 76.0);

        expect(forecast.daily.length, 2);
        expect(forecast.daily[0].high, 78.0);
        expect(forecast.daily[0].low, 58.0);
        expect(forecast.daily[1].high, 80.0);
        expect(forecast.daily[1].low, 60.0);
      });

      test('handles null precipitation probabilities', () {
        final json = {
          'hourly': {
            'time': ['2026-02-25T12:00'],
            'temperature_2m': [72.0],
            'weather_code': [2],
            'precipitation_probability': [null],
          },
          'daily': {
            'time': ['2026-02-25'],
            'temperature_2m_max': [78.0],
            'temperature_2m_min': [58.0],
            'weather_code': [2],
            'precipitation_probability_max': [null],
          },
        };

        final forecast = Forecast.fromJson(json);

        expect(forecast.hourly[0].precipitationProbability, 0);
        expect(forecast.daily[0].precipitationProbability, 0);
      });

      test('parses DateTime correctly from ISO strings', () {
        final json = {
          'hourly': {
            'time': ['2026-02-25T12:00'],
            'temperature_2m': [72.0],
            'weather_code': [2],
            'precipitation_probability': [10],
          },
          'daily': {
            'time': ['2026-02-25'],
            'temperature_2m_max': [78.0],
            'temperature_2m_min': [58.0],
            'weather_code': [2],
            'precipitation_probability_max': [30],
          },
        };

        final forecast = Forecast.fromJson(json);

        expect(forecast.hourly[0].time, DateTime(2026, 2, 25, 12, 0));
        expect(forecast.daily[0].date, DateTime(2026, 2, 25));
      });

      test('handles empty data arrays', () {
        final json = {
          'hourly': {
            'time': [],
            'temperature_2m': [],
            'weather_code': [],
            'precipitation_probability': [],
          },
          'daily': {
            'time': [],
            'temperature_2m_max': [],
            'temperature_2m_min': [],
            'weather_code': [],
            'precipitation_probability_max': [],
          },
        };

        final forecast = Forecast.fromJson(json);

        expect(forecast.hourly, isEmpty);
        expect(forecast.daily, isEmpty);
      });
    });

    group('equality', () {
      test('same values are equal', () {
        final forecast1 = Forecast(
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
        final forecast2 = Forecast(
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

        expect(forecast1, forecast2);
      });

      test('different values are not equal', () {
        final forecast1 = Forecast(
          hourly: [
            HourlyForecast(
              time: DateTime(2026, 2, 25, 12),
              temperature: 72.0,
              weatherCode: 2,
              precipitationProbability: 10,
            ),
          ],
          daily: [],
        );
        final forecast2 = Forecast(
          hourly: [
            HourlyForecast(
              time: DateTime(2026, 2, 25, 12),
              temperature: 75.0,
              weatherCode: 3,
              precipitationProbability: 20,
            ),
          ],
          daily: [],
        );

        expect(forecast1, isNot(forecast2));
      });
    });
  });
}
