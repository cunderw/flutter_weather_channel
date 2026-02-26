import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/display/display_cubit.dart';
import '../blocs/display/display_state.dart';
import '../blocs/weather/weather_state.dart';
import '../models/location.dart';
import '../utils/constants.dart';
import 'current_conditions_panel.dart';
import 'radar_panel.dart';
import 'text_summary_panel.dart';

/// Auto-cycles between the three main content panels using AnimatedSwitcher.
class ContentCycler extends StatelessWidget {
  final WeatherLoaded weatherState;
  final Location location;

  const ContentCycler({
    super.key,
    required this.weatherState,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DisplayCubit, DisplayState>(
      builder: (context, displayState) {
        return AnimatedSwitcher(
          duration: TimingConstants.panelFadeDuration,
          child: _panelForState(displayState.panel),
        );
      },
    );
  }

  Widget _panelForState(ActivePanel panel) {
    switch (panel) {
      case ActivePanel.currentConditions:
        return CurrentConditionsPanel(
          key: const ValueKey('current'),
          weather: weatherState.weather,
        );
      case ActivePanel.radar:
        return RadarPanel(
          key: const ValueKey('radar'),
          radarUrl: weatherState.radarUrl,
          locationName: location.displayName,
          latitude: location.latitude,
          longitude: location.longitude,
        );
      case ActivePanel.textSummary:
        return TextSummaryPanel(
          key: const ValueKey('text'),
          weather: weatherState.weather,
          forecast: weatherState.forecast,
          location: location,
        );
    }
  }
}
