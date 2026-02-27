---
name: add-bloc
description: Guides creation of a new BLoC with events, states, and registration. Use when the user wants to add a new BLoC or Cubit for state management, or asks how to structure event-driven logic.
argument-hint: "[feature name]"
---

# Adding a New BLoC

Use this when you need complex state management with multiple events, event-driven logic, or async operations with loading/success/error states.

## Steps

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

6. **Add tests** — see the `test-bloc` skill for BLoC testing guidance.

## Conventions

- Each BLoC lives in its own folder: `bloc.dart`, `event.dart`, `state.dart`
- States and events extend `Equatable`
- Use `Cubit` for simple state (e.g., `DisplayCubit`); use full `Bloc` for complex event-driven logic
- Emit new state objects; never mutate existing state
- Inject dependencies via constructor
- Use `on<EventType>` handlers in BLoC constructors
- Always call `super.close()` when overriding `close()` for cleanup
- BLoC events use past-tense verbs (`WeatherFetched`, `ZipCodeSubmitted`)
- BLoC states use adjectives/nouns (`WeatherLoading`, `WeatherLoaded`)
