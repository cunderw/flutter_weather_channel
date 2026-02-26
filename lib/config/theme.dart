import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Classic TV Weather Channel color palette.
class WeatherColors {
  WeatherColors._();

  // Backgrounds
  static const Color backgroundDark = Color(0xFF0A1931);
  static const Color backgroundLight = Color(0xFF1A3A5C);
  static const Color tickerBlue = Color(0xFF003399);
  static const Color infoBarOverlay = Color(0xCC0A1931); // ~80% opacity

  // Text
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textYellow = Color(0xFFFFD700);
  static const Color textCyan = Color(0xFF00E5FF);
  static const Color textGreen = Color(0xFF00FF7F);
  static const Color textRed = Color(0xFFFF4444);
  static const Color textGray = Color(0xFFBBBBBB);

  // Accents
  static const Color borderGlow = Color(0xFF2196F3);
  static const Color scanlineColor = Color(0x0DFFFFFF); // very faint white

  /// Standard dark-navy gradient used behind most panels.
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [backgroundDark, backgroundLight],
  );
}

/// Text styles replicating the retro TV Weather Channel aesthetic.
/// All text uses pixelated / monospace fonts for a low-res broadcast look.
class WeatherTextStyles {
  WeatherTextStyles._();

  /// Pixel / LED readout font — used for large temperatures, data values.
  static TextStyle led({
    double size = 48,
    Color color = WeatherColors.textYellow,
  }) {
    return GoogleFonts.vt323(
      fontSize: size,
      color: color,
      letterSpacing: 2,
      shadows: [
        Shadow(color: color.withValues(alpha: 0.5), blurRadius: 6),
      ],
    );
  }

  /// Body text — also uses the pixel font for full retro consistency.
  static TextStyle body({
    double size = 16,
    Color color = WeatherColors.textWhite,
    FontWeight weight = FontWeight.normal,
  }) {
    return GoogleFonts.vt323(
      fontSize: size + 4, // VT323 reads smaller, bump slightly
      color: color,
      fontWeight: weight,
      shadows: [
        Shadow(color: color.withValues(alpha: 0.3), blurRadius: 2),
      ],
    );
  }

  /// Heading — larger pixel font with stronger glow.
  static TextStyle heading({
    double size = 24,
    Color color = WeatherColors.textCyan,
  }) {
    return GoogleFonts.vt323(
      fontSize: size + 6,
      color: color,
      fontWeight: FontWeight.bold,
      letterSpacing: 3,
      shadows: [
        Shadow(color: color.withValues(alpha: 0.6), blurRadius: 8),
        Shadow(color: color.withValues(alpha: 0.3), blurRadius: 16),
      ],
    );
  }

  /// Ticker text — used in the bottom scrolling bar.
  static TextStyle ticker({
    double size = 18,
    Color color = WeatherColors.textWhite,
  }) {
    return GoogleFonts.vt323(
      fontSize: size + 4,
      color: color,
      fontWeight: FontWeight.w500,
      letterSpacing: 1,
      shadows: [
        Shadow(color: color.withValues(alpha: 0.4), blurRadius: 3),
      ],
    );
  }
}

/// App-wide ThemeData configured for the TV Weather Channel look.
ThemeData weatherTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: WeatherColors.backgroundDark,
    colorScheme: const ColorScheme.dark(
      primary: WeatherColors.borderGlow,
      secondary: WeatherColors.textYellow,
      surface: WeatherColors.backgroundDark,
    ),
    textTheme: TextTheme(
      displayLarge: WeatherTextStyles.led(size: 72),
      displayMedium: WeatherTextStyles.led(size: 48),
      displaySmall: WeatherTextStyles.led(size: 32),
      headlineMedium: WeatherTextStyles.heading(),
      bodyLarge: WeatherTextStyles.body(size: 18),
      bodyMedium: WeatherTextStyles.body(),
      bodySmall: WeatherTextStyles.body(
        size: 14,
        color: WeatherColors.textGray,
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
    ),
  );
}
