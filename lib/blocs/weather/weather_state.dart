import 'package:equatable/equatable.dart';
import '../../models/weather.dart';
import '../../models/forecast.dart';

abstract class WeatherState extends Equatable {
  const WeatherState();

  @override
  List<Object?> get props => [];
}

class WeatherInitial extends WeatherState {
  const WeatherInitial();
}

class WeatherLoading extends WeatherState {
  const WeatherLoading();
}

class WeatherLoaded extends WeatherState {
  final Weather weather;
  final Forecast forecast;
  final String? radarUrl;

  const WeatherLoaded({
    required this.weather,
    required this.forecast,
    this.radarUrl,
  });

  @override
  List<Object?> get props => [weather, forecast, radarUrl];
}

class WeatherError extends WeatherState {
  final String message;
  const WeatherError(this.message);

  @override
  List<Object?> get props => [message];
}
