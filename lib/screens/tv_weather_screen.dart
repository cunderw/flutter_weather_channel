import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/display/display_cubit.dart';
import '../blocs/weather/weather_bloc.dart';
import '../blocs/weather/weather_event.dart';
import '../blocs/weather/weather_state.dart';
import '../config/theme.dart';
import '../models/location.dart';
import '../services/audio_service.dart';
import '../widgets/content_cycler.dart';
import '../widgets/forecast_ticker.dart';
import '../widgets/tv_frame.dart';
import '../widgets/weather_info_bar.dart';

/// Main TV broadcast view. Displays the weather info bar, cycling content
/// panels, and bottom forecast ticker with a CRT overlay.
class TvWeatherScreen extends StatefulWidget {
  final Location location;

  const TvWeatherScreen({super.key, required this.location});

  @override
  State<TvWeatherScreen> createState() => _TvWeatherScreenState();
}

class _TvWeatherScreenState extends State<TvWeatherScreen> {
  @override
  void initState() {
    super.initState();
    // Request immersive full-screen for the TV experience.
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // Start background music.
    context.read<AudioService>().play();

    // Fetch weather data.
    context.read<WeatherBloc>().add(
      FetchWeather(
        latitude: widget.location.latitude,
        longitude: widget.location.longitude,
      ),
    );

    // Start panel cycling.
    context.read<DisplayCubit>().startCycling();
  }

  @override
  void dispose() {
    // Stop background music.
    context.read<AudioService>().stop();
    // Restore system UI when leaving.
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    context.read<DisplayCubit>().stopCycling();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TvFrame(
        child: Container(
          decoration: const BoxDecoration(
            gradient: WeatherColors.backgroundGradient,
          ),
          child: BlocBuilder<WeatherBloc, WeatherState>(
            builder: (context, state) {
              if (state is WeatherLoading || state is WeatherInitial) {
                return _buildLoading();
              }
              if (state is WeatherError) {
                return _buildError(state.message);
              }
              if (state is WeatherLoaded) {
                return _buildWeatherView(state);
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: WeatherColors.textCyan),
          const SizedBox(height: 16),
          Text(
            'Loading forecast...',
            style: WeatherTextStyles.body(color: WeatherColors.textGray),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: WeatherColors.textRed,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'Unable to load weather data',
              style: WeatherTextStyles.heading(color: WeatherColors.textRed),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: WeatherTextStyles.body(color: WeatherColors.textGray),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                context.read<WeatherBloc>().add(
                  FetchWeather(
                    latitude: widget.location.latitude,
                    longitude: widget.location.longitude,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: WeatherColors.tickerBlue,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherView(WeatherLoaded state) {
    return Column(
      children: [
        // Top info bar
        WeatherInfoBar(locationName: widget.location.displayName),

        // Main cycling content area
        Expanded(
          child: ContentCycler(weatherState: state, location: widget.location),
        ),

        // Bottom forecast ticker
        ForecastTicker(hourlyForecasts: state.forecast.hourly),
      ],
    );
  }
}
