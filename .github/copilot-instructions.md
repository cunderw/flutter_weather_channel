# Flutter Weather Channel — Copilot Instructions

## Project Overview

This is a Flutter app that recreates the nostalgic look and feel of 1990s–2000s TV Weather Channel
"Local on the 8s" broadcasts. It displays current conditions, radar imagery, and text summaries on
an auto-cycling TV-style screen with a scrolling forecast ticker at the bottom.

## Architecture

- **State Management:** BLoC / Cubit (`flutter_bloc`)
- **Weather API:** Open-Meteo (no API key required)
- **Radar Imagery:** RainViewer free API (static composite radar tiles)
- **Location:** `geolocator` + `geocoding` packages for device GPS; Open-Meteo Geocoding API for zip code lookup

## Folder Structure

```
lib/
├── main.dart                     App entry point, BlocProviders
├── app.dart                      MaterialApp, routing, theme
├── config/
│   └── theme.dart                TV Weather Channel color palette & text styles
├── models/
│   ├── weather.dart              Current conditions model
│   ├── forecast.dart             Hourly/daily forecast model
│   └── location.dart             Location (lat, lon, city, state, zip)
├── services/
│   ├── weather_service.dart      Open-Meteo API client
│   ├── location_service.dart     Geolocator wrapper
│   └── geocoding_service.dart    Zip → coordinates (Open-Meteo Geocoding)
├── blocs/
│   ├── weather/                  WeatherBloc (events + states)
│   ├── location/                 LocationBloc (events + states)
│   └── display/                  DisplayCubit (panel cycling)
├── screens/
│   ├── location_prompt_screen.dart   Zip entry + "Use My Location"
│   └── tv_weather_screen.dart        Main TV broadcast view
├── widgets/
│   ├── tv_frame.dart             CRT scanline/vignette overlay
│   ├── forecast_ticker.dart      Scrolling bottom forecast bar
│   ├── current_conditions_panel.dart
│   ├── radar_panel.dart          Static radar image display
│   ├── text_summary_panel.dart   Scrolling text summary
│   ├── weather_info_bar.dart     Top bar (city, time, date)
│   └── content_cycler.dart       Auto-cycles between content panels
└── utils/
    ├── weather_icons.dart        WMO code → description/icon mapping
    └── constants.dart            API URLs, timing, color constants
```

## Conventions

### BLoC Pattern

- Each BLoC lives in its own folder: `bloc.dart`, `event.dart`, `state.dart`
- States and events extend `Equatable`
- Use `Cubit` for simple state (e.g., DisplayCubit); use full `Bloc` for complex event-driven logic
- Emit new state objects; never mutate existing state

### Naming

- Files: `snake_case.dart`
- Classes: `PascalCase`
- BLoC events: past-tense verbs (`WeatherFetched`, `ZipCodeSubmitted`)
- BLoC states: adjectives/nouns (`WeatherLoading`, `WeatherLoaded`)

### Models

- All models are immutable (final fields)
- Extend `Equatable` and override `props`
- Include `factory fromJson(Map<String, dynamic> json)` constructors
- Use WMO weather interpretation codes (integers) mapped locally to descriptions

### Theming

- Dark navy gradient backgrounds (`#0a1931` → `#1a3a5c`)
- Yellow for temperatures, cyan for location names, white for general text
- Google Fonts: "VT323" for LED/pixel readouts, "Roboto Condensed" for body
- Semi-transparent dark overlays for info bars
- Blue band at bottom for forecast ticker

### APIs

- **Open-Meteo Forecast:** `https://api.open-meteo.com/v1/forecast?latitude={lat}&longitude={lon}&current=...&hourly=...&daily=...&temperature_unit=fahrenheit&wind_speed_unit=mph&timezone=auto`
- **Open-Meteo Geocoding:** `https://geocoding-api.open-meteo.com/v1/search?name={query}&count=1&language=en&format=json`
- **RainViewer Radar:** `https://api.rainviewer.com/public/weather-maps.json` → use latest composite radar tile URL
- No API keys are needed for any of these services

### Testing

- Unit tests for services (mock HTTP with `mocktail`)
- BLoC tests with `bloc_test` package
- Widget tests for individual panels
- Test files mirror `lib/` structure under `test/`

### Panel Cycling

- Main content auto-cycles every ~8 seconds between 3 panels:
  1. Current Conditions (temp, humidity, wind, pressure, etc.)
  2. Radar (static composite image centered on location)
  3. Text Summary (narrative description of current + forecast conditions)
- Uses `AnimatedSwitcher` with fade transitions

### Ticker

- Bottom forecast ticker scrolls continuously left-to-right
- Shows hourly forecasts: time, temp, weather icon
- Blue background band with white/yellow text
