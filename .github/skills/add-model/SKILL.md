---
name: add-model
description: Guides creation of a new immutable data model with Equatable, fromJson, and tests. Use when the user wants to add a new model class for API data, domain objects, or UI state.
argument-hint: "[model name]"
---

# Adding a New Model

Use this when representing data structures from APIs, domain models for business logic, or UI state models.

## Steps

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

       test('fromJson handles optional fields', () {
         final json = {
           'field_1': 'value',
           'field_2': 42,
           'optional_field': 3.14,
         };
         final model = ModelName.fromJson(json);
         expect(model.optionalField, 3.14);
       });

       test('equality works correctly', () {
         const a = ModelName(field1: 'a', field2: 1);
         const b = ModelName(field1: 'a', field2: 1);
         expect(a, equals(b));
       });

       test('computed properties return expected values', () {
         const model = ModelName(field1: 'test', field2: 5);
         expect(model.displayValue, 'test (5)');
       });
     });
   }
   ```

## Conventions

- All models are immutable (final fields)
- Extend `Equatable` and override `props`
- Include `factory fromJson(Map<String, dynamic> json)` constructors
- Use `const` constructors when possible
- Include computed properties for derived values (e.g., `displayName`)
- No `toJson` methods (read-only from API)
- Use WMO weather interpretation codes (integers) mapped locally to descriptions
- Test `fromJson` with valid data, missing/null fields, computed properties, and equality
