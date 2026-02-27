---
name: pre-commit-check
description: Runs the full pre-commit validation suite for this Flutter project. Use when the user says "ready to commit", "check before PR", "validate changes", or "pre-commit". Runs analysis and tests together and reports results.
argument-hint: "[optional: specific files or directories to check]"
---

# Pre-Commit Check

Run the full validation suite before committing or opening a PR.

## Steps

Run these commands in order. Stop and report issues at the first failure:

1. **Install dependencies** (if needed):
   ```bash
   flutter pub get
   ```

2. **Static analysis**:
   ```bash
   flutter analyze
   ```
   Fix any warnings or errors before proceeding.

3. **Run all tests**:
   ```bash
   flutter test
   ```
   All tests must pass.

## Interpreting results

- **`flutter analyze`** — zero issues means pass. Any `info`, `warning`, or `error` should be addressed.
- **`flutter test`** — look for the summary line: `+N: All tests passed.` means success. Any `-N` indicates failures.

## Common pre-commit issues

| Issue | Resolution |
|-------|-----------|
| New repository not registered in GetIt | Add to `lib/di/injection.dart` |
| New mock class missing | Add to `test/helpers/mocks.dart` |
| New model missing test factory | Add `make*()` to `test/helpers/factories.dart` |
| Unused imports after refactor | Remove them — `flutter analyze` catches these |
| Missing `const` on constructors | Add `const` — all state/model constructors must be `const` |

## Report format

After running, summarize:

```
Pre-commit check:
  Analysis: ✓ pass / ✗ N issues
  Tests:    ✓ N passed / ✗ N failed
```
