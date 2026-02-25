import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/weather_service.dart';
import '../../utils/constants.dart';
import 'weather_event.dart';
import 'weather_state.dart';

class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  final WeatherService _weatherService;
  Timer? _refreshTimer;
  double? _lastLat;
  double? _lastLon;

  WeatherBloc({required WeatherService weatherService})
    : _weatherService = weatherService,
      super(const WeatherInitial()) {
    on<FetchWeather>(_onFetchWeather);
    on<RefreshWeather>(_onRefreshWeather);
  }

  Future<void> _onFetchWeather(
    FetchWeather event,
    Emitter<WeatherState> emit,
  ) async {
    emit(const WeatherLoading());
    _lastLat = event.latitude;
    _lastLon = event.longitude;

    try {
      final result = await _weatherService.fetchWeather(
        lat: event.latitude,
        lon: event.longitude,
      );
      final radarUrl = await _weatherService.fetchRadarUrl(
        lat: event.latitude,
        lon: event.longitude,
      );

      emit(
        WeatherLoaded(
          weather: result.weather,
          forecast: result.forecast,
          radarUrl: radarUrl,
        ),
      );

      // Start auto-refresh timer
      _startRefreshTimer();
    } catch (e) {
      emit(WeatherError(e.toString()));
    }
  }

  Future<void> _onRefreshWeather(
    RefreshWeather event,
    Emitter<WeatherState> emit,
  ) async {
    if (_lastLat == null || _lastLon == null) return;

    try {
      final result = await _weatherService.fetchWeather(
        lat: _lastLat!,
        lon: _lastLon!,
      );
      final radarUrl = await _weatherService.fetchRadarUrl(
        lat: _lastLat!,
        lon: _lastLon!,
      );

      emit(
        WeatherLoaded(
          weather: result.weather,
          forecast: result.forecast,
          radarUrl: radarUrl,
        ),
      );
    } catch (_) {
      // On refresh failure, keep existing data — don't emit error.
    }
  }

  void _startRefreshTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(
      TimingConstants.weatherRefreshInterval,
      (_) => add(const RefreshWeather()),
    );
  }

  @override
  Future<void> close() {
    _refreshTimer?.cancel();
    return super.close();
  }
}
