import 'package:equatable/equatable.dart';

/// Current weather conditions parsed from Open-Meteo.
class Weather extends Equatable {
  /// Temperature in °F.
  final double temperature;

  /// Apparent / feels-like temperature in °F.
  final double feelsLike;

  /// Relative humidity as a percentage (0–100).
  final int humidity;

  /// Wind speed in mph.
  final double windSpeed;

  /// Wind direction in degrees (0 = N, 90 = E, etc.).
  final int windDirection;

  /// Surface pressure in hPa / mbar.
  final double pressure;

  /// UV index.
  final double uvIndex;

  /// Visibility in meters (converted to miles for display).
  final double visibility;

  /// WMO weather interpretation code.
  final int weatherCode;

  const Weather({
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.windDirection,
    required this.pressure,
    required this.uvIndex,
    required this.visibility,
    required this.weatherCode,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    final current = json['current'] as Map<String, dynamic>;
    return Weather(
      temperature: (current['temperature_2m'] as num).toDouble(),
      feelsLike: (current['apparent_temperature'] as num).toDouble(),
      humidity: (current['relative_humidity_2m'] as num).toInt(),
      windSpeed: (current['wind_speed_10m'] as num).toDouble(),
      windDirection: (current['wind_direction_10m'] as num).toInt(),
      pressure: (current['surface_pressure'] as num).toDouble(),
      uvIndex: (current['uv_index'] as num).toDouble(),
      visibility: (current['visibility'] as num).toDouble(),
      weatherCode: (current['weather_code'] as num).toInt(),
    );
  }

  /// Visibility converted from meters to miles.
  double get visibilityMiles => visibility / 1609.344;

  /// Compass direction string from wind degrees.
  String get windDirectionCompass {
    const directions = [
      'N',
      'NNE',
      'NE',
      'ENE',
      'E',
      'ESE',
      'SE',
      'SSE',
      'S',
      'SSW',
      'SW',
      'WSW',
      'W',
      'WNW',
      'NW',
      'NNW',
    ];
    final index = ((windDirection + 11.25) % 360 / 22.5).floor();
    return directions[index];
  }

  @override
  List<Object?> get props => [
    temperature,
    feelsLike,
    humidity,
    windSpeed,
    windDirection,
    pressure,
    uvIndex,
    visibility,
    weatherCode,
  ];
}
