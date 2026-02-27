---
name: add-widget
description: Guides creation of a new widget or content panel, including integration with the panel cycler. Use when the user wants to add a new UI component, content panel, or reusable widget.
argument-hint: "[widget name]"
---

# Adding a New Widget/Panel

Use this when creating reusable UI components, new content panels for the auto-cycling display, or custom widgets for specific features.

## Steps

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

4. **Add tests** (`test/widgets/widget_name_test.dart`):

   ```dart
   import 'package:flutter/material.dart';
   import 'package:flutter_test/flutter_test.dart';

   void main() {
     group('WidgetName', () {
       testWidgets('displays content correctly', (tester) async {
         const data = DataModel(...);

         await tester.pumpWidget(
           const MaterialApp(
             home: Scaffold(
               body: WidgetName(data: data),
             ),
           ),
         );

         expect(find.text('expected text'), findsOneWidget);
       });
     });
   }
   ```

## Conventions

- All custom widgets are `StatelessWidget` unless animation/state is needed
- Use `const` constructors whenever possible
- Extract reusable UI into private methods (prefix with `_build`)
- Use theme colors from `WeatherColors` class
- Use text styles from `WeatherTextStyles` class
- Pass required data via constructor parameters, not global state
- Use descriptive widget names that indicate purpose
- Wrap widgets in `MaterialApp` for testing
- Handle stateful widget timers and animations in tests

## Panel cycling details

- Main content auto-cycles every ~8 seconds between panels
- Uses `AnimatedSwitcher` with fade transitions
- Managed by `DisplayCubit` with timer-based cycling
- Each panel is a separate stateless widget
