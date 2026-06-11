import 'dart:async';
import 'dart:convert' as convert;
import 'dart:io' as io;

import 'ansi.dart';

/// Abstract interface representing a terminal output and input device.
abstract interface class TerminalBackend {
  /// Width in columns.
  int get width;

  /// Height in rows.
  int get height;

  /// Stream of raw input bytes received from the terminal.
  Stream<List<int>> get input;

  /// Writes string data directly to the terminal output stream.
  void write(String data);

  /// Flushes any pending output to the terminal.
  void flush();

  /// Puts the terminal input into raw mode (disabling echo and line buffering).
  void enableRawMode();

  /// Restores normal terminal input mode.
  void disableRawMode();

  /// Enters the alternate screen buffer.
  void enterAlternateScreen();

  /// Exits the alternate screen buffer and returns to the primary screen.
  void exitAlternateScreen();

  /// Hides the terminal cursor.
  void hideCursor();

  /// Shows the terminal cursor.
  void showCursor();

  /// Disposes of any resources held by the backend.
  void dispose();
}

/// In-memory mock implementation of [TerminalBackend] for deterministic testing.
class VirtualTerminalBackend implements TerminalBackend {
  @override
  int width;

  @override
  int height;

  final StringBuffer _output = StringBuffer();
  final StreamController<List<int>> _inputController =
      StreamController<List<int>>.broadcast();

  bool isRawMode = false;
  bool isAlternateScreen = false;
  bool isCursorVisible = true;
  bool isDisposed = false;

  VirtualTerminalBackend({this.width = 80, this.height = 24});

  @override
  Stream<List<int>> get input => _inputController.stream;

  /// Simulates incoming user input bytes.
  void simulateInput(List<int> bytes) {
    if (!_inputController.isClosed) {
      _inputController.add(bytes);
    }
  }

  /// The entire output written to this virtual terminal so far.
  String get outputText => _output.toString();

  /// Clears the recorded output buffer.
  void clearOutput() => _output.clear();

  @override
  void write(String data) {
    _output.write(data);
  }

  @override
  void flush() {}

  @override
  void enableRawMode() {
    isRawMode = true;
  }

  @override
  void disableRawMode() {
    isRawMode = false;
  }

  @override
  void enterAlternateScreen() {
    isAlternateScreen = true;
    write(Ansi.enterAlternateScreen);
  }

  @override
  void exitAlternateScreen() {
    isAlternateScreen = false;
    write(Ansi.exitAlternateScreen);
  }

  @override
  void hideCursor() {
    isCursorVisible = false;
    write(Ansi.hideCursor);
  }

  @override
  void showCursor() {
    isCursorVisible = true;
    write(Ansi.showCursor);
  }

  @override
  void dispose() {
    if (!isDisposed) {
      isDisposed = true;
      _inputController.close();
    }
  }
}

/// Concrete production implementation of [TerminalBackend] using `dart:io`.
class IoTerminalBackend implements TerminalBackend {
  bool _isRawMode = false;
  bool _isDisposed = false;

  IoTerminalBackend() {
    _initEnvironment();
  }

  void _initEnvironment() {
    try {
      // Set UTF-8 encoding for unicode rendering fidelity
      io.stdout.encoding = convert.utf8;
    } catch (_) {}
  }

  /// Whether the current stdout environment supports ANSI escape sequences.
  bool get supportsAnsiEscapes {
    try {
      return io.stdout.supportsAnsiEscapes;
    } catch (_) {
      return true;
    }
  }

  @override
  int get width {
    try {
      if (io.stdout.hasTerminal) {
        return io.stdout.terminalColumns;
      }
    } catch (_) {}
    return 80;
  }

  @override
  int get height {
    try {
      if (io.stdout.hasTerminal) {
        return io.stdout.terminalLines;
      }
    } catch (_) {}
    return 24;
  }

  @override
  Stream<List<int>> get input => io.stdin;

  @override
  void write(String data) {
    io.stdout.write(data);
  }

  @override
  void flush() {
    try {
      // Best-effort flush without blocking
      io.stdout.flush();
    } catch (_) {}
  }

  @override
  void enableRawMode() {
    if (_isRawMode) return;
    try {
      if (io.stdin.hasTerminal) {
        io.stdin.echoMode = false;
        io.stdin.lineMode = false;
      }
      _isRawMode = true;
    } catch (_) {}
  }

  @override
  void disableRawMode() {
    if (!_isRawMode) return;
    try {
      if (io.stdin.hasTerminal) {
        io.stdin.echoMode = true;
        io.stdin.lineMode = true;
      }
      _isRawMode = false;
    } catch (_) {}
  }

  @override
  void enterAlternateScreen() {
    write(Ansi.enterAlternateScreen);
  }

  @override
  void exitAlternateScreen() {
    write(Ansi.exitAlternateScreen);
  }

  @override
  void hideCursor() {
    write(Ansi.hideCursor);
  }

  @override
  void showCursor() {
    write(Ansi.showCursor);
  }

  @override
  void dispose() {
    if (!_isDisposed) {
      _isDisposed = true;
      disableRawMode();
      showCursor();
      exitAlternateScreen();
    }
  }
}
