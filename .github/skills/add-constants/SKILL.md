---
name: add-constants
description: Guides adding new constants for API URLs, timing, or configuration. Use when the user wants to add or modify constant values used across the app.
argument-hint: "[constant name or category]"
---

# Adding New Constants

## Steps

1. **Choose appropriate constant class** in `lib/utils/constants.dart`:
   - `ApiConstants` for API URLs and parameters
   - `TimingConstants` for durations and intervals
   - Create a new class if the constant doesn't fit existing categories

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

## Conventions

- Store all constants in dedicated classes under `lib/utils/constants.dart`
- Use descriptive class names: `ApiConstants`, `TimingConstants`
- Make classes private with private constructor: `ClassName._();`
- Use `static const` for all constant values
- Group related constants together
- No magic numbers or strings in widget/service/bloc code — extract to constants
