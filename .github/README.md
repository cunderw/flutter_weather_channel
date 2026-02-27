# Documentation Index

This directory contains comprehensive documentation for the Flutter Weather Channel project.

## Documents

### [copilot-instructions.md](copilot-instructions.md)
**Purpose:** GitHub Copilot agent instructions that provide high-level guidance on the project architecture, conventions, and coding patterns.

**Contents:**
- Project overview and architecture
- Folder structure reference
- BLoC pattern conventions with examples
- Model, service, and widget patterns
- Theming guidelines
- API reference
- Testing guidelines
- Panel cycling and ticker implementation details

**Target Audience:** GitHub Copilot agents, new developers, AI assistants

**File Size:** 314 lines (~11 KB)

---

### [copilot-skills.md](copilot-skills.md)
**Purpose:** Step-by-step guides for common development tasks in this codebase.

**Contents:**
- Adding new BLoCs (structure, registration, testing)
- Adding new models (JSON parsing, Equatable, testing)
- Adding new services (HTTP clients, error handling, testing)
- Adding new widgets/panels
- Adding new weather data fields
- Adding new screens
- Testing BLoCs and services
- Adding constants
- Modifying theme colors/styles
- Common commands (run, test, analyze, format)
- Troubleshooting guide

**Target Audience:** Developers, GitHub Copilot agents, contributors

**File Size:** 704 lines (~18 KB)

---

### [../CONVENTIONS.md](../CONVENTIONS.md)
**Purpose:** Comprehensive coding standards and best practices for the project.

**Contents:**
- File organization and directory structure
- Naming conventions (files, classes, variables, functions)
- Code style guidelines (formatting, indentation, trailing commas)
- BLoC pattern deep dive (events, states, implementation)
- Model conventions (immutability, Equatable, JSON parsing)
- Service conventions (error handling, testing, dependency injection)
- Widget conventions (stateless vs stateful, theming)
- Theme and styling guidelines
- Error handling patterns
- Testing guidelines (unit tests, BLoC tests)
- Documentation standards
- Import order rules
- Git commit message format
- Code review checklist
- Resource links

**Target Audience:** All developers, code reviewers, contributors

**File Size:** 979 lines (~23 KB)

---

## Quick Reference

### For New Developers
1. Start with [copilot-instructions.md](copilot-instructions.md) for an overview
2. Read [../CONVENTIONS.md](../CONVENTIONS.md) to understand coding standards
3. Use [copilot-skills.md](copilot-skills.md) as a reference when implementing features

### For GitHub Copilot
- Primary reference: [copilot-instructions.md](copilot-instructions.md)
- Task-specific guidance: [copilot-skills.md](copilot-skills.md)
- Detailed standards: [../CONVENTIONS.md](../CONVENTIONS.md)

### For Code Reviewers
- Use [../CONVENTIONS.md](../CONVENTIONS.md) as the standard for reviews
- Reference the code review checklist at the end of CONVENTIONS.md

---

## Maintenance

These documents should be updated when:
- New architectural patterns are introduced
- Significant refactoring changes project structure
- New tools or libraries are added
- Coding standards evolve
- Common development tasks change

## Related Documentation

- **README.md** (project root): User-facing project overview, setup instructions, features
- **analysis_options.yaml**: Dart analyzer configuration and lint rules
- **pubspec.yaml**: Project dependencies and metadata

---

**Last Updated:** 2026-02-27

**Total Documentation:** 2,108 lines (~60 KB)
