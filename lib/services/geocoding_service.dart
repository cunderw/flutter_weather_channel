import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/location.dart';
import '../utils/constants.dart';

/// Converts a zip code or city name to geographic coordinates.
/// Uses Open-Meteo Geocoding API first, falling back to Nominatim
/// for US zip codes when Open-Meteo returns no results.
class GeocodingService {
  final http.Client _client;

  GeocodingService({http.Client? client}) : _client = client ?? http.Client();

  /// Searches for a location by [query] (zip code or city name).
  /// Returns the first matching [Location], or throws on failure.
  ///
  /// For zip codes, Open-Meteo is tried first. If it returns no results,
  /// Nominatim is used as a fallback.
  Future<Location> search(String query) async {
    // Trim whitespace once at the start
    final trimmedQuery = query.trim();
    final isZip = _isUSZipCode(trimmedQuery);

    // Always try Open-Meteo first
    try {
      final location = await _searchOpenMeteo(trimmedQuery);
      // Attach zip code to result if the query was a zip
      if (isZip) {
        return Location(
          latitude: location.latitude,
          longitude: location.longitude,
          city: location.city,
          state: location.state,
          zip: trimmedQuery,
        );
      }
      return location;
    } on GeocodingException {
      // If it's a zip code, fall back to Nominatim
      if (isZip) {
        return await _searchByZipCode(trimmedQuery);
      }
      rethrow;
    }
  }

  /// Searches using the Open-Meteo Geocoding API.
  Future<Location> _searchOpenMeteo(String query) async {
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
    return RegExp(r'^\d{5}$').hasMatch(query);
  }

  /// Searches for a US zip code using the Nominatim API.
  Future<Location> _searchByZipCode(String zipCode) async {
    final uri = Uri.parse(
      '${ApiConstants.nominatimSearchUrl}'
      '?postalcode=${Uri.encodeComponent(zipCode)}'
      '&country=US&format=json&limit=1',
    );

    final response = await _client.get(
      uri,
      headers: {'User-Agent': 'FlutterWeatherChannel/1.0'},
    );

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
    final dynamic rawLat = json['lat'];
    final dynamic rawLon = json['lon'];

    if (rawLat == null || rawLon == null) {
      throw GeocodingException(
        'Nominatim response missing latitude/longitude for zip "$zip"',
      );
    }

    double lat;
    double lon;

    try {
      if (rawLat is num) {
        lat = rawLat.toDouble();
      } else if (rawLat is String) {
        lat = double.parse(rawLat);
      } else {
        throw GeocodingException(
          'Unexpected latitude type "${rawLat.runtimeType}" for zip "$zip"',
        );
      }

      if (rawLon is num) {
        lon = rawLon.toDouble();
      } else if (rawLon is String) {
        lon = double.parse(rawLon);
      } else {
        throw GeocodingException(
          'Unexpected longitude type "${rawLon.runtimeType}" for zip "$zip"',
        );
      }
    } on FormatException catch (e) {
      throw GeocodingException(
        'Failed to parse coordinates from Nominatim for zip "$zip": ${e.message}',
      );
    } on TypeError catch (e) {
      throw GeocodingException(
        'Invalid coordinate types from Nominatim for zip "$zip": $e',
      );
    }
    // Extract city and state from address object
    String city = 'Unknown';
    String state = '';

    final address = json['address'] as Map<String, dynamic>?;
    if (address != null) {
      city =
          (address['city'] as String?) ??
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
