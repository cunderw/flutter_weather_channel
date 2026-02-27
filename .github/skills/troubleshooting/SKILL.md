---
name: troubleshooting
description: Common troubleshooting tips and solutions for this Flutter project. Use when the user encounters an error, something isn't working, or needs help debugging an issue with BLoCs, services, widgets, or API calls.
argument-hint: "[error message or problem description]"
---

# Troubleshooting

Common issues and solutions for this project.

## BLoC not updating UI

- Ensure state classes extend `Equatable` and implement `props` — identical states are deduplicated
- Verify you're emitting **new** state objects, not mutating existing ones
- Check that `BlocProvider` is above widgets that use the BLoC in the widget tree
- If using `Cubit`, ensure `emit()` is called with a different state instance

## Service tests failing

- Register any objects used in `when()` with `registerFallbackValue()` in `setUpAll`
- Mock all external dependencies (HTTP client, etc.)
- Use `thenAnswer()` for async methods, `thenReturn()` for sync
- Check that the mock is passed to the service constructor

## Widget tests failing

- Wrap widget in `MaterialApp` for Material widgets
- Provide required `BlocProvider` wrappers if the widget uses a BLoC
- Use `pumpAndSettle()` for animations to complete
- For widgets with timers, use `pump(Duration)` instead of `pumpAndSettle()`

## API calls not working

- Verify URL is correct in `ApiConstants`
- Check HTTP status code handling in the service
- Ensure JSON parsing matches actual API response structure
- Test with actual API endpoint manually first (curl or browser)
- Open-Meteo and RainViewer APIs require no API keys

## `MissingStubError` in tests

A `mocktail` mock method was called without a `when()` stub. Add the missing `when()` in the test's `build:` or `setUp`.

## `Bad state` errors

Usually means a provider or BLoC wasn't registered. Check that:

- `BlocProvider` / `RepositoryProvider` are set up in `app.dart`
- `context.read<T>()` is called below the provider in the widget tree

## Common commands

```bash
flutter pub get                    # Install dependencies
flutter analyze                    # Run static analysis
flutter test                       # Run all tests
flutter test path/to/test.dart     # Run specific test file
flutter test --coverage            # Generate coverage report
dart format lib/ test/             # Format code
dart fix --apply                   # Auto-fix lint issues
flutter run                        # Run on connected device/emulator
flutter pub upgrade                # Update dependencies
flutter pub outdated               # Check for outdated packages
```
