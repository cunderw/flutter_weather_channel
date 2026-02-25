import 'dart:convert';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import '../models/weather.dart';
import '../models/forecast.dart';
import '../utils/constants.dart';

/// Fetches weather data from the Open-Meteo API.
class WeatherService {
  final http.Client _client;

  WeatherService({http.Client? client}) : _client = client ?? http.Client();

  /// Fetches current weather conditions and forecast for [lat], [lon].
  Future<({Weather weather, Forecast forecast})> fetchWeather({
    required double lat,
    required double lon,
  }) async {
    final uri = Uri.parse(
      '${ApiConstants.openMeteoForecastUrl}'
      '?latitude=$lat&longitude=$lon'
      '&current=${ApiConstants.currentFields}'
      '&hourly=${ApiConstants.hourlyFields}'
      '&daily=${ApiConstants.dailyFields}'
      '&temperature_unit=fahrenheit'
      '&wind_speed_unit=mph'
      '&timezone=auto',
    );

    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      throw WeatherException('API returned status ${response.statusCode}');
    }

    final data = json.decode(response.body) as Map<String, dynamic>;
    final weather = Weather.fromJson(data);
    final forecast = Forecast.fromJson(data);

    return (weather: weather, forecast: forecast);
  }

  /// Fetches the latest radar tile URL from RainViewer.
  Future<String?> fetchRadarUrl({
    required double lat,
    required double lon,
  }) async {
    try {
      final mapsResponse = await _client.get(
        Uri.parse(ApiConstants.rainViewerMapsUrl),
      );

      if (mapsResponse.statusCode != 200) return null;

      final mapsData = json.decode(mapsResponse.body) as Map<String, dynamic>;
      final radar = mapsData['radar'] as Map<String, dynamic>?;
      final past = radar?['past'] as List<dynamic>?;

      if (past == null || past.isEmpty) return null;

      // Use the most recent radar frame
      final latestFrame = past.last as Map<String, dynamic>;
      final path = latestFrame['path'] as String;

      // Build a 512x512 composite tile URL centered on the location.
      // RainViewer uses OSM-style z/x/y tiles. We use zoom level 6 for
      // a regional view.
      const zoom = 6;
      final x = _lonToTileX(lon, zoom);
      final y = _latToTileY(lat, zoom);

      return '${ApiConstants.rainViewerTileBase}$path/512/$zoom/$x/$y/2/1_1.png';
    } catch (_) {
      return null;
    }
  }

  /// Converts longitude to tile X coordinate (OSM slippy-map convention).
  int _lonToTileX(double lon, int zoom) {
    return ((lon + 180) / 360 * (1 << zoom)).floor();
  }

  /// Converts latitude to tile Y coordinate (OSM slippy-map convention).
  int _latToTileY(double lat, int zoom) {
    final latRad = lat * math.pi / 180;
    return ((1 - math.log(math.tan(latRad) + 1 / math.cos(latRad)) / math.pi) /
            2 *
            (1 << zoom))
        .floor();
  }
}

class WeatherException implements Exception {
  final String message;
  WeatherException(this.message);

  @override
  String toString() => 'WeatherException: $message';
}
