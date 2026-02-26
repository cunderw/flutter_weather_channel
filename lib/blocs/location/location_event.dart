import 'package:equatable/equatable.dart';

abstract class LocationEvent extends Equatable {
  const LocationEvent();

  @override
  List<Object?> get props => [];
}

/// User submitted a zip code or city name.
class ZipCodeSubmitted extends LocationEvent {
  final String query;
  const ZipCodeSubmitted(this.query);

  @override
  List<Object?> get props => [query];
}
