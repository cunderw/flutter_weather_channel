---
name: test-bloc
description: Guides writing BLoC and Cubit tests using bloc_test and mocktail. Use when the user wants to test a BLoC, fix a failing BLoC test, or add test coverage for state management.
argument-hint: "[bloc name or test file]"
---

# Testing a BLoC

Use this when writing or fixing tests for BLoCs and Cubits.

## Steps

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

## What to test

- **Initial state**: Verify the bloc starts in the correct initial state
- **Each event handler**: Test state transitions for every event type
- **Success paths**: Mock service returns data, verify `[Loading, Loaded]` emissions
- **Error paths**: Mock service throws, verify `[Loading, Error]` emissions
- **Timer cleanup**: If the bloc uses timers, test that `close()` cancels them
- **Edge cases**: Empty data, null values, concurrent events

## Conventions

- Use `bloc_test` package for testing BLoCs
- Mock injected services with `mocktail`
- Always `tearDown` with `bloc.close()`
- Use `any(named: 'paramName')` for named parameters in `when()` stubs
- Use `isA<StateType>()` for states with dynamic data

## Troubleshooting

- **BLoC not emitting expected states**: Ensure state classes extend `Equatable` and implement `props` — duplicate states are dropped
- **`MissingStubError`**: A mock method was called without a `when()` stub — add the missing stub in `build:`
- **Timer not cleaned up**: Override `close()` in the BLoC and cancel timers, then test it
