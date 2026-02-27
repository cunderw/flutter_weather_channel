import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/location.dart';
import '../utils/constants.dart';

/// Converts a zip code or city name to geographic coordinates
/// using the Open-Meteo Geocoding API for city names and
/// Nominatim API for US zip codes.
class GeocodingService {
  final http.Client _client;

  GeocodingService({http.Client? client}) : _client = client ?? http.Client();

  /// Searches for a location by [query] (zip code or city name).
  /// Returns the first matching [Location], or throws on failure.
  Future<Location> search(String query) async {
    // If query is a US zip code, use Nominatim directly for accurate results
    if (_isUSZipCode(query)) {
      return await _searchByZipCode(query);
    }

    // Otherwise, use Open-Meteo for city/place name search
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

  /// Checks if the query looks like a US zip code (5 digits).
  bool _isUSZipCode(String query) {
    final trimmed = query.trim();
    return RegExp(r'^\d{5}$').hasMatch(trimmed);
  }

  /// Searches for a US zip code using the Nominatim API.
  Future<Location> _searchByZipCode(String zipCode) async {
    final uri = Uri.parse(
      '${ApiConstants.nominatimSearchUrl}'
      '?postalcode=${Uri.encodeComponent(zipCode)}'
      '&country=US&format=json&limit=1',
    );

    final response = await _client.get(uri, headers: {
      'User-Agent': 'FlutterWeatherChannel/1.0',
    });

    if (response.statusCode != 200) {
      throw GeocodingException(
        'Nominatim API returned status ${response.statusCode}',
      );
    }

    final data = json.decode(response.body);
    if (data is! List || data.isEmpty) {
      throw GeocodingException('No results found for zip code "$zipCode"');
    }

    final first = data[0] as Map<String, dynamic>;
    return _locationFromNominatim(first, zipCode);
  }

  /// Converts a Nominatim response to a [Location] object.
  Location _locationFromNominatim(Map<String, dynamic> json, String zip) {
    final lat = double.parse(json['lat'] as String);
    final lon = double.parse(json['lon'] as String);

    // Extract city and state from display_name or address
    String city = 'Unknown';
    String state = '';

    final address = json['address'] as Map<String, dynamic>?;
    if (address != null) {
      city = (address['city'] as String?) ??
          (address['town'] as String?) ??
          (address['village'] as String?) ??
          (address['hamlet'] as String?) ??
          'Unknown';
      state = (address['state'] as String?) ?? '';
    }

    return Location(
      latitude: lat,
      longitude: lon,
      city: city,
      state: state,
      zip: zip,
    );
  }
}

class GeocodingException implements Exception {
  final String message;
  GeocodingException(this.message);

  @override
  String toString() => 'GeocodingException: $message';
}
