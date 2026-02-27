---
name: add-screen
description: Guides creation of a new screen with routing. Use when the user wants to add a new page, settings screen, or full-screen overlay to the app.
argument-hint: "[screen name]"
---

# Adding a New Screen

Use this when adding new top-level navigation destinations, settings/preferences screens, or modal dialogs and full-screen overlays.

## Steps

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

4. **Add tests** for the screen widget if it contains interactive or data-driven elements.

## Conventions

- Screens are `StatelessWidget` unless state is needed
- Use `WeatherColors.backgroundGradient` for consistent dark navy backgrounds
- Use `WeatherTextStyles` methods for all text
- Keep screens under 300 lines; extract complex sections into widgets
