import 'dart:async';
import 'dart:io' as io;

import 'backend.dart';

/// Manages terminal lifecycle, alternate screen buffer, raw mode, and safe teardown.
class TerminalManager {
  final TerminalBackend backend;
  bool _initialized = false;
  StreamSubscription<io.ProcessSignal>? _sigintSub;
  StreamSubscription<io.ProcessSignal>? _sigwinchSub;
  void Function(int width, int height)? onResize;

  TerminalManager({TerminalBackend? backend})
      : backend = backend ?? IoTerminalBackend();

  /// Whether the terminal is currently initialized in alternate screen raw mode.
  bool get isInitialized => _initialized;

  /// Initializes the terminal: enters alternate screen, hides cursor, and enters raw mode.
  void initialize() {
    if (_initialized) return;

    backend.enterAlternateScreen();
    backend.hideCursor();
    backend.enableRawMode();
    _initialized = true;

    // Attach signal listeners if on supported platforms
    try {
      if (!io.Platform.isWindows) {
        _sigwinchSub = io.ProcessSignal.sigwinch.watch().listen((_) {
          onResize?.call(backend.width, backend.height);
        });
      }
    } catch (_) {}

    try {
      _sigintSub = io.ProcessSignal.sigint.watch().listen((_) {
        restore();
        io.exit(0);
      });
    } catch (_) {}
  }

  /// Restores standard terminal settings (cursor, normal buffer, echo mode).
  void restore() {
    if (!_initialized) return;

    try {
      _sigintSub?.cancel();
      _sigwinchSub?.cancel();
    } catch (_) {}

    backend.showCursor();
    backend.exitAlternateScreen();
    backend.disableRawMode();
    backend.flush();
    backend.dispose();
    _initialized = false;
  }

  /// Executes [body] safely, guaranteeing [restore] is executed even if exceptions occur.
  Future<T> runSafe<T>(FutureOr<T> Function() body) async {
    initialize();
    try {
      return await body();
    } finally {
      restore();
    }
  }
}
