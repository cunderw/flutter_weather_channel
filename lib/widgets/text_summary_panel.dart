import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/weather.dart';
import '../models/forecast.dart';
import '../models/location.dart';
import '../utils/weather_icons.dart';

/// Scrolling narrative text summary of current conditions and short-term forecast.
class TextSummaryPanel extends StatefulWidget {
  final Weather weather;
  final Forecast forecast;
  final Location location;

  const TextSummaryPanel({
    super.key,
    required this.weather,
    required this.forecast,
    required this.location,
  });

  @override
  State<TextSummaryPanel> createState() => _TextSummaryPanelState();
}

class _TextSummaryPanelState extends State<TextSummaryPanel> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startScrolling());
  }

  void _startScrolling() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    if (maxScroll <= 0) return;

    final duration = Duration(milliseconds: (maxScroll * 50).toInt());
    _scrollController
        .animateTo(maxScroll, duration: duration, curve: Curves.linear)
        .then((_) {
      if (mounted && _scrollController.hasClients) {
        _scrollController.jumpTo(0);
        _startScrolling();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final summary = _buildSummary();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CURRENT CONDITIONS',
            style: WeatherTextStyles.heading(
              size: 20,
              color: WeatherColors.textCyan,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Text(
                summary,
                style: WeatherTextStyles.body(
                  size: 20,
                  color: WeatherColors.textWhite,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _buildSummary() {
    final w = widget.weather;
    final f = widget.forecast;
    final loc = widget.location;
    final desc = WeatherIcons.description(w.weatherCode).toLowerCase();

    final buffer = StringBuffer();
    buffer.writeln(
      'Currently ${w.temperature.round()}°F and $desc '
      'in ${loc.displayName}.',
    );
    buffer.writeln();
    buffer.writeln(
      'Winds from the ${w.windDirectionCompass} at '
      '${w.windSpeed.round()} mph. Humidity at ${w.humidity}%. '
      'Barometric pressure ${w.pressure.round()} mb.',
    );

    if (w.feelsLike != w.temperature) {
      buffer.writeln();
      buffer.writeln('Feels like ${w.feelsLike.round()}°F.');
    }

    // Tonight's low / Tomorrow's high from daily forecast
    if (f.daily.isNotEmpty) {
      buffer.writeln();
      final today = f.daily.first;
      buffer.writeln(
        "Today's high: ${today.high.round()}°F. "
        "Low: ${today.low.round()}°F.",
      );

      if (f.daily.length > 1) {
        final tomorrow = f.daily[1];
        final tmrwDesc = WeatherIcons.description(tomorrow.weatherCode).toLowerCase();
        buffer.writeln();
        buffer.writeln(
          "Tomorrow: $tmrwDesc with a high of ${tomorrow.high.round()}°F "
          "and a low of ${tomorrow.low.round()}°F.",
        );
        if (tomorrow.precipitationProbability > 0) {
          buffer.writeln(
            '${tomorrow.precipitationProbability}% chance of precipitation.',
          );
        }
      }
    }

    return buffer.toString();
  }
}
