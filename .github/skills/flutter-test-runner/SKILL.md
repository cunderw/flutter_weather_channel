---
name: flutter-test-runner
description: Runs Flutter tests for this project. Use when the user asks to run tests, fix a failing test, check test output, or validate changes. Knows the project test structure, how to target specific test files, and how to interpret results.
argument-hint: "[test file or directory] [options]"
---

# Flutter Test Runner

Run and manage Flutter tests for this project.

## Test commands

- **All tests**: `flutter test`
- **Single file**: `flutter test test/blocs/docker/docker_cubit_test.dart`
- **Directory**: `flutter test test/blocs/`
- **By name**: `flutter test --name "emits DockerLoading"`
- **With coverage**: `flutter test --coverage`

## Project test structure

Tests mirror `lib/`:

## Interpreting failures

- **`Bad state: GetIt: Object/factory with type X is not registered`** — Test pumps `UnraidApp` or a widget that uses `getIt` without registering mock dependencies. Fix: register mocks in GetIt before pumping (see `test/widget_test.dart`).
- **`MissingStubError`** — A `mocktail` mock method was called without a `when()` stub. Add the missing stub in the test's `build:` or `setUp`.
- **`Expected: ...` / `Actual: ...`** — State emission mismatch. Check the cubit logic and the `expect:` list in `blocTest`.

## When fixing a failing test

1. Run the specific failing test file first to reproduce
2. Read the error output carefully — mocktail errors name the missing stub
3. Check if the source code changed and the test needs updating (new states, renamed methods, changed signatures)
4. Check if `test/helpers/mocks.dart` or `test/helpers/factories.dart` need new entries
5. Run the full suite after fixing to catch regressions: `flutter test`
