# Flutter Weather Channel — Coding Conventions

This document outlines the coding standards, patterns, and best practices for the Flutter Weather Channel project.

## Table of Contents

1. [File Organization](#file-organization)
2. [Naming Conventions](#naming-conventions)
3. [Code Style](#code-style)
4. [BLoC Pattern](#bloc-pattern)
5. [Models](#models)
6. [Services](#services)
7. [Widgets](#widgets)
8. [Theme & Styling](#theme--styling)
9. [Error Handling](#error-handling)
10. [Testing](#testing)
11. [Documentation](#documentation)
12. [Import Order](#import-order)

---

## File Organization

### Directory Structure

All source code lives under `lib/` with the following structure:

```
lib/
├── main.dart                 # App entry point only, minimal code
├── app.dart                  # MaterialApp configuration, routing, providers
├── blocs/                    # State management
│   └── feature_name/         # One folder per BLoC
│       ├── feature_name_bloc.dart
│       ├── feature_name_event.dart
│       └── feature_name_state.dart
├── config/                   # App-wide configuration
│   └── theme.dart            # Colors, text styles, themes
├── models/                   # Data models
│   └── model_name.dart       # One file per model
├── screens/                  # Full-screen views
│   └── screen_name.dart      # One file per screen
├── services/                 # Business logic, API clients
│   └── service_name.dart     # One file per service
├── utils/                    # Utilities and helpers
│   ├── constants.dart        # App-wide constants
│   └── helper_name.dart      # Utility functions/classes
└── widgets/                  # Reusable UI components
    └── widget_name.dart      # One file per widget
```

### Test Structure

Tests mirror the `lib/` structure under `test/`:

```
test/
├── blocs/
│   └── feature_name/
│       └── feature_name_bloc_test.dart
├── models/
│   └── model_name_test.dart
├── services/
│   └── service_name_test.dart
└── widgets/
    └── widget_name_test.dart
```

### File Naming Rules

- **All files**: `snake_case.dart`
- **No abbreviations** unless widely understood (e.g., `api`, `url`)
- **Be descriptive**: `location_prompt_screen.dart` not `prompt.dart`

---

## Naming Conventions

### Classes

- **Format**: `PascalCase`
- **Examples**: `WeatherBloc`, `LocationService`, `CurrentConditionsPanel`
- **BLoCs**: Suffix with `Bloc` or `Cubit` (e.g., `WeatherBloc`, `DisplayCubit`)
- **Events**: Past-tense verbs (e.g., `WeatherFetched`, `ZipCodeSubmitted`)
- **States**: Adjectives/nouns (e.g., `WeatherLoading`, `WeatherLoaded`)
- **Exceptions**: Suffix with `Exception` (e.g., `WeatherException`)

### Variables & Parameters

- **Format**: `camelCase`
- **Private fields**: Prefix with `_` (e.g., `_weatherService`, `_client`)
- **Boolean fields**: Start with `is`/`has`/`can` (e.g., `isLoading`, `hasError`)
- **Be descriptive**: `weatherData` not `data`, `userLocation` not `loc`

### Constants

- **Format**: `camelCase` for static const
- **Group in classes**: `ApiConstants`, `TimingConstants`, `LayoutConstants`
- **All caps** only for compile-time constants at top level (rare)

```dart
// ✅ Good
class ApiConstants {
  static const String openMeteoForecastUrl = 'https://...';
}

// ❌ Bad
const OPEN_METEO_URL = 'https://...';
```

### Functions & Methods

- **Format**: `camelCase`
- **Action verbs**: `fetchWeather`, `buildDataGrid`, `onSubmit`
- **Boolean getters**: Start with `is`/`has`/`can` (e.g., `isValid`, `hasData`)
- **Private methods**: Prefix with `_` (e.g., `_buildHeader`, `_handleError`)

---

## Code Style

### Line Length

- **Maximum**: 80 characters preferred, 100 acceptable
- **Break long lines** using Dart's cascade operator or method chaining

```dart
// ✅ Good
final uri = Uri.parse(
  '${ApiConstants.openMeteoForecastUrl}'
  '?latitude=$lat&longitude=$lon'
  '&current=${ApiConstants.currentFields}',
);

// ❌ Bad
final uri = Uri.parse('${ApiConstants.openMeteoForecastUrl}?latitude=$lat&longitude=$lon&current=${ApiConstants.currentFields}');
```

### Indentation

- **2 spaces** (Flutter default)
- **No tabs**

### Braces

- **Always use braces** for control flow, even single lines

```dart
// ✅ Good
if (condition) {
  doSomething();
}

// ❌ Bad
if (condition) doSomething();
```

### Trailing Commas

- **Always use** trailing commas for multi-line parameter/argument lists
- **Benefits**: Better diffs, auto-formatting

```dart
// ✅ Good
const Location(
  latitude: 39.78,
  longitude: -89.65,
  city: 'Springfield',
);

// ❌ Bad
const Location(
  latitude: 39.78,
  longitude: -89.65,
  city: 'Springfield'
);
```

### Const Constructors

- **Use `const`** whenever possible for immutable widgets/objects
- **Required for**: All stateless widgets, models, configuration objects

```dart
// ✅ Good
const CurrentConditionsPanel({super.key, required this.weather});

// ❌ Bad
CurrentConditionsPanel({super.key, required this.weather});
```

### Null Safety

- **Prefer non-nullable** types by default
- **Use `?`** only when null is a valid value
- **Use `!`** sparingly; prefer `??` operator or null checks

```dart
// ✅ Good
final String city;
final String? zip;  // null is valid
final value = optionalValue ?? defaultValue;

// ❌ Bad
final city = optionalCity!;  // Unsafe
```

---

## BLoC Pattern

### Structure

Each BLoC lives in its own folder with three files:

1. `feature_name_bloc.dart` - BLoC implementation
2. `feature_name_event.dart` - Event definitions
3. `feature_name_state.dart` - State definitions

### BLoC vs Cubit

**Use Cubit when:**
- Simple state transitions
- No need for event tracking
- Straightforward setter-like operations

**Use BLoC when:**
- Complex event-driven logic
- Need event history/debugging
- Multiple events affect same state

### Events

```dart
abstract class WeatherEvent extends Equatable {
  const WeatherEvent();
  
  @override
  List<Object?> get props => [];
}

// Use past-tense verbs
class FetchWeather extends WeatherEvent {
  final double latitude;
  final double longitude;
  
  const FetchWeather({required this.latitude, required this.longitude});
  
  @override
  List<Object?> get props => [latitude, longitude];
}
```

**Rules:**
- Extend `Equatable`
- Override `props` for all fields
- Use past-tense verbs (actions that happened)
- Immutable (all fields `final`)
- Use named parameters

### States

```dart
abstract class WeatherState extends Equatable {
  const WeatherState();
  
  @override
  List<Object?> get props => [];
}

class WeatherInitial extends WeatherState {
  const WeatherInitial();
}

class WeatherLoading extends WeatherState {
  const WeatherLoading();
}

class WeatherLoaded extends WeatherState {
  final Weather weather;
  final Forecast forecast;
  
  const WeatherLoaded({required this.weather, required this.forecast});
  
  @override
  List<Object?> get props => [weather, forecast];
}

class WeatherError extends WeatherState {
  final String message;
  
  const WeatherError(this.message);
  
  @override
  List<Object?> get props => [message];
}
```

**Rules:**
- Extend `Equatable`
- Override `props` for all fields
- Use adjectives/nouns (state descriptions)
- Always have: Initial, Loading, Loaded, Error states
- Immutable (all fields `final`)
- Use named parameters

### BLoC Implementation

```dart
class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  final WeatherService _weatherService;
  Timer? _refreshTimer;
  
  WeatherBloc({required WeatherService weatherService})
    : _weatherService = weatherService,
      super(const WeatherInitial()) {
    on<FetchWeather>(_onFetchWeather);
    on<RefreshWeather>(_onRefreshWeather);
  }
  
  Future<void> _onFetchWeather(
    FetchWeather event,
    Emitter<WeatherState> emit,
  ) async {
    emit(const WeatherLoading());
    try {
      final result = await _weatherService.fetchWeather(
        lat: event.latitude,
        lon: event.longitude,
      );
      emit(WeatherLoaded(weather: result.weather, forecast: result.forecast));
    } catch (e) {
      emit(WeatherError(e.toString()));
    }
  }
  
  @override
  Future<void> close() {
    _refreshTimer?.cancel();
    return super.close();
  }
}
```

**Rules:**
- Inject dependencies via constructor
- Store dependencies in private fields
- Use `on<EventType>` to register handlers
- Always emit Loading state before async operations
- Catch exceptions and emit Error state
- Never mutate state; always emit new state
- Override `close()` if managing resources (timers, streams, etc.)
- Always call `super.close()` when overriding

---

## Models

### Structure

```dart
import 'package:equatable/equatable.dart';

class Weather extends Equatable {
  final double temperature;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  
  const Weather({
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
  });
  
  factory Weather.fromJson(Map<String, dynamic> json) {
    final current = json['current'] as Map<String, dynamic>;
    return Weather(
      temperature: (current['temperature_2m'] as num).toDouble(),
      feelsLike: (current['apparent_temperature'] as num).toDouble(),
      humidity: (current['relative_humidity_2m'] as num).toInt(),
      windSpeed: (current['wind_speed_10m'] as num).toDouble(),
    );
  }
  
  @override
  List<Object?> get props => [temperature, feelsLike, humidity, windSpeed];
  
  String get displayTemperature => '${temperature.round()}°F';
}
```

**Rules:**
- Extend `Equatable`
- All fields `final` (immutable)
- Use `const` constructor
- Include `factory fromJson` for API models
- Override `props` with all fields
- Use computed properties for derived values
- Type conversions in `fromJson` (e.g., `as num` then `.toDouble()`)
- Null-safe defaults in `fromJson` (e.g., `?? 'Unknown'`)

### JSON Parsing

```dart
// ✅ Good - Safe type casting
temperature: (json['temperature'] as num).toDouble(),
city: json['name'] as String? ?? 'Unknown',

// ❌ Bad - Unsafe casting
temperature: json['temperature'] as double,  // Fails if int
city: json['name'] as String,  // Fails if null
```

---

## Services

### Structure

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/result_model.dart';
import '../utils/constants.dart';

class WeatherService {
  final http.Client _client;
  
  WeatherService({http.Client? client}) : _client = client ?? http.Client();
  
  Future<({Weather weather, Forecast forecast})> fetchWeather({
    required double lat,
    required double lon,
  }) async {
    final uri = Uri.parse(
      '${ApiConstants.openMeteoForecastUrl}'
      '?latitude=$lat&longitude=$lon'
      '&current=${ApiConstants.currentFields}',
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
}

class WeatherException implements Exception {
  final String message;
  WeatherException(this.message);
  
  @override
  String toString() => 'WeatherException: $message';
}
```

**Rules:**
- Accept optional HTTP client for testing
- Store client in private field
- Use named parameters for all methods
- Throw custom exceptions (never return null for errors)
- Include descriptive error messages
- Keep services stateless
- Use records for multiple return values: `({Type1 name1, Type2 name2})`
- One responsibility per service

### Custom Exceptions

```dart
class ServiceNameException implements Exception {
  final String message;
  ServiceNameException(this.message);
  
  @override
  String toString() => 'ServiceNameException: $message';
}
```

**Rules:**
- Implement `Exception`
- Include descriptive message
- Override `toString()`
- Name with `Exception` suffix

---

## Widgets

### Structure

```dart
import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/weather.dart';

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
          const SizedBox(height: 16),
          _buildDataGrid(),
        ],
      ),
    );
  }
  
  Widget _buildDataGrid() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildDataItem('Humidity', '${weather.humidity}%'),
        _buildDataItem('Wind', '${weather.windSpeed.round()} mph'),
      ],
    );
  }
  
  Widget _buildDataItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: WeatherTextStyles.label()),
        Text(value, style: WeatherTextStyles.body()),
      ],
    );
  }
}
```

**Rules:**
- Prefer `StatelessWidget` unless state is needed
- Use `const` constructor with `super.key`
- Pass data via constructor, not global state
- Extract complex UI into private `_build*` methods
- Use theme colors/styles from `WeatherColors` and `WeatherTextStyles`
- Use `const` for child widgets when possible
- Keep `build()` method readable; extract complex trees

### StatelessWidget vs StatefulWidget

**Use StatelessWidget when:**
- Widget doesn't manage its own state
- Data comes from constructor parameters
- Widget is purely presentational

**Use StatefulWidget when:**
- Need to manage local UI state (e.g., animation controllers)
- Need lifecycle methods (initState, dispose)
- Widget has mutable internal state

---

## Theme & Styling

### Colors

All colors defined in `lib/config/theme.dart`:

```dart
class WeatherColors {
  WeatherColors._();  // Private constructor
  
  static const Color backgroundDark = Color(0xFF0A1931);
  static const Color textYellow = Color(0xFFFFD700);
  
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [backgroundDark, backgroundLight],
  );
}
```

**Rules:**
- Never hardcode colors in widgets
- Use `WeatherColors` constants
- Hex format: `Color(0xFFRRGGBB)`
- Group related colors
- Private constructor: `ClassName._();`

### Text Styles

All text styles defined in `lib/config/theme.dart`:

```dart
class WeatherTextStyles {
  WeatherTextStyles._();
  
  static TextStyle led({
    double size = 48,
    Color color = WeatherColors.textYellow,
  }) {
    return GoogleFonts.vt323(
      fontSize: size,
      color: color,
      letterSpacing: 2,
      shadows: [
        Shadow(color: color.withValues(alpha: 0.5), blurRadius: 6),
      ],
    );
  }
}
```

**Rules:**
- Never hardcode text styles in widgets
- Use `WeatherTextStyles` methods
- Use named parameters for customization
- Provide sensible defaults
- Use Google Fonts for consistency

---

## Error Handling

### In Services

```dart
Future<Result> doSomething() async {
  try {
    final response = await _client.get(uri);
    
    if (response.statusCode != 200) {
      throw ServiceException('API error: ${response.statusCode}');
    }
    
    return Result.fromJson(json.decode(response.body));
  } catch (e) {
    throw ServiceException('Failed to fetch data: $e');
  }
}
```

**Rules:**
- Throw custom exceptions, never return null
- Include descriptive error messages
- Include context (what operation failed)
- Don't expose implementation details

### In BLoCs

```dart
Future<void> _onEvent(Event event, Emitter<State> emit) async {
  emit(const Loading());
  try {
    final result = await _service.doSomething();
    emit(Loaded(result));
  } catch (e) {
    emit(Error(e.toString()));
  }
}
```

**Rules:**
- Catch all exceptions
- Emit error state with message
- Log errors for debugging
- Never let exceptions escape BLoC

### In Widgets

```dart
BlocBuilder<WeatherBloc, WeatherState>(
  builder: (context, state) {
    if (state is WeatherError) {
      return Center(
        child: Text(
          'Error: ${state.message}',
          style: WeatherTextStyles.body(color: WeatherColors.textRed),
        ),
      );
    }
    // ... other states
  },
)
```

**Rules:**
- Display user-friendly error messages
- Use error state from BLoC
- Provide retry mechanism when appropriate

---

## Testing

### Unit Tests (Services)

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:http/http.dart' as http;

class MockClient extends Mock implements http.Client {}

void main() {
  group('WeatherService', () {
    late WeatherService service;
    late MockClient mockClient;
    
    setUp(() {
      mockClient = MockClient();
      service = WeatherService(client: mockClient);
    });
    
    test('fetchWeather returns data on success', () async {
      when(() => mockClient.get(any())).thenAnswer(
        (_) async => http.Response('{"temperature": 72}', 200),
      );
      
      final result = await service.fetchWeather(lat: 40, lon: -89);
      
      expect(result.weather.temperature, 72);
    });
    
    test('fetchWeather throws on error', () {
      when(() => mockClient.get(any())).thenAnswer(
        (_) async => http.Response('Error', 500),
      );
      
      expect(
        () => service.fetchWeather(lat: 40, lon: -89),
        throwsA(isA<WeatherException>()),
      );
    });
  });
}
```

### BLoC Tests

```dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockWeatherService extends Mock implements WeatherService {}

void main() {
  group('WeatherBloc', () {
    late WeatherService mockService;
    late WeatherBloc bloc;
    
    setUp(() {
      mockService = MockWeatherService();
      bloc = WeatherBloc(weatherService: mockService);
    });
    
    tearDown(() {
      bloc.close();
    });
    
    test('initial state is WeatherInitial', () {
      expect(bloc.state, equals(const WeatherInitial()));
    });
    
    blocTest<WeatherBloc, WeatherState>(
      'emits [Loading, Loaded] on success',
      build: () {
        when(() => mockService.fetchWeather(lat: any(named: 'lat'), lon: any(named: 'lon')))
          .thenAnswer((_) async => (weather: mockWeather, forecast: mockForecast));
        return bloc;
      },
      act: (bloc) => bloc.add(const FetchWeather(latitude: 40, longitude: -89)),
      expect: () => [
        const WeatherLoading(),
        isA<WeatherLoaded>(),
      ],
    );
  });
}
```

**Rules:**
- Use `mocktail` for mocking
- Use `bloc_test` for BLoC testing
- Test both success and error paths
- Use descriptive test names
- Group related tests
- Clean up resources in `tearDown`

---

## Documentation

### Doc Comments

Use `///` for public APIs:

```dart
/// Fetches current weather conditions and forecast for [lat], [lon].
/// 
/// Returns a record containing both [Weather] and [Forecast] data.
/// Throws [WeatherException] if the API request fails.
Future<({Weather weather, Forecast forecast})> fetchWeather({
  required double lat,
  required double lon,
}) async {
  // ...
}
```

**Rules:**
- Document all public classes, methods, and fields
- Use `///` not `//` for documentation
- Reference parameters with `[paramName]`
- Document exceptions
- Keep docs concise but complete
- Use present tense

### Inline Comments

```dart
// Calculate tile coordinates for radar image
final x = ((lon + 180) / 360 * (1 << zoom)).floor();

// Use the most recent radar frame
final latestFrame = past.last as Map<String, dynamic>;
```

**Rules:**
- Use `//` for inline comments
- Explain *why*, not *what*
- Keep comments short
- Don't state the obvious
- Update comments when code changes

---

## Import Order

```dart
// 1. Dart SDK imports
import 'dart:async';
import 'dart:convert';

// 2. Flutter imports
import 'package:flutter/material.dart';

// 3. Package imports (alphabetical)
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

// 4. Relative imports (alphabetical)
import '../config/theme.dart';
import '../models/weather.dart';
import '../utils/constants.dart';
```

**Rules:**
- Group imports as shown above
- Sort alphabetically within each group
- Use relative imports for project files
- Separate groups with blank lines
- Run `dart format` to auto-sort

---

## Formatting

### Auto-formatting

Always run before committing:

```bash
dart format lib/ test/
```

### Analyzer

Fix all analyzer warnings:

```bash
flutter analyze
```

### Lint Rules

Configured in `analysis_options.yaml`:

```yaml
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    # Enabled by default via flutter_lints
```

---

## Git Commit Messages

### Format

```
type: short description

Longer explanation if needed. Wrap at 72 characters.

- Bullet points for multiple changes
- Each starting with a dash
```

### Types

- `feat`: New feature
- `fix`: Bug fix
- `refactor`: Code restructure without behavior change
- `style`: Formatting, missing semicolons, etc.
- `test`: Adding/updating tests
- `docs`: Documentation only
- `chore`: Maintenance (dependencies, build, etc.)

### Examples

```
feat: add radar panel with RainViewer integration

- Implement RadarPanel widget
- Add radar URL fetching to WeatherService
- Integrate radar into content cycler
```

```
fix: handle null state in geocoding response

Geocoding API can return null for admin1 field, causing
crashes. Now defaults to empty string.
```

---

## Code Review Checklist

Before submitting code:

- [ ] All tests pass
- [ ] No analyzer warnings
- [ ] Code is formatted (`dart format`)
- [ ] New code has tests
- [ ] Public APIs have doc comments
- [ ] Constants extracted (no magic numbers/strings)
- [ ] Theme colors/styles used (no hardcoded values)
- [ ] Error cases handled
- [ ] BLoC states extend Equatable with props
- [ ] Models are immutable
- [ ] Services are stateless
- [ ] No commented-out code
- [ ] Git commit message follows format

---

## Resources

- [Effective Dart](https://dart.dev/guides/language/effective-dart)
- [Flutter Style Guide](https://github.com/flutter/flutter/wiki/Style-guide-for-Flutter-repo)
- [BLoC Library Documentation](https://bloclibrary.dev/)
- [Equatable Package](https://pub.dev/packages/equatable)
- [Open-Meteo API Docs](https://open-meteo.com/en/docs)
