# Flutter Weather Channel — Development Skills

This document outlines common development tasks and how to accomplish them in this codebase.

## Table of Contents

1. [Adding a New BLoC](#adding-a-new-bloc)
2. [Adding a New Model](#adding-a-new-model)
3. [Adding a New Service](#adding-a-new-service)
4. [Adding a New Widget/Panel](#adding-a-new-widgetpanel)
5. [Adding a New Weather Data Field](#adding-a-new-weather-data-field)
6. [Adding a New Screen](#adding-a-new-screen)
7. [Testing a BLoC](#testing-a-bloc)
8. [Testing a Service](#testing-a-service)
9. [Adding New Constants](#adding-new-constants)
10. [Modifying Theme Colors/Styles](#modifying-theme-colorsstyles)

---

## Adding a New BLoC

### When to Use
- Complex state management with multiple events
- Need for event-driven logic
- Async operations with loading/success/error states

### Steps

1. **Create folder structure:**
   ```
   lib/blocs/feature_name/
   ├── feature_name_bloc.dart
   ├── feature_name_event.dart
   └── feature_name_state.dart
   ```

2. **Define events** (`feature_name_event.dart`):
   ```dart
   import 'package:equatable/equatable.dart';
   
   abstract class FeatureNameEvent extends Equatable {
     const FeatureNameEvent();
     
     @override
     List<Object?> get props => [];
   }
   
   class SomeActionRequested extends FeatureNameEvent {
     final String parameter;
     
     const SomeActionRequested({required this.parameter});
     
     @override
     List<Object?> get props => [parameter];
   }
   ```

3. **Define states** (`feature_name_state.dart`):
   ```dart
   import 'package:equatable/equatable.dart';
   
   abstract class FeatureNameState extends Equatable {
     const FeatureNameState();
     
     @override
     List<Object?> get props => [];
   }
   
   class FeatureNameInitial extends FeatureNameState {
     const FeatureNameInitial();
   }
   
   class FeatureNameLoading extends FeatureNameState {
     const FeatureNameLoading();
   }
   
   class FeatureNameLoaded extends FeatureNameState {
     final DataModel data;
     
     const FeatureNameLoaded(this.data);
     
     @override
     List<Object?> get props => [data];
   }
   
   class FeatureNameError extends FeatureNameState {
     final String message;
     
     const FeatureNameError(this.message);
     
     @override
     List<Object?> get props => [message];
   }
   ```

4. **Implement BLoC** (`feature_name_bloc.dart`):
   ```dart
   import 'package:flutter_bloc/flutter_bloc.dart';
   import '../../services/some_service.dart';
   import 'feature_name_event.dart';
   import 'feature_name_state.dart';
   
   class FeatureNameBloc extends Bloc<FeatureNameEvent, FeatureNameState> {
     final SomeService _service;
     
     FeatureNameBloc({required SomeService service})
       : _service = service,
         super(const FeatureNameInitial()) {
       on<SomeActionRequested>(_onSomeActionRequested);
     }
     
     Future<void> _onSomeActionRequested(
       SomeActionRequested event,
       Emitter<FeatureNameState> emit,
     ) async {
       emit(const FeatureNameLoading());
       try {
         final result = await _service.doSomething(event.parameter);
         emit(FeatureNameLoaded(result));
       } catch (e) {
         emit(FeatureNameError(e.toString()));
       }
     }
   }
   ```

5. **Register in app.dart:**
   ```dart
   BlocProvider(
     create: (ctx) => FeatureNameBloc(
       service: ctx.read<SomeService>(),
     ),
   ),
   ```

---

## Adding a New Model

### When to Use
- Representing data structures from APIs
- Domain models for business logic
- UI state models

### Steps

1. **Create model file** (`lib/models/model_name.dart`):
   ```dart
   import 'package:equatable/equatable.dart';
   
   class ModelName extends Equatable {
     final String field1;
     final int field2;
     final double? optionalField;
     
     const ModelName({
       required this.field1,
       required this.field2,
       this.optionalField,
     });
     
     factory ModelName.fromJson(Map<String, dynamic> json) {
       return ModelName(
         field1: json['field_1'] as String,
         field2: (json['field_2'] as num).toInt(),
         optionalField: (json['optional_field'] as num?)?.toDouble(),
       );
     }
     
     @override
     List<Object?> get props => [field1, field2, optionalField];
     
     // Add computed properties if needed
     String get displayValue => '$field1 ($field2)';
   }
   ```

2. **Add tests** (`test/models/model_name_test.dart`):
   ```dart
   import 'package:flutter_test/flutter_test.dart';
   import 'package:flutter_weather_channel/models/model_name.dart';
   
   void main() {
     group('ModelName', () {
       test('fromJson parses correctly', () {
         final json = {
           'field_1': 'value',
           'field_2': 42,
         };
         final model = ModelName.fromJson(json);
         expect(model.field1, 'value');
         expect(model.field2, 42);
       });
     });
   }
   ```

---

## Adding a New Service

### When to Use
- Making API calls
- External integrations
- Business logic that doesn't belong in BLoCs
- Reusable operations

### Steps

1. **Create service file** (`lib/services/service_name.dart`):
   ```dart
   import 'dart:convert';
   import 'package:http/http.dart' as http;
   import '../models/result_model.dart';
   import '../utils/constants.dart';
   
   class ServiceName {
     final http.Client _client;
     
     ServiceName({http.Client? client}) : _client = client ?? http.Client();
     
     Future<ResultModel> fetchData({required String parameter}) async {
       final uri = Uri.parse(
         '${ApiConstants.someApiUrl}?param=$parameter',
       );
       
       final response = await _client.get(uri);
       
       if (response.statusCode != 200) {
         throw ServiceNameException('API returned status ${response.statusCode}');
       }
       
       final data = json.decode(response.body) as Map<String, dynamic>;
       return ResultModel.fromJson(data);
     }
   }
   
   class ServiceNameException implements Exception {
     final String message;
     ServiceNameException(this.message);
     
     @override
     String toString() => 'ServiceNameException: $message';
   }
   ```

2. **Register in app.dart:**
   ```dart
   RepositoryProvider(create: (_) => ServiceName()),
   ```

3. **Add tests** (`test/services/service_name_test.dart`):
   ```dart
   import 'package:flutter_test/flutter_test.dart';
   import 'package:mocktail/mocktail.dart';
   import 'package:http/http.dart' as http;
   import 'package:flutter_weather_channel/services/service_name.dart';
   
   class MockClient extends Mock implements http.Client {}
   
   void main() {
     group('ServiceName', () {
       late ServiceName service;
       late MockClient mockClient;
       
       setUp(() {
         mockClient = MockClient();
         service = ServiceName(client: mockClient);
       });
       
       test('fetchData returns result on success', () async {
         // Mock response
         when(() => mockClient.get(any())).thenAnswer(
           (_) async => http.Response('{"field": "value"}', 200),
         );
         
         final result = await service.fetchData(parameter: 'test');
         expect(result, isA<ResultModel>());
       });
       
       test('fetchData throws on error', () {
         when(() => mockClient.get(any())).thenAnswer(
           (_) async => http.Response('Error', 500),
         );
         
         expect(
           () => service.fetchData(parameter: 'test'),
           throwsA(isA<ServiceNameException>()),
         );
       });
     });
   }
   ```

---

## Adding a New Widget/Panel

### When to Use
- Reusable UI components
- New content panels for cycling
- Custom widgets for specific features

### Steps

1. **Create widget file** (`lib/widgets/widget_name.dart`):
   ```dart
   import 'package:flutter/material.dart';
   import '../config/theme.dart';
   import '../models/data_model.dart';
   
   class WidgetName extends StatelessWidget {
     final DataModel data;
     
     const WidgetName({super.key, required this.data});
     
     @override
     Widget build(BuildContext context) {
       return Container(
         padding: const EdgeInsets.all(16),
         child: Column(
           children: [
             Text(
               data.title,
               style: WeatherTextStyles.led(size: 32),
             ),
             _buildContent(),
           ],
         ),
       );
     }
     
     Widget _buildContent() {
       return Text(
         data.content,
         style: WeatherTextStyles.body(
           size: 16,
           color: WeatherColors.textWhite,
         ),
       );
     }
   }
   ```

2. **If adding to panel cycle**, update `ActivePanel` enum in `lib/blocs/display/display_state.dart`:
   ```dart
   enum ActivePanel { currentConditions, radar, textSummary, newPanel }
   ```

3. **Update content cycler** in `lib/widgets/content_cycler.dart`:
   ```dart
   Widget _panelForState(ActivePanel panel) {
     switch (panel) {
       case ActivePanel.currentConditions:
         return CurrentConditionsPanel(...);
       case ActivePanel.radar:
         return RadarPanel(...);
       case ActivePanel.textSummary:
         return TextSummaryPanel(...);
       case ActivePanel.newPanel:
         return NewPanel(...);
     }
   }
   ```

---

## Adding a New Weather Data Field

### When to Use
- Open-Meteo API has new fields you want to display
- Adding computed/derived weather metrics

### Steps

1. **Update constants** (`lib/utils/constants.dart`):
   ```dart
   static const String currentFields =
       'temperature_2m,relative_humidity_2m,apparent_temperature,'
       'weather_code,wind_speed_10m,wind_direction_10m,'
       'surface_pressure,uv_index,visibility,new_field_name';
   ```

2. **Update Weather model** (`lib/models/weather.dart`):
   ```dart
   class Weather extends Equatable {
     // ... existing fields
     final double newField;
     
     const Weather({
       // ... existing parameters
       required this.newField,
     });
     
     factory Weather.fromJson(Map<String, dynamic> json) {
       final current = json['current'] as Map<String, dynamic>;
       return Weather(
         // ... existing fields
         newField: (current['new_field_name'] as num).toDouble(),
       );
     }
     
     @override
     List<Object?> get props => [/* ... existing props, */ newField];
   }
   ```

3. **Display in UI** (e.g., `lib/widgets/current_conditions_panel.dart`):
   ```dart
   _buildDataRow('New Field', '${weather.newField.round()}'),
   ```

---

## Adding a New Screen

### When to Use
- New top-level navigation destinations
- Settings/preferences screens
- Modal dialogs or full-screen overlays

### Steps

1. **Create screen file** (`lib/screens/screen_name.dart`):
   ```dart
   import 'package:flutter/material.dart';
   import '../config/theme.dart';
   
   class ScreenName extends StatelessWidget {
     const ScreenName({super.key});
     
     @override
     Widget build(BuildContext context) {
       return Scaffold(
         appBar: AppBar(
           title: const Text('Screen Title'),
         ),
         body: Container(
           decoration: const BoxDecoration(
             gradient: WeatherColors.backgroundGradient,
           ),
           child: Center(
             child: Text(
               'Screen Content',
               style: WeatherTextStyles.body(),
             ),
           ),
         ),
       );
     }
   }
   ```

2. **Add route** in `lib/app.dart`:
   ```dart
   MaterialApp(
     routes: {
       '/': (context) => const LocationPromptScreen(),
       '/tv': (context) => const TvWeatherScreen(),
       '/new-screen': (context) => const ScreenName(),
     },
     initialRoute: '/',
   )
   ```

3. **Navigate to screen:**
   ```dart
   Navigator.pushNamed(context, '/new-screen');
   ```

---

## Testing a BLoC

### Steps

1. **Create test file** (`test/blocs/feature_name/feature_name_bloc_test.dart`):
   ```dart
   import 'package:bloc_test/bloc_test.dart';
   import 'package:flutter_test/flutter_test.dart';
   import 'package:mocktail/mocktail.dart';
   import 'package:flutter_weather_channel/blocs/feature_name/feature_name_bloc.dart';
   import 'package:flutter_weather_channel/blocs/feature_name/feature_name_event.dart';
   import 'package:flutter_weather_channel/blocs/feature_name/feature_name_state.dart';
   import 'package:flutter_weather_channel/services/some_service.dart';
   import 'package:flutter_weather_channel/models/data_model.dart';
   
   class MockSomeService extends Mock implements SomeService {}
   
   void main() {
     group('FeatureNameBloc', () {
       late SomeService mockService;
       late FeatureNameBloc bloc;
       
       setUp(() {
         mockService = MockSomeService();
         bloc = FeatureNameBloc(service: mockService);
       });
       
       tearDown(() {
         bloc.close();
       });
       
       test('initial state is FeatureNameInitial', () {
         expect(bloc.state, equals(const FeatureNameInitial()));
       });
       
       blocTest<FeatureNameBloc, FeatureNameState>(
         'emits [Loading, Loaded] when successful',
         build: () {
           when(() => mockService.doSomething(any())).thenAnswer(
             (_) async => const DataModel(field: 'value'),
           );
           return bloc;
         },
         act: (bloc) => bloc.add(const SomeActionRequested(parameter: 'test')),
         expect: () => [
           const FeatureNameLoading(),
           isA<FeatureNameLoaded>(),
         ],
       );
       
       blocTest<FeatureNameBloc, FeatureNameState>(
         'emits [Loading, Error] when service fails',
         build: () {
           when(() => mockService.doSomething(any())).thenThrow(
             Exception('Service failed'),
           );
           return bloc;
         },
         act: (bloc) => bloc.add(const SomeActionRequested(parameter: 'test')),
         expect: () => [
           const FeatureNameLoading(),
           isA<FeatureNameError>(),
         ],
       );
     });
   }
   ```

---

## Testing a Service

See [Adding a New Service](#adding-a-new-service) section above for service testing example.

---

## Adding New Constants

### Steps

1. **Choose appropriate constant class** in `lib/utils/constants.dart`:
   - `ApiConstants` for API URLs and parameters
   - `TimingConstants` for durations and intervals
   - Create new class if needed

2. **Add constant:**
   ```dart
   class ApiConstants {
     ApiConstants._();
     
     static const String newApiUrl = 'https://api.example.com/v1';
     static const String newParameter = 'param_value';
   }
   
   class TimingConstants {
     TimingConstants._();
     
     static const Duration newDuration = Duration(seconds: 5);
   }
   ```

3. **Use in code:**
   ```dart
   import '../utils/constants.dart';
   
   final uri = Uri.parse(ApiConstants.newApiUrl);
   await Future.delayed(TimingConstants.newDuration);
   ```

---

## Modifying Theme Colors/Styles

### Steps

1. **Update colors** in `lib/config/theme.dart`:
   ```dart
   class WeatherColors {
     WeatherColors._();
     
     static const Color newColor = Color(0xFFHEXCODE);
     
     // Or update existing
     static const Color textYellow = Color(0xFFFFD700);
   }
   ```

2. **Update or add text styles:**
   ```dart
   class WeatherTextStyles {
     WeatherTextStyles._();
     
     static TextStyle newStyle({
       double size = 16,
       Color color = WeatherColors.textWhite,
       FontWeight weight = FontWeight.normal,
     }) {
       return GoogleFonts.robotoCondensed(
         fontSize: size,
         color: color,
         fontWeight: weight,
       );
     }
   }
   ```

3. **Use in widgets:**
   ```dart
   Text(
     'Content',
     style: WeatherTextStyles.newStyle(
       size: 20,
       color: WeatherColors.newColor,
     ),
   )
   ```

---

## Common Commands

### Running the App
```bash
flutter run
```

### Running Tests
```bash
# All tests
flutter test

# Specific test file
flutter test test/services/weather_service_test.dart

# With coverage
flutter test --coverage
```

### Code Analysis
```bash
# Run analyzer
flutter analyze

# Auto-fix issues
dart fix --apply
```

### Code Formatting
```bash
# Format all files
dart format lib/ test/

# Check formatting
dart format --output=none --set-exit-if-changed lib/ test/
```

### Dependencies
```bash
# Get dependencies
flutter pub get

# Update dependencies
flutter pub upgrade

# Analyze dependency issues
flutter pub outdated
```

---

## Troubleshooting

### BLoC not updating UI
- Ensure state classes extend `Equatable` and implement `props`
- Verify you're emitting new state objects, not mutating existing ones
- Check that `BlocProvider` is above widgets using the BLoC

### Service tests failing
- Register any objects used in `when()` with `registerFallbackValue()`
- Mock all external dependencies (HTTP client, etc.)
- Use `thenAnswer()` for async methods, `thenReturn()` for sync

### Widget tests failing
- Wrap widget in `MaterialApp` for Material widgets
- Provide required `BlocProvider` if widget uses BLoC
- Use `pumpAndSettle()` for animations to complete

### API calls not working
- Verify URL is correct in `ApiConstants`
- Check HTTP status code handling
- Ensure JSON parsing matches API response structure
- Test with actual API endpoint manually first
