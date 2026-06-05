import 'dart:math' as math;

import '../style/style.dart';
import 'cell.dart';
import 'unicode_width.dart';

/// Represents a 2D grid of terminal character cells.
class ScreenBuffer {
  final int width;
  final int height;
  final List<Cell> _cells;

  ScreenBuffer(this.width, this.height, {Cell initialCell = Cell.empty})
      : assert(width >= 0, 'Buffer width must be non-negative'),
        assert(height >= 0, 'Buffer height must be non-negative'),
        _cells = List<Cell>.filled(
          width * height,
          initialCell,
          growable: false,
        );

  /// Checks if the given coordinate is within buffer boundaries.
  bool inBounds(int x, int y) => x >= 0 && x < width && y >= 0 && y < height;

  /// Returns the cell at (x, y), or [Cell.empty] if out of bounds.
  Cell get(int x, int y) {
    if (!inBounds(x, y)) return Cell.empty;
    return _cells[y * width + x];
  }

  /// Sets the cell at (x, y). Out of bounds coordinates are safely ignored.
  void set(int x, int y, Cell cell) {
    if (!inBounds(x, y)) return;

    final index = y * width + x;
    _cells[index] = cell;

    // If writing a wide character and room exists, place continuation cell
    if (cell.width == 2 && x + 1 < width) {
      _cells[y * width + (x + 1)] = Cell.wideContinuation;
    }
  }

  /// Writes [text] horizontally starting at ([x], [y]) with optional [style].
  ///
  /// Automatically accounts for wide characters and avoids buffer overflows.
  int writeString(int x, int y, String text, [Style style = Style.none]) {
    if (y < 0 || y >= height || x >= width || text.isEmpty) return 0;

    var curX = x;
    for (final rune in text.runes) {
      if (curX >= width) break;

      final char = String.fromCharCode(rune);
      final charWidth = UnicodeWidth.codePointWidth(rune);

      if (charWidth == 0) {
        // Zero-width character: append to previous cell if possible
        if (curX > x && curX - 1 >= 0) {
          final prev = get(curX - 1, y);
          set(curX - 1, y, prev.copyWith(character: prev.character + char));
        }
        continue;
      }

      if (curX + charWidth > width) {
        // Wide character doesn't fit in remaining space on line: pad with space and stop
        if (charWidth == 2 && curX < width) {
          set(curX, y, Cell.char(' ', style, 1));
        }
        break;
      }

      set(curX, y, Cell(character: char, style: style, width: charWidth));
      curX += charWidth;
    }

    return curX - x;
  }

  /// Fills a rectangular region with [cell].
  void fill(int startX, int startY, int fillWidth, int fillHeight, Cell cell) {
    final xEnd = math.min(width, startX + fillWidth);
    final yEnd = math.min(height, startY + fillHeight);

    for (var y = math.max(0, startY); y < yEnd; y++) {
      for (var x = math.max(0, startX); x < xEnd; x++) {
        set(x, y, cell);
      }
    }
  }

  /// Clears the entire buffer to [fillCell].
  void clear([Cell fillCell = Cell.empty]) {
    _cells.fillRange(0, _cells.length, fillCell);
  }

  /// Clones this buffer.
  ScreenBuffer clone() {
    final copy = ScreenBuffer(width, height);
    for (var i = 0; i < _cells.length; i++) {
      copy._cells[i] = _cells[i];
    }
    return copy;
  }

  /// Resizes the buffer to ([newWidth], [newHeight]), retaining overlapping cells.
  ScreenBuffer resize(int newWidth, int newHeight) {
    final newBuffer = ScreenBuffer(newWidth, newHeight);
    final copyWidth = math.min(width, newWidth);
    final copyHeight = math.min(height, newHeight);

    for (var y = 0; y < copyHeight; y++) {
      for (var x = 0; x < copyWidth; x++) {
        newBuffer.set(x, y, get(x, y));
      }
    }
    return newBuffer;
  }

  /// Copies cells from [source] buffer into this buffer at ([destX], [destY]).
  void blit(ScreenBuffer source, {int destX = 0, int destY = 0}) {
    for (var y = 0; y < source.height; y++) {
      final targetY = destY + y;
      if (targetY < 0 || targetY >= height) continue;

      for (var x = 0; x < source.width; x++) {
        final targetX = destX + x;
        if (targetX < 0 || targetX >= width) continue;

        set(targetX, targetY, source.get(x, y));
      }
    }
  }

  /// Converts the buffer to a clean ASCII/Unicode text representation.
  ///
  /// Useful for snapshot tests and terminal debugging.
  String toAsciiString() {
    final buffer = StringBuffer();
    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        final cell = get(x, y);
        if (!cell.isWideTrailing) {
          buffer.write(cell.character);
        }
      }
      if (y < height - 1) {
        buffer.writeln();
      }
    }
    return buffer.toString();
  }
}
