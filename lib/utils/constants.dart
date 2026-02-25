class ApiConstants {
  ApiConstants._();

  /// Open-Meteo forecast API base URL.
  static const String openMeteoForecastUrl =
      'https://api.open-meteo.com/v1/forecast';

  /// Open-Meteo geocoding API base URL.
  static const String openMeteoGeocodingUrl =
      'https://geocoding-api.open-meteo.com/v1/search';

  /// RainViewer weather-maps metadata endpoint.
  static const String rainViewerMapsUrl =
      'https://api.rainviewer.com/public/weather-maps.json';

  /// RainViewer tile base URL (composite radar).
  static const String rainViewerTileBase = 'https://tilecache.rainviewer.com';

  /// Current-condition fields requested from Open-Meteo.
  static const String currentFields =
      'temperature_2m,relative_humidity_2m,apparent_temperature,'
      'weather_code,wind_speed_10m,wind_direction_10m,'
      'surface_pressure,uv_index,visibility';

  /// Hourly forecast fields requested from Open-Meteo.
  static const String hourlyFields =
      'temperature_2m,weather_code,precipitation_probability';

  /// Daily forecast fields requested from Open-Meteo.
  static const String dailyFields =
      'temperature_2m_max,temperature_2m_min,weather_code,'
      'precipitation_probability_max';
}

class TimingConstants {
  TimingConstants._();

  /// Duration each content panel is shown before cycling.
  static const Duration panelCycleDuration = Duration(seconds: 8);

  /// Duration of the fade transition between panels.
  static const Duration panelFadeDuration = Duration(milliseconds: 800);

  /// Auto-refresh interval for weather data.
  static const Duration weatherRefreshInterval = Duration(minutes: 10);
}
