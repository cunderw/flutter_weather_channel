import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/geocoding_service.dart';
import '../../services/location_service.dart';
import 'location_event.dart';
import 'location_state.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  final GeocodingService _geocodingService;
  final LocationService _locationService;

  LocationBloc({
    required GeocodingService geocodingService,
    required LocationService locationService,
  }) : _geocodingService = geocodingService,
       _locationService = locationService,
       super(const LocationInitial()) {
    on<ZipCodeSubmitted>(_onZipCodeSubmitted);
    on<DeviceLocationRequested>(_onDeviceLocationRequested);
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

  Future<void> _onDeviceLocationRequested(
    DeviceLocationRequested event,
    Emitter<LocationState> emit,
  ) async {
    emit(const LocationLoading());
    try {
      final location = await _locationService.getCurrentLocation();
      emit(LocationLoaded(location));
    } catch (e) {
      emit(LocationError(e.toString()));
    }
  }
}
