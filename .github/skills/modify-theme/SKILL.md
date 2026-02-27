---
name: modify-theme
description: Guides modifying theme colors, text styles, and visual design tokens. Use when the user wants to change colors, fonts, text styles, or visual theming in the app.
argument-hint: "[color or style to change]"
---

# Modifying Theme Colors/Styles

## Steps

1. **Update colors** in `lib/config/theme.dart`:

   ```dart
   class WeatherColors {
     WeatherColors._();

     static const Color newColor = Color(0xFFHEXCODE);

     // Or update existing
     static const Color textYellow = Color(0xFFFFD700);
   }
   ```

2. **Update or add text styles:**

   ```dart
   class WeatherTextStyles {
     WeatherTextStyles._();

     static TextStyle newStyle({
       double size = 16,
       Color color = WeatherColors.textWhite,
       FontWeight weight = FontWeight.normal,
     }) {
       return GoogleFonts.robotoCondensed(
         fontSize: size,
         color: color,
         fontWeight: weight,
       );
     }
   }
   ```

3. **Use in widgets:**
   ```dart
   Text(
     'Content',
     style: WeatherTextStyles.newStyle(
       size: 20,
       color: WeatherColors.newColor,
     ),
   )
   ```

## Color palette

| Color                      | Hex          | Usage                      |
| -------------------------- | ------------ | -------------------------- |
| Dark navy (gradient start) | `0xFF0A1931` | Background                 |
| Medium navy (gradient end) | `0xFF1A3A5C` | Background                 |
| Yellow                     | `0xFFFFD700` | Temperatures               |
| Cyan                       | `0xFF00E5FF` | Location names             |
| White                      | `0xFFFFFFFF` | General text               |
| Gray                       | `0xFFBBBBBB` | Secondary text             |
| Semi-transparent dark      | `0xCC0A1931` | Info bar overlays          |
| Blue band                  | `0xFF003399` | Forecast ticker background |

## Fonts

- **"VT323"** (Google Fonts) — LED/pixel readouts, retro display text
- **"Roboto Condensed"** (Google Fonts) — Body text, general UI

## Conventions

- Use `WeatherColors` constants instead of hardcoded colors
- Use `WeatherTextStyles` methods for consistent typography
- Theme classes use private constructor: `ClassName._();`
- Keep all visual tokens in `lib/config/theme.dart`
