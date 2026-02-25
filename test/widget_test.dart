import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_weather_channel/models/weather.dart';
import 'package:flutter_weather_channel/models/forecast.dart';
import 'package:flutter_weather_channel/models/location.dart';
import 'package:flutter_weather_channel/utils/weather_icons.dart';

void main() {
  group('Location model', () {
    test('fromJson parses correctly', () {
      final json = {
        'latitude': 39.78,
        'longitude': -89.65,
        'name': 'Springfield',
        'admin1': 'Illinois',
      };
      final location = Location.fromJson(json);
      expect(location.city, 'Springfield');
      expect(location.state, 'Illinois');
      expect(location.displayName, 'Springfield, Illinois');
    });

    test('displayName without state', () {
      const location = Location(
        latitude: 0,
        longitude: 0,
        city: 'TestCity',
      );
      expect(location.displayName, 'TestCity');
    });
  });

  group('Weather model', () {
    test('fromJson parses current conditions', () {
      final json = {
        'current': {
          'temperature_2m': 72.5,
          'apparent_temperature': 70.0,
          'relative_humidity_2m': 65,
          'wind_speed_10m': 8.5,
          'wind_direction_10m': 225,
          'surface_pressure': 1013.0,
          'uv_index': 5.2,
          'visibility': 16093.0,
          'weather_code': 2,
        },
      };
      final weather = Weather.fromJson(json);
      expect(weather.temperature, 72.5);
      expect(weather.humidity, 65);
      expect(weather.weatherCode, 2);
      expect(weather.windDirectionCompass, 'SW');
      expect(weather.visibilityMiles, closeTo(10.0, 0.1));
    });
  });

  group('Forecast model', () {
    test('fromJson parses hourly and daily data', () {
      final json = {
        'hourly': {
          'time': ['2026-02-25T12:00', '2026-02-25T13:00'],
          'temperature_2m': [72.0, 74.0],
          'weather_code': [2, 3],
          'precipitation_probability': [10, 20],
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
      expect(forecast.hourly.length, 2);
      expect(forecast.hourly[0].temperature, 72.0);
      expect(forecast.daily.length, 1);
      expect(forecast.daily[0].high, 78.0);
      expect(forecast.daily[0].low, 58.0);
    });
  });

  group('WeatherIcons', () {
    test('returns correct description for WMO codes', () {
      expect(WeatherIcons.description(0), 'Clear Sky');
      expect(WeatherIcons.description(95), 'Thunderstorm');
      expect(WeatherIcons.description(999), 'Unknown');
    });
  });
}
