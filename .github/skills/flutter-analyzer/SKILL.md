---
name: flutter-analyzer
description: Runs Flutter static analysis for this project. Use when the user mentions lint errors, code quality issues, analysis warnings, or wants to check code before committing. Understands the project's lint rules and conventions.
argument-hint: "[file or directory to analyze]"
---

# Flutter Analyzer

Run static analysis and fix lint issues for this project.

## Commands

- **Full analysis**: `flutter analyze`
- **Specific directory**: `flutter analyze lib/blocs/`

## Project lint configuration

- Uses `package:flutter_lints/flutter.yaml` (see `analysis_options.yaml`)
- No custom overrides — standard Flutter linting rules apply

## Common issues and fixes

| Issue | Fix |
|-------|-----|
| `prefer_const_constructors` | Add `const` keyword. All model/state constructors should be `const`. |
| `prefer_final_fields` | Make fields `final`. All model and state fields must be `final`. |
| `unused_import` | Remove the import. |
| `missing_return` | Add exhaustive `switch` branches — sealed classes require all variants. |
| `avoid_print` | Use `Log.d/i/w/e()` from `lib/utils/log.dart` instead of `print()`. |
| `unnecessary_this` | Remove `this.` — only needed in constructors with `this.field` syntax. |

## Project-specific conventions to verify

- All state classes use `sealed class` base + `final class` leaves
- All model constructors are `const`
- Utility/constant classes use `abstract final class` (e.g., `AppSpacing`, `Queries`)
- No `toJson` methods on models (read-only from API)
- GraphQL strings use raw string literals (`r'''...'''`)
- Log calls use `_tag` constant, not string literals
