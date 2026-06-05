import 'dart:async';
import 'package:termora/termora.dart';

void main() async {
  final manager = TerminalManager();

  await manager.runSafe(() async {
    final width = manager.backend.width;
    final height = manager.backend.height;
    final doubleBuffer = DoubleBuffer(width, height);

    // Render a decorative frame
    final buffer = doubleBuffer.current;
    buffer.clear();

    const titleStyle = Style(
      foregroundColor: Color.cyan,
      modifiers: {TextModifier.bold},
    );
    const subStyle = Style(
      foregroundColor: Color.brightYellow,
    );
    const infoStyle = Style(
      foregroundColor: Color.brightGreen,
      modifiers: {TextModifier.dim},
    );

    // Draw box
    buffer.writeString(
        2, 2, '┌────────────────────────────────────────────────┐', titleStyle);
    buffer.writeString(
        2, 3, '│         Termora Rendering Foundation Demo      │', titleStyle);
    buffer.writeString(
        2, 4, '├────────────────────────────────────────────────┤', titleStyle);
    buffer.writeString(
        2, 5, '│ Double-buffered rendering with ANSI diffing    │', subStyle);
    buffer.writeString(2, 6,
        '│ Screen dimensions: ${width}x$height columns/rows       │', subStyle);
    buffer.writeString(
        2, 7, '│ Press Ctrl+C or wait 2 seconds to exit...      │', infoStyle);
    buffer.writeString(
        2, 8, '└────────────────────────────────────────────────┘', titleStyle);

    doubleBuffer.render(manager.backend);

    // Keep on screen for 2 seconds
    await Future<void>.delayed(const Duration(seconds: 2));
  });
}
