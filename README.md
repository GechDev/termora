# Termora

[![Dart](https://img.shields.io/badge/Dart-3.0+-blue.svg)](https://dart.dev)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)
[![Tests](https://img.shields.io/badge/Tests-Passing-brightgreen.svg)]()
[![Version](https://img.shields.io/badge/Version-0.1.0-orange.svg)]()

**Termora** is an independent, declarative, widget-driven Terminal UI (TUI) framework for Dart, designed to build sophisticated, flicker-free, interactive command-line applications.

Inspired by Flutter's component and rendering architecture, Termora brings immutable widget trees, element lifecycles, integer box constraints, and double-buffered ANSI screen rendering to terminal workflows.

---

## Architecture Overview

Termora is architected in clean, decoupled layers from high-level widgets down to low-level VT100 / ANSI escape generation:

```
┌────────────────────────────────────────────────────────┐
│                   Declarative UI                       │
│    StatelessWidget • StatefulWidget • InheritedWidget   │
├────────────────────────────────────────────────────────┤
│                    Component Tree                      │
│      Element • ComponentElement • RenderObjectElement  │
├────────────────────────────────────────────────────────┤
│                    Layout Engine                       │
│   BoxConstraints • Flex • Alignment • Padding • Scroll │
├────────────────────────────────────────────────────────┤
│                   Rendering Engine                     │
│       PaintingContext • RenderObject • ScreenBuffer    │
├────────────────────────────────────────────────────────┤
│                 Differential Buffer                    │
│      DoubleBuffer (Front & Back) • Cell Diff Engine     │
├────────────────────────────────────────────────────────┤
│               ANSI & Terminal Backends                 │
│   VT100 Escape Sequences • VirtualTerminal • IoTerminal│
└────────────────────────────────────────────────────────┘
```

---

## Key Features

- **Declarative & Component-Driven**: Compose terminal interfaces using immutable, reusable widgets (`StatelessWidget`, `StatefulWidget`).
- **Diff-Based Double Buffering**: Back and front buffers are diffed every frame. Only cells that actually change emit ANSI cursor jump sequences, eliminating screen flicker and minimizing bandwidth.
- **True Flutter-Style Constraints**: Integer-based `BoxConstraints` layout system with tight, loose, bounded, and unbounded bounds.
- **Rich Terminal Styling**:
  - Full support for 16 standard ANSI colors, 256 indexed colors, and 24-bit TrueColor (RGB).
  - Text modifiers: bold, dim, italic, underline, reverse video, strikethrough.
  - Border presets: single, double, heavy, rounded, ascii, dotted, dashed.
- **Robust Input & Focus Hierarchy**:
  - Raw ANSI escape sequence parser supporting ASCII, Unicode UTF-8, Arrow Keys, Home/End, PageUp/PageDown, Delete/Backspace, and Ctrl / Shift combinations.
  - `FocusNode` and `FocusManager` graph enabling seamless keyboard navigation with Tab and Shift+Tab.
- **Resilient Lifecycle Boundaries**:
  - `TerminalManager` guarantees restoration of raw mode, alternate screen buffer, and cursor visibility even upon unhandled errors or SIGINT / SIGTERM signals.
  - `ErrorBoundary` and `ErrorWidget` isolate subtree crashes and display clean diagnostic cards.
- **100% Headless Testability**:
  - `VirtualTerminalBackend` allows headless snapshot testing of terminal frames without requiring an interactive TTY.

---

## Widget Catalog

| Category | Widget | Description |
|---|---|---|
| **Text** | `Text` | Monospaced text with truncation, overflow clipping, and styles |
| | `RichText` | Multi-styled inline spans (`TextSpan`) on the same line |
| **Layout** | `Row` / `Column` | Flex-based linear arrangements with Main/Cross axis alignment |
| | `Expanded` / `Flexible` | Flexible proportional sizing inside flex containers |
| | `Spacer` | Adjustable empty space between flex items |
| | `Align` / `Center` | Fractional child alignment (`topLeft`, `center`, `bottomRight`, etc.) |
| | `Padding` | Uniform or symmetric margins and insets (`EdgeInsets`) |
| | `SizedBox` / `ConstrainedBox` | Enforces explicit fixed or bounded min/max dimensions |
| | `SingleChildScrollView` | Vertically scrollable viewport with auto-calculated scrollbar |
| **Containers** | `Container` | Box decorator with borders, padding, style, and dimensions |
| **Interactive** | `Button` | Pressable button triggered via Enter/Space with focus styling |
| | `Menu<T>` | Keyboard-navigable vertical option list with arrow keys |
| | `TextField` | Single-line editable text input with cursor movement and editing |
| **Data & Feedback** | `Table` | Auto-sized multi-column grid with borders and divider lines |
| | `ProgressBar` | Graphical progress meter with customizable fill glyphs and labels |
| **Reliability** | `ErrorBoundary` | Catches subtree build errors and renders diagnostic UI |

---

## Getting Started

Add Termora to your `pubspec.yaml`:

```yaml
dependencies:
  termora: ^0.1.0
```

### 1. Minimal Application

```dart
import 'package:termora/termora.dart';

void main() async {
  final app = TermoraApp(
    child: Center(
      child: Container(
        border: const Border.rounded(Style(foregroundColor: Color.brightCyan)),
        padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
        child: const Text(
          'Hello from Termora! 🚀',
          style: Style(foregroundColor: Color.white, modifiers: {TextModifier.bold}),
        ),
      ),
    ),
  );

  await app.run();
}
```

### 2. Interactive Stateful Counter

```dart
import 'package:termora/termora.dart';

void main() async {
  final app = TermoraApp(child: const CounterApp());
  await app.run();
}

class CounterApp extends StatefulWidget {
  const CounterApp({super.key});

  @override
  State<CounterApp> createState() => _CounterAppState();
}

class _CounterAppState extends State<CounterApp> {
  int _counter = 0;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        border: const Border.heavy(Style(foregroundColor: Color.brightYellow)),
        padding: const EdgeInsets.all(2),
        child: Column(
          children: [
            Text('Count: $_counter', style: const Style(modifiers: {TextModifier.bold})),
            const SizedBox(height: 1),
            Button(
              focusNode: _focusNode,
              onPressed: () => setState(() => _counter++),
              child: const Text(' Increment (+1) '),
            ),
          ],
        ),
      ),
    );
  }
}
```

### 3. Headless Unit Testing

```dart
import 'package:termora/termora.dart';
import 'package:test/test.dart';

void main() {
  test('renders Hello Termora in virtual terminal', () {
    final backend = VirtualTerminalBackend(width: 30, height: 3);
    final app = TermoraApp(
      backend: backend,
      child: const Text('Hello Termora'),
    );

    app.renderFrame();
    expect(app.doubleBuffer.current.toAsciiString(), contains('Hello Termora'));
  });
}
```

---

## Runnable Examples

Explore complete interactive examples in the `example/` directory:

- `01_rendering_demo`: Demonstrates ANSI sequences, double buffering, and unicode glyphs.
- `02_styling_gallery`: Visual catalog of 256/TrueColor palettes and box borders.
- `03_interactive_counter`: Interactive keyboard counter with button focus navigation.
- `04_live_stopwatch`: Periodic real-time timer with start/stop/reset actions.
- `05_widget_showcase`: Multi-widget dashboard combining Table, Menu, TextField, and ProgressBar.

Run any example with:

```bash
dart run example/05_widget_showcase/main.dart
```

---

## License

Termora is released under the Apache-2.0 License. See [LICENSE](LICENSE) for details.
