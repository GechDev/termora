# Changelog

All notable changes to the `termora` package will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2026-06-12

### Added
- **Declarative Component Model**:
  - Flutter-inspired `Widget`, `StatelessWidget`, `StatefulWidget`, and `InheritedWidget` hierarchy.
  - Retained `Element` tree with lifecycle management (`initState`, `didUpdateWidget`, `dispose`, `setState`).
  - Object identity support via `Key` and `ValueKey<T>`.

- **Double-Buffered Rendering Engine**:
  - Retained 2D `ScreenBuffer` with monospaced column tracking for standard and wide characters.
  - Differential `DoubleBuffer` calculating minimal ANSI jump sequences to eliminate screen flickering.
  - `Cell` grid abstraction with 16 ANSI colors, 256 indexed colors, and 24-bit TrueColor (RGB).
  - Composable `Style` system with text modifiers (bold, dim, italic, underline, reverse, strikethrough).
  - Composable `Border` sets including single, double, heavy, rounded, ascii, dotted, and dashed glyphs.

- **Layout Engine**:
  - Discrete integer `BoxConstraints` system (tight, loose, min/max dimensions).
  - Flex layout primitives (`Row`, `Column`, `Flex`, `Expanded`, `Flexible`, `Spacer`).
  - Fractional alignment and centering (`Align`, `Center`, `Alignment`).
  - Spacing and dimension wrappers (`Padding`, `EdgeInsets`, `SizedBox`, `ConstrainedBox`).
  - Viewport scroll clipping (`SingleChildScrollView`, `ScrollController`).

- **Input & Focus Graph**:
  - Low-level ANSI stream parser decoding UTF-8 keystrokes, arrow keys, function keys, and modifier keys (`Ctrl`, `Shift`).
  - Multi-node `FocusManager` and `FocusNode` hierarchy enabling cyclic tab traversal.

- **Built-in Widget Library**:
  - `Text` and `RichText` with multi-styled inline `TextSpan` support.
  - `Container` with composable borders, padding, and explicit dimensions.
  - `Button` with focus highlights and `onPressed` callbacks.
  - `Menu<T>` with arrow-key option navigation.
  - `TextField` and `TextEditingController` for single-line editable input.
  - `Table` with auto-sized column widths, headers, and borders.
  - `ProgressBar` with percentage readout and customizable fill glyphs.
  - `ErrorBoundary` and `ErrorWidget` for resilient runtime failure isolation.

- **Lifecycle & Compatibility**:
  - `TerminalManager` guaranteeing safe restoration of raw mode, alternate screen, and cursor visibility.
  - `IoTerminalBackend` supporting Windows Console Virtual Terminal processing and UTF-8 encoding.
  - `VirtualTerminalBackend` enabling deterministic headless snapshot testing.

- **Examples & Test Suite**:
  - 5 interactive examples (`01_rendering_demo`, `02_styling_gallery`, `03_interactive_counter`, `04_live_stopwatch`, `05_widget_showcase`).
  - Comprehensive unit test suite covering 100% of core architectures.
