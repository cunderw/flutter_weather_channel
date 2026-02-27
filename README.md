# Flutter Weather Channel

A Flutter app that recreates the nostalgic look and feel of 1990s-2000s TV Weather Channel "Local on the 8s" broadcasts. Enter a zip code or share your device location, and watch current conditions, radar imagery, and text summaries cycle on an auto-cycling TV-style screen — complete with a scrolling forecast ticker, CRT scanlines, and retro fonts.

![Flutter](https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter)
![License](https://img.shields.io/badge/License-MIT-green)
![Tests](https://github.com/cunderw/flutter_weather_channel/workflows/Tests/badge.svg)

---

## Current Features (v1)

- **Location entry** — Zip code input or device GPS with reverse geocoding
- **Current conditions panel** — Temperature, feels-like, humidity, wind, pressure, UV index, visibility
- **Radar panel** — Static composite radar image from RainViewer API centered on your location
- **Text summary panel** — Narrative description of current weather and short-term forecast
- **Auto-cycling content** — Panels fade-transition every ~8 seconds (Current -> Radar -> Summary)
- **Forecast ticker** — Continuously scrolling bottom bar with hourly forecast (time, icon, temp)
- **CRT TV overlay** — Scanline and vignette effects for authentic retro look
- **Live clock** — Top info bar with city name, date, and real-time clock
- **Retro theming** — Dark navy gradients, VT323 pixel font, Weather Channel color palette
- **Auto-refresh** — Weather data refreshes every 10 minutes in the background

## Planned Features

- [ ] Background smooth jazz audio (royalty-free lo-fi Weather Channel music)
- [ ] 7-day extended forecast panel added to the content cycle
- [ ] Severe weather alerts with red banner overlay
- [ ] Multiple saved locations with quick switching
- [ ] Settings screen (cycle speed, CRT effect toggle, F/C units)
- [ ] Animated weather icons (rain drops, snow flakes, sun rays)
- [ ] "Local on the 8s" scheduled refresh mode
- [ ] Home screen widget / lock screen companion
- [ ] Landscape / tablet optimized layout
- [ ] Accessibility mode (disable CRT effects, increase contrast)

## Architecture

| Layer            | Technology                                                               |
| ---------------- | ------------------------------------------------------------------------ |
| State Management | BLoC / Cubit (`flutter_bloc`)                                            |
| Weather API      | [Open-Meteo](https://open-meteo.com/) (free, no API key)                 |
| Radar            | [RainViewer](https://www.rainviewer.com/api.html) (free composite tiles) |
| Location         | `geolocator` + `geocoding` + Open-Meteo Geocoding API                    |
| Fonts            | Google Fonts — VT323, Roboto Condensed                                   |

### Folder Structure

```
lib/
├── main.dart                     App entry point
├── app.dart                      MaterialApp, routing, BlocProviders
├── config/
│   └── theme.dart                Color palette & text styles
├── models/
│   ├── weather.dart              Current conditions model
│   ├── forecast.dart             Hourly/daily forecast model
│   └── location.dart             Location model
├── services/
│   ├── weather_service.dart      Open-Meteo API client
│   ├── location_service.dart     Geolocator wrapper
│   └── geocoding_service.dart    Zip -> coordinates
├── blocs/
│   ├── weather/                  WeatherBloc (fetch + auto-refresh)
│   ├── location/                 LocationBloc (zip + GPS)
│   └── display/                  DisplayCubit (panel cycling)
├── screens/
│   ├── location_prompt_screen.dart
│   └── tv_weather_screen.dart
├── widgets/
│   ├── tv_frame.dart             CRT scanline/vignette overlay
│   ├── forecast_ticker.dart      Scrolling bottom forecast bar
│   ├── current_conditions_panel.dart
│   ├── radar_panel.dart
│   ├── text_summary_panel.dart
│   ├── weather_info_bar.dart     Top bar (city, time, date)
│   └── content_cycler.dart       Auto-cycles between panels
└── utils/
    ├── weather_icons.dart        WMO code -> description/icon
    └── constants.dart            API URLs, timing constants
```

## Getting Started

### Prerequisites

- Flutter SDK 3.x+
- Dart SDK 3.11+

### Setup

```bash
# Clone the repo
git clone https://github.com/your-username/flutter_weather_channel.git
cd flutter_weather_channel

# Install dependencies
flutter pub get

# Run the app
flutter run
```

No API keys are required — Open-Meteo and RainViewer are free and open.

### Running Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/services/weather_service_test.dart

# Run with coverage
flutter test --coverage

# Run static analysis
flutter analyze

# Format code
dart format .
```

All tests run automatically on push and pull requests via GitHub Actions. See `.github/workflows/test.yml` for the CI configuration.

## APIs Used

| API                                                                  | Purpose                                     | Auth |
| -------------------------------------------------------------------- | ------------------------------------------- | ---- |
| [Open-Meteo Forecast](https://open-meteo.com/en/docs)                | Current conditions + hourly/daily forecasts | None |
| [Open-Meteo Geocoding](https://open-meteo.com/en/docs/geocoding-api) | Zip/city -> lat/lon lookup                  | None |
| [RainViewer](https://www.rainviewer.com/api.html)                    | Composite radar imagery tiles               | None |

## License

MIT
