# Flutter Weather Channel — Copilot Instructions

## Project Overview

This is a Flutter app that recreates the nostalgic look and feel of 1990s–2000s TV Weather Channel
"Local on the 8s" broadcasts. It displays current conditions, radar imagery, and text summaries on
an auto-cycling TV-style screen with a scrolling forecast ticker at the bottom.

## Architecture

- **State Management:** BLoC / Cubit (`flutter_bloc`)
- **Weather API:** Open-Meteo (no API key required)
- **Radar Imagery:** RainViewer free API (static composite radar tiles)
- **Location:** `geolocator` + `geocoding` packages for device GPS; Open-Meteo Geocoding API for zip code lookup

## Folder Structure

```
lib/
├── main.dart                     App entry point, BlocProviders
├── app.dart                      MaterialApp, routing, theme
├── config/
│   └── theme.dart                TV Weather Channel color palette & text styles
├── models/
│   ├── weather.dart              Current conditions model
│   ├── forecast.dart             Hourly/daily forecast model
│   └── location.dart             Location (lat, lon, city, state, zip)
├── services/
│   ├── weather_service.dart      Open-Meteo API client
│   ├── location_service.dart     Geolocator wrapper
│   └── geocoding_service.dart    Zip → coordinates (Open-Meteo Geocoding)
├── blocs/
│   ├── weather/                  WeatherBloc (events + states)
│   ├── location/                 LocationBloc (events + states)
│   └── display/                  DisplayCubit (panel cycling)
├── screens/
│   ├── location_prompt_screen.dart   Zip entry + "Use My Location"
│   └── tv_weather_screen.dart        Main TV broadcast view
├── widgets/
│   ├── tv_frame.dart             CRT scanline/vignette overlay
│   ├── forecast_ticker.dart      Scrolling bottom forecast bar
│   ├── current_conditions_panel.dart
│   ├── radar_panel.dart          Static radar image display
│   ├── text_summary_panel.dart   Scrolling text summary
│   ├── weather_info_bar.dart     Top bar (city, time, date)
│   └── content_cycler.dart       Auto-cycles between content panels
└── utils/
    ├── weather_icons.dart        WMO code → description/icon mapping
    └── constants.dart            API URLs, timing, color constants
```

## Conventions

### BLoC Pattern

- Each BLoC lives in its own folder: `bloc.dart`, `event.dart`, `state.dart`
- States and events extend `Equatable`
- Use `Cubit` for simple state (e.g., DisplayCubit); use full `Bloc` for complex event-driven logic
- Emit new state objects; never mutate existing state
- Inject dependencies via constructor (e.g., `WeatherBloc({required WeatherService weatherService})`)
- Use `on<EventType>` handlers in BLoC constructors
- Always call `super.close()` when overriding `close()` for cleanup

**BLoC Example:**
```dart
class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  final WeatherService _weatherService;
  
  WeatherBloc({required WeatherService weatherService})
    : _weatherService = weatherService,
      super(const WeatherInitial()) {
    on<FetchWeather>(_onFetchWeather);
  }
  
  Future<void> _onFetchWeather(
    FetchWeather event,
    Emitter<WeatherState> emit,
  ) async {
    emit(const WeatherLoading());
    try {
      final result = await _weatherService.fetchWeather(...);
      emit(WeatherLoaded(weather: result.weather, forecast: result.forecast));
    } catch (e) {
      emit(WeatherError(e.toString()));
    }
  }
}
```

### Naming

- Files: `snake_case.dart`
- Classes: `PascalCase`
- BLoC events: past-tense verbs (`WeatherFetched`, `ZipCodeSubmitted`)
- BLoC states: adjectives/nouns (`WeatherLoading`, `WeatherLoaded`)
- Private fields: prefix with underscore (`_weatherService`, `_client`)
- Constants: use descriptive class names (e.g., `ApiConstants`, `TimingConstants`)

### Models

- All models are immutable (final fields)
- Extend `Equatable` and override `props`
- Include `factory fromJson(Map<String, dynamic> json)` constructors
- Use WMO weather interpretation codes (integers) mapped locally to descriptions
- Use `const` constructors when possible
- Include computed properties for derived values (e.g., `displayName`)

**Model Example:**
```dart
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
    );
  }
  
  @override
  List<Object?> get props => [latitude, longitude, city, state, zip];
  
  String get displayName {
    if (state.isNotEmpty) return '$city, $state';
    return city;
  }
}
```

### Services

- All services accept an optional `http.Client` for testing
- Services throw custom exceptions (e.g., `WeatherException`, `GeocodingException`)
- Use descriptive method names (`fetchWeather`, `search`)
- Use named parameters for clarity
- Keep services stateless; store no data between calls
- Use records for multiple return values: `({Weather weather, Forecast forecast})`

**Service Example:**
```dart
class WeatherService {
  final http.Client _client;
  
  WeatherService({http.Client? client}) : _client = client ?? http.Client();
  
  Future<({Weather weather, Forecast forecast})> fetchWeather({
    required double lat,
    required double lon,
  }) async {
    final uri = Uri.parse('${ApiConstants.openMeteoForecastUrl}?latitude=$lat&longitude=$lon...');
    final response = await _client.get(uri);
    
    if (response.statusCode != 200) {
      throw WeatherException('API returned status ${response.statusCode}');
    }
    
    final data = json.decode(response.body) as Map<String, dynamic>;
    return (weather: Weather.fromJson(data), forecast: Forecast.fromJson(data));
  }
}

class WeatherException implements Exception {
  final String message;
  WeatherException(this.message);
  
  @override
  String toString() => 'WeatherException: $message';
}
```

### Widgets

