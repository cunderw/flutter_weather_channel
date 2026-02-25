import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/location.dart';
import '../utils/constants.dart';

/// Converts a zip code or city name to geographic coordinates
/// using the Open-Meteo Geocoding API.
class GeocodingService {
  final http.Client _client;

  GeocodingService({http.Client? client}) : _client = client ?? http.Client();

  /// Searches for a location by [query] (zip code or city name).
  /// Returns the first matching [Location], or throws on failure.
  Future<Location> search(String query) async {
    final uri = Uri.parse(
      '${ApiConstants.openMeteoGeocodingUrl}'
      '?name=${Uri.encodeComponent(query)}&count=1&language=en&format=json',
    );

    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      throw GeocodingException('API returned status ${response.statusCode}');
    }

    final data = json.decode(response.body) as Map<String, dynamic>;
    final results = data['results'] as List<dynamic>?;

    if (results == null || results.isEmpty) {
      throw GeocodingException('No results found for "$query"');
    }

    final first = results[0] as Map<String, dynamic>;
    return Location.fromJson(first);
  }
}

class GeocodingException implements Exception {
  final String message;
  GeocodingException(this.message);

  @override
  String toString() => 'GeocodingException: $message';
}
