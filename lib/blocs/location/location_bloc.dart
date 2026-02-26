import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/geocoding_service.dart';
import 'location_event.dart';
import 'location_state.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  final GeocodingService _geocodingService;

  LocationBloc({required GeocodingService geocodingService})
    : _geocodingService = geocodingService,
      super(const LocationInitial()) {
    on<ZipCodeSubmitted>(_onZipCodeSubmitted);
  }

  Future<void> _onZipCodeSubmitted(
    ZipCodeSubmitted event,
    Emitter<LocationState> emit,
  ) async {
    emit(const LocationLoading());
    try {
      final location = await _geocodingService.search(event.query);
      emit(LocationLoaded(location));
    } catch (e) {
      emit(LocationError(e.toString()));
    }
  }
}
