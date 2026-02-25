import 'package:flutter/material.dart';

/// Maps WMO weather interpretation codes to human-readable descriptions
/// and Material Icons.
///
/// Reference: https://open-meteo.com/en/docs#weathervariables
class WeatherIcons {
  WeatherIcons._();

  /// Returns a human-readable description for a WMO weather code.
  static String description(int code) {
    return _wmoDescriptions[code] ?? 'Unknown';
  }

  /// Returns a Material [IconData] for a WMO weather code.
  static IconData icon(int code) {
    return _wmoIcons[code] ?? Icons.help_outline;
  }

  static const Map<int, String> _wmoDescriptions = {
    0: 'Clear Sky',
    1: 'Mainly Clear',
    2: 'Partly Cloudy',
    3: 'Overcast',
    45: 'Foggy',
    48: 'Depositing Rime Fog',
    51: 'Light Drizzle',
    53: 'Moderate Drizzle',
    55: 'Dense Drizzle',
    56: 'Light Freezing Drizzle',
    57: 'Dense Freezing Drizzle',
    61: 'Slight Rain',
    63: 'Moderate Rain',
    65: 'Heavy Rain',
    66: 'Light Freezing Rain',
    67: 'Heavy Freezing Rain',
    71: 'Slight Snowfall',
    73: 'Moderate Snowfall',
    75: 'Heavy Snowfall',
    77: 'Snow Grains',
    80: 'Slight Rain Showers',
    81: 'Moderate Rain Showers',
    82: 'Violent Rain Showers',
    85: 'Slight Snow Showers',
    86: 'Heavy Snow Showers',
    95: 'Thunderstorm',
    96: 'Thunderstorm w/ Slight Hail',
    99: 'Thunderstorm w/ Heavy Hail',
  };

  static const Map<int, IconData> _wmoIcons = {
    0: Icons.wb_sunny,
    1: Icons.wb_sunny,
    2: Icons.cloud_queue,
    3: Icons.cloud,
    45: Icons.foggy,
    48: Icons.foggy,
    51: Icons.grain,
    53: Icons.grain,
    55: Icons.grain,
    56: Icons.ac_unit,
    57: Icons.ac_unit,
    61: Icons.water_drop,
    63: Icons.water_drop,
    65: Icons.water_drop,
    66: Icons.ac_unit,
    67: Icons.ac_unit,
    71: Icons.ac_unit,
    73: Icons.ac_unit,
    75: Icons.ac_unit,
    77: Icons.ac_unit,
    80: Icons.beach_access,
    81: Icons.beach_access,
    82: Icons.beach_access,
    85: Icons.ac_unit,
    86: Icons.ac_unit,
    95: Icons.flash_on,
    96: Icons.flash_on,
    99: Icons.flash_on,
  };
}
