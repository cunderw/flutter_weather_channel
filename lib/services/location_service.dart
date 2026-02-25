import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geo;
import '../models/location.dart';

/// Wraps the geolocator + geocoding packages to obtain the
/// device's current location and reverse-geocode it.
class LocationService {
  /// Returns the device's current position as a [Location].
  ///
  /// Checks (and requests) location permissions before querying GPS.
  /// Throws [LocationServiceException] on failure.
  Future<Location> getCurrentLocation() async {
    // Check if location services are enabled
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw LocationServiceException('Location services are disabled.');
    }

    // Check / request permissions
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw LocationServiceException('Location permission denied.');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw LocationServiceException(
        'Location permission permanently denied. '
        'Please enable it in device settings.',
      );
    }

    // Get position
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.low,
        timeLimit: Duration(seconds: 10),
      ),
    );

    // Reverse geocode to get city / state
    try {
      final placemarks = await geo.placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      final place = placemarks.isNotEmpty ? placemarks.first : null;

      return Location(
        latitude: position.latitude,
        longitude: position.longitude,
        city: place?.locality ?? place?.subAdministrativeArea ?? 'Unknown',
        state: place?.administrativeArea ?? '',
      );
    } catch (_) {
      // If reverse geocoding fails, still return the coordinates.
      return Location(
        latitude: position.latitude,
        longitude: position.longitude,
        city: 'Current Location',
      );
    }
  }
}

class LocationServiceException implements Exception {
  final String message;
  LocationServiceException(this.message);

  @override
  String toString() => 'LocationServiceException: $message';
}
