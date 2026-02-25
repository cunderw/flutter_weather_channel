import 'package:equatable/equatable.dart';

/// Represents a resolved geographic location.
class Location extends Equatable {
  final double latitude;
  final double longitude;
  final String city;
  final String state;
  final String? zip;

  const Location({
    required this.latitude,
    required this.longitude,
    required this.city,
    this.state = '',
    this.zip,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      city: json['name'] as String? ?? 'Unknown',
      state: json['admin1'] as String? ?? '',
      zip: json['zip'] as String?,
    );
  }

  @override
  List<Object?> get props => [latitude, longitude, city, state, zip];

  /// Formatted display name, e.g. "Springfield, IL".
  String get displayName {
    if (state.isNotEmpty) return '$city, $state';
    return city;
  }
}