- All custom widgets are `StatelessWidget` unless animation/state is needed
- Use `const` constructors whenever possible
- Extract reusable UI into private methods (prefix with `_build`)
- Use theme colors from `WeatherColors` class
- Use text styles from `WeatherTextStyles` class
- Pass required data via constructor parameters, not global state
- Use descriptive widget names that indicate purpose

**Widget Example:**
```dart
class CurrentConditionsPanel extends StatelessWidget {
  final Weather weather;
  
  const CurrentConditionsPanel({super.key, required this.weather});
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${weather.temperature.round()}°F',
            style: WeatherTextStyles.led(size: 72),
          ),
          _buildDataGrid(),
        ],
      ),
    );
  }
  
  Widget _buildDataGrid() { /* ... */ }
}
```

### Theming

- Dark navy gradient backgrounds (`Color(0xFF0A1931)` → `Color(0xFF1A3A5C)`)
- Yellow (`Color(0xFFFFD700)`) for temperatures
- Cyan (`Color(0xFF00E5FF)`) for location names
- White (`Color(0xFFFFFFFF)`) for general text
- Gray (`Color(0xFFBBBBBB)`) for secondary text
- Google Fonts: "VT323" for LED/pixel readouts, "Roboto Condensed" for body
- Semi-transparent dark overlays for info bars (`Color(0xCC0A1931)`)
- Blue band (`Color(0xFF003399)`) at bottom for forecast ticker
- Use `WeatherColors` constants instead of hardcoded colors
- Use `WeatherTextStyles` methods for consistent typography

### APIs

- **Open-Meteo Forecast:** `https://api.open-meteo.com/v1/forecast?latitude={lat}&longitude={lon}&current=...&hourly=...&daily=...&temperature_unit=fahrenheit&wind_speed_unit=mph&timezone=auto`
- **Open-Meteo Geocoding:** `https://geocoding-api.open-meteo.com/v1/search?name={query}&count=1&language=en&format=json`
- **RainViewer Radar:** `https://api.rainviewer.com/public/weather-maps.json` → use latest composite radar tile URL
- No API keys are needed for any of these services
- All API URLs stored in `ApiConstants` class

### Testing

- Unit tests for services (mock HTTP with `mocktail`)
- BLoC tests with `bloc_test` package
- Widget tests for individual panels
- Test files mirror `lib/` structure under `test/`
- Use descriptive test names with `group` and `test` blocks
- Mock external dependencies (HTTP client, services)
- Test both success and error cases

### Constants

- Store all constants in dedicated classes under `lib/utils/constants.dart`
- Use descriptive class names: `ApiConstants`, `TimingConstants`
- Make classes private with private constructor: `ClassName._();`
- Use `static const` for all constant values
- Group related constants together

**Constants Example:**
```dart
class TimingConstants {
  TimingConstants._();
  
  static const Duration panelCycleDuration = Duration(seconds: 8);
  static const Duration panelFadeDuration = Duration(milliseconds: 800);
  static const Duration weatherRefreshInterval = Duration(minutes: 10);
}
```

### Error Handling

- Create custom exception classes for each service
- Include descriptive error messages
- Catch exceptions in BLoC event handlers
- Emit error states with user-friendly messages
- Log errors for debugging but don't expose implementation details

### Dependency Injection

- Use `RepositoryProvider` for services
- Use `BlocProvider` for BLoCs and Cubits
- Inject dependencies via constructor parameters
- Use `context.read<T>()` to access providers in build methods
- Keep dependency tree shallow and clear

### Panel Cycling

- Main content auto-cycles every ~8 seconds between 3 panels:
  1. Current Conditions (temp, humidity, wind, pressure, etc.)
  2. Radar (static composite image centered on location)
  3. Text Summary (narrative description of current + forecast conditions)
- Uses `AnimatedSwitcher` with fade transitions
- Managed by `DisplayCubit` with timer-based cycling
- Each panel is a separate stateless widget

### Ticker

- Bottom forecast ticker scrolls continuously left-to-right
- Shows hourly forecasts: time, temp, weather icon
- Blue background band with white/yellow text
- Implemented as animated widget with continuous scroll

### Code Quality

- Follow Flutter/Dart style guide
- Use `flutter analyze` for linting
- Keep methods small and focused
- Avoid deep nesting; extract complex logic
- Use meaningful variable names
- Add doc comments for public APIs
- Keep files under 300 lines when possible

### Import Order

Organize imports in this specific order, with blank lines separating each group:

1. Dart SDK imports (e.g., `dart:async`, `dart:convert`)
2. Flutter imports (e.g., `package:flutter/material.dart`)
3. Package imports - alphabetical (e.g., `package:equatable/equatable.dart`)
4. Relative imports - alphabetical (e.g., `../config/theme.dart`)

Within each group, imports are consecutive (no blank lines between them).

**Example:**
```dart
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../config/theme.dart';
import '../models/weather.dart';
import '../utils/constants.dart';
```

### Build & Test Commands

**Setup:**
```bash
flutter pub get                    # Install dependencies
```

**Code Quality:**
```bash
flutter analyze                    # Run static analysis (must pass)
dart format lib/ test/             # Format code before committing
```

**Testing:**
```bash
flutter test                       # Run all tests
flutter test path/to/test.dart     # Run specific test file
```

**Running:**
```bash
flutter run                        # Run on connected device/emulator
```

### Git Commit Format

Use conventional commit format:

```
type: short description

Optional longer explanation. Wrap at 72 characters.
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation only
- `style`: Formatting changes
- `refactor`: Code restructure without behavior change
- `test`: Adding/updating tests
- `chore`: Maintenance (dependencies, build, etc.)
