# Termora

A declarative, widget-driven Terminal UI (TUI) framework for Dart, built for interactive command-line applications.

Inspired by Flutter's component architecture, Termora enables developers to build sophisticated, responsive terminal interfaces using composable widgets, flexible box layouts, reactive state management, and double-buffered rendering.

## Features

- **Declarative Widgets**: Compose UI using immutable widgets (`StatelessWidget`, `StatefulWidget`).
- **Retained Double-Buffered Renderer**: Diff-based screen updates minimize flicker and bandwidth by redrawing only changed terminal cells.
- **Box Constraints Layout**: Familiar layout system (`Row`, `Column`, `Padding`, `Center`, `Expanded`, `SizedBox`).
- **Styling & Color System**: 16 ANSI colors, 256 colors, 24-bit TrueColor, text modifiers (bold, dim, underline, etc.), and customizable borders.
- **Input & Focus Management**: Robust ANSI escape sequence parser decoding keyboard events with a multi-level focus graph.
- **Fail-Safe Lifecycle**: Automatic terminal restoration (alternate screen, raw mode, cursor visibility) upon exit or error.
- **Headless Testability**: Complete virtual backend abstraction for testing TUI components without an interactive terminal.

## Architecture

Termora separates concerns into modular layers:
- `core/`: Widget, Element, and BuildContext contracts, lifecycle management.
- `rendering/`: Double-buffered screen grid, cell definitions, ANSI escape writer, and backend abstractions.
- `layout/`: Box constraints, flex computation, alignment, and geometry.
- `style/`: Color models, text attributes, and border sets.
- `input/`: ANSI keyboard stream parser, event models, and focus nodes.
- `widgets/`: Built-in component library.

## Getting Started

Add Termora to your `pubspec.yaml`:

```yaml
dependencies:
  termora: ^0.1.0
```

### Basic Example

```dart
import 'package:termora/termora.dart';

void main() {
  runTermora(
    Center(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 2, vertical: 1),
        border: Border.rounded(),
        style: Style(foregroundColor: Color.cyan),
        child: Text('Hello, Termora!'),
      ),
    ),
  );
}
```

## License

This project is licensed under the Apache-2.0 License. See the [LICENSE](LICENSE) file for details.
