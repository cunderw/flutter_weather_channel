# Tests

This directory contains all tests for the Flutter Weather Channel app.

## Structure

Tests mirror the `lib/` directory structure:

```
test/
├── blocs/              # BLoC/Cubit tests
│   ├── weather/
│   ├── location/
│   └── display/
├── models/             # Data model tests
├── services/           # API service tests
├── utils/              # Utility function tests
└── widgets/            # Widget tests
```

## Running Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/services/weather_service_test.dart

# Run tests in a directory
flutter test test/services/

# Run tests with coverage
flutter test --coverage

# Run tests in watch mode (re-run on changes)
flutter test --watch
```

## Test Types

### Service Tests

Test API services with mocked HTTP clients:
- Success cases with valid responses
- Error cases with invalid status codes
- Edge cases (null values, empty responses)
- Exception handling

### BLoC Tests

Test state management using `bloc_test`:
- Initial state
- Event handling and state transitions
- Success and error flows
- Timer/resource cleanup

### Model Tests

Test data models:
- JSON parsing with `fromJson`
- Computed properties
- Equality (Equatable)
- Edge cases and null handling

### Widget Tests

Test UI components:
- Widget rendering
- Data display
- User interactions
- Layout and styling

## Test Quality Standards

- Every public method must have tests
- Test both happy path and error cases
- Use descriptive test names
- Group related tests with `group()`
- Clean up resources in `tearDown()`
- Aim for >80% code coverage
- All tests must pass before merging

## Dependencies

- `flutter_test`: Core testing framework (from Flutter SDK)
- `bloc_test`: BLoC testing utilities
- `mocktail`: Mocking framework

See `pubspec.yaml` for current versions.
