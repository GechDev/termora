import '../style/style.dart';
import 'ansi.dart';
import 'backend.dart';
import 'screen_buffer.dart';

/// Double-buffered screen rendering manager with cell diffing.
class DoubleBuffer {
  int _width;
  int _height;

  ScreenBuffer _frontBuffer;
  ScreenBuffer _backBuffer;
  bool _needsFullRedraw = true;

  DoubleBuffer(int width, int height)
      : _width = width,
        _height = height,
        _frontBuffer = ScreenBuffer(width, height),
        _backBuffer = ScreenBuffer(width, height);

  /// Width in columns.
  int get width => _width;

  /// Height in rows.
  int get height => _height;

  /// The active back buffer where rendering occurs before frame commit.
  ScreenBuffer get current => _backBuffer;

  /// Resizes the double buffer to ([newWidth], [newHeight]).
  void resize(int newWidth, int newHeight) {
    if (newWidth == _width && newHeight == _height) return;

    _width = newWidth;
    _height = newHeight;
    _frontBuffer = ScreenBuffer(newWidth, newHeight);
    _backBuffer = _backBuffer.resize(newWidth, newHeight);
    _needsFullRedraw = true;
  }

  /// Clears the back buffer in preparation for the next frame.
  void clear() {
    _backBuffer.clear();
  }

  /// Renders delta updates between [_backBuffer] and [_frontBuffer] to [backend].
  void render(TerminalBackend backend, {bool forceFullRedraw = false}) {
    final fullRedraw = forceFullRedraw || _needsFullRedraw;

    final output = StringBuffer();
    var curCursorX = -1;
    var curCursorY = -1;
    var curStyle = Style.none;

    for (var y = 0; y < _height; y++) {
      for (var x = 0; x < _width; x++) {
        final backCell = _backBuffer.get(x, y);
        final frontCell = _frontBuffer.get(x, y);

        // Skip continuation trailing cells (they are written as part of wide characters)
        if (backCell.isWideTrailing) continue;

        if (fullRedraw || backCell != frontCell) {
          // If cursor is not at current cell, position it
          if (curCursorX != x || curCursorY != y) {
            output.write(Ansi.moveTo(x, y));
            curCursorX = x;
            curCursorY = y;
          }

          // Apply styling difference
          if (backCell.style != curStyle) {
            output.write(backCell.style.diffAnsi(curStyle));
            curStyle = backCell.style;
          }

          output.write(backCell.character);
          curCursorX += backCell.width;
        }
      }
    }

    // Reset style back to default at end of render frame
    if (curStyle != Style.none) {
      output.write(Ansi.reset);
    }

    if (output.isNotEmpty) {
      backend.write(output.toString());
      backend.flush();
    }

    // Sync front buffer with back buffer
    _frontBuffer = _backBuffer.clone();
    _needsFullRedraw = false;
  }
}
