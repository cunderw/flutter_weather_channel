import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/weather.dart';
import '../utils/weather_icons.dart';

/// Displays current weather conditions in a classic Weather Channel grid layout.
class CurrentConditionsPanel extends StatelessWidget {
  final Weather weather;

  const CurrentConditionsPanel({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Weather icon + description
          Icon(
            WeatherIcons.icon(weather.weatherCode),
            color: WeatherColors.textWhite,
            size: 48,
          ),
          const SizedBox(height: 4),
          Text(
            WeatherIcons.description(weather.weatherCode),
            style: WeatherTextStyles.body(
              size: 20,
              color: WeatherColors.textWhite,
              weight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          // Large temperature
          Text(
            '${weather.temperature.round()}°F',
            style: WeatherTextStyles.led(size: 72),
          ),
          Text(
            'Feels Like ${weather.feelsLike.round()}°',
            style: WeatherTextStyles.body(
              size: 16,
              color: WeatherColors.textGray,
            ),
          ),

          const SizedBox(height: 24),

          // Data grid
          _buildDataGrid(),
        ],
      ),
    );
  }

  Widget _buildDataGrid() {
    return Column(
      children: [
        // Thin yellow horizontal rule like broadcast lower-third graphics
        Container(
          height: 2,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                WeatherColors.textYellow.withValues(alpha: 0.6),
                WeatherColors.textYellow,
                WeatherColors.textYellow.withValues(alpha: 0.6),
                Colors.transparent,
              ],
            ),
          ),
        ),
        Table(
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            _dataRow(
              'Humidity',
              '${weather.humidity}%',
              'Wind',
              '${weather.windDirectionCompass} ${weather.windSpeed.round()} mph',
            ),
            _dataRow(
              'Pressure',
              '${weather.pressure.round()} mb',
              'UV Index',
              weather.uvIndex.toStringAsFixed(1),
            ),
            _dataRow(
              'Visibility',
              '${weather.visibilityMiles.toStringAsFixed(1)} mi',
              '',
              '',
            ),
          ],
        ),
      ],
    );
  }

  TableRow _dataRow(
    String label1,
    String value1,
    String label2,
    String value2,
  ) {
    return TableRow(
      children: [_dataCell(label1, value1), _dataCell(label2, value2)],
    );
  }

  Widget _dataCell(String label, String value) {
    if (label.isEmpty) return const SizedBox(height: 32);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: WeatherTextStyles.body(
              size: 14,
              color: WeatherColors.textCyan,
            ),
          ),
          Text(
            value,
            style: WeatherTextStyles.led(
              size: 24,
              color: WeatherColors.textYellow,
            ),
          ),
        ],
      ),
    );
  }
}
