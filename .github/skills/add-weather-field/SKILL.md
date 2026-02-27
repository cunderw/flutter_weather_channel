---
name: add-weather-field
description: Guides adding a new weather data field end-to-end — from API constants to model to UI display. Use when the user wants to show a new weather metric from Open-Meteo.
argument-hint: "[field name]"
---

# Adding a New Weather Data Field

Use this when adding a new weather metric from the Open-Meteo API, or adding computed/derived weather values.

## Steps

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

4. **Update model tests** (`test/models/weather_test.dart`):
   - Add the new field to existing test JSON fixtures
   - Add a dedicated test for the new field's parsing
   - Test edge cases (null, zero, boundary values)

5. **Update widget tests** if the field is displayed in a panel.

## Notes

- Open-Meteo API fields are documented at https://open-meteo.com/en/docs
- Use WMO weather interpretation codes (integers) mapped locally to descriptions
- Temperature units are Fahrenheit, wind speed is mph (configured in API URL)
- All API URLs and field lists are stored in `ApiConstants` class
