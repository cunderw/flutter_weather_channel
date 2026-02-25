import 'package:equatable/equatable.dart';

/// A single hourly forecast entry.
class HourlyForecast extends Equatable {
  final DateTime time;
  final double temperature;
  final int weatherCode;
  final int precipitationProbability;

  const HourlyForecast({
    required this.time,
    required this.temperature,
    required this.weatherCode,
    required this.precipitationProbability,
  });

  @override
  List<Object?> get props => [
    time,
    temperature,
    weatherCode,
    precipitationProbability,
  ];
}

/// A single daily forecast entry.
class DailyForecast extends Equatable {
  final DateTime date;
  final double high;
  final double low;
  final int weatherCode;
  final int precipitationProbability;

  const DailyForecast({
    required this.date,
    required this.high,
    required this.low,
    required this.weatherCode,
    required this.precipitationProbability,
  });

  @override
  List<Object?> get props => [
    date,
    high,
    low,
    weatherCode,
    precipitationProbability,
  ];
}

/// Complete forecast data parsed from Open-Meteo.
class Forecast extends Equatable {
  final List<HourlyForecast> hourly;
  final List<DailyForecast> daily;

  const Forecast({required this.hourly, required this.daily});

  factory Forecast.fromJson(Map<String, dynamic> json) {
    // Parse hourly data
    final hourlyData = json['hourly'] as Map<String, dynamic>;
    final hourlyTimes = (hourlyData['time'] as List).cast<String>();
    final hourlyTemps = (hourlyData['temperature_2m'] as List).cast<num>();
    final hourlyCodes = (hourlyData['weather_code'] as List).cast<num>();
    final hourlyPrecip = (hourlyData['precipitation_probability'] as List)
        .cast<num?>();

    final hourlyForecasts = <HourlyForecast>[];
    for (var i = 0; i < hourlyTimes.length; i++) {
      hourlyForecasts.add(
        HourlyForecast(
          time: DateTime.parse(hourlyTimes[i]),
          temperature: hourlyTemps[i].toDouble(),
          weatherCode: hourlyCodes[i].toInt(),
          precipitationProbability: (hourlyPrecip[i] ?? 0).toInt(),
        ),
      );
    }

    // Parse daily data
    final dailyData = json['daily'] as Map<String, dynamic>;
    final dailyTimes = (dailyData['time'] as List).cast<String>();
    final dailyHighs = (dailyData['temperature_2m_max'] as List).cast<num>();
    final dailyLows = (dailyData['temperature_2m_min'] as List).cast<num>();
    final dailyCodes = (dailyData['weather_code'] as List).cast<num>();
    final dailyPrecip = (dailyData['precipitation_probability_max'] as List)
        .cast<num?>();

    final dailyForecasts = <DailyForecast>[];
    for (var i = 0; i < dailyTimes.length; i++) {
      dailyForecasts.add(
        DailyForecast(
          date: DateTime.parse(dailyTimes[i]),
          high: dailyHighs[i].toDouble(),
          low: dailyLows[i].toDouble(),
          weatherCode: dailyCodes[i].toInt(),
          precipitationProbability: (dailyPrecip[i] ?? 0).toInt(),
        ),
      );
    }

    return Forecast(hourly: hourlyForecasts, daily: dailyForecasts);
  }

  @override
  List<Object?> get props => [hourly, daily];
}
