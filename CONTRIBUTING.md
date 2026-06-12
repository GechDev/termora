# Contributing to Termora

Thank you for your interest in contributing to **Termora**! We welcome bug reports, documentation improvements, widget contributions, and architecture enhancements.

## Code of Conduct

Termora is an open and welcoming community. Please treat all contributors and users with kindness, empathy, and respect.

---

## Development Setup

### Prerequisites

- **Dart SDK**: 3.0.0 or higher.
- A terminal emulator with standard ANSI escape support (Windows Terminal, iTerm2, Alacritty, GNOME Terminal, etc.).

### Getting the Code

```bash
git clone https://github.com/gechjs/termora.git
cd termora
dart pub get
```

---

## Architecture Principles

When contributing code to Termora, adhere to these core design tenets:

1. **Declarative & Immutable Widgets**: Widgets must be immutable (`const` constructors wherever possible). State belongs in `State<T>` or `RenderObject`.
2. **Double Buffer Integrity**: Never write directly to stdout inside widget or render object code. Always paint into the provided `ScreenBuffer` / `PaintingContext`.
3. **Decoupled Terminal Backend**: Code must remain testable using `VirtualTerminalBackend`. Avoid static dependencies on `dart:io` stdout outside `IoTerminalBackend`.
4. **Deterministic Layout Math**: Layout uses integer coordinates. Never use floating point coordinates without rounding or truncation to discrete grid cells.
5. **Fail-Safe Restoration**: Keep error isolation in mind. Never disable signal traps or leave raw mode active on unexpected exits.

---

## Development Workflow

Before submitting a pull request, run the verification checklist:

1. **Format Code**:
   ```bash
   dart format lib test example
   ```
2. **Analyze Code**:
   ```bash
   dart analyze --fatal-infos
   ```
3. **Run Test Suite**:
   ```bash
   dart test
   ```

All checks must pass with zero warnings, hints, or errors.

---

## Commit Guidelines

We use [Conventional Commits](https://www.conventionalcommits.org/):

- `feat:` New features, widgets, or API additions
- `fix:` Bug fixes and layout edge case corrections
- `test:` Unit and snapshot test suites
- `docs:` Documentation, README, and dartdoc comments
- `refactor:` Code restructuring without behavioral changes
- `chore:` Dependency, CI/CD, and release metadata updates
