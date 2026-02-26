import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../config/theme.dart';
import '../models/forecast.dart';
import '../utils/weather_icons.dart';

/// A continuously scrolling horizontal ticker at the bottom of the TV view
/// showing hourly forecast data.
class ForecastTicker extends StatefulWidget {
  final List<HourlyForecast> hourlyForecasts;

  const ForecastTicker({super.key, required this.hourlyForecasts});

  @override
  State<ForecastTicker> createState() => _ForecastTickerState();
}

class _ForecastTickerState extends State<ForecastTicker> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    // Start scrolling after the widget is built.
    WidgetsBinding.instance.addPostFrameCallback((_) => _startScrolling());
  }

  void _startScrolling() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final duration = Duration(milliseconds: (maxScroll * 30).toInt());

    _scrollController
        .animateTo(maxScroll, duration: duration, curve: Curves.linear)
        .then((_) {
          // Reset and scroll again.
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
    final timeFormat = DateFormat('ha'); // e.g. "3PM"

    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: WeatherColors.tickerBlue,
        border: const Border(
          top: BorderSide(color: WeatherColors.textYellow, width: 3),
        ),
        boxShadow: [
          BoxShadow(
            color: WeatherColors.textYellow.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: widget.hourlyForecasts.length,
        itemBuilder: (context, index) {
          final hour = widget.hourlyForecasts[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  timeFormat.format(hour.time),
                  style: WeatherTextStyles.ticker(
                    color: WeatherColors.textWhite,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  WeatherIcons.icon(hour.weatherCode),
                  color: WeatherColors.textWhite,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  '${hour.temperature.round()}°',
                  style: WeatherTextStyles.ticker(
                    color: WeatherColors.textYellow,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 1,
                  height: 24,
                  color: WeatherColors.textWhite.withValues(alpha: 0.3),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
