import 'dart:async';

import '../input/ansi_parser.dart';
import '../input/event.dart';
import '../input/focus_manager.dart';
import '../layout/box_constraints.dart';
import '../layout/geometry.dart';
import '../rendering/backend.dart';
import '../rendering/double_buffer.dart';
import '../rendering/render_object.dart';
import '../rendering/terminal_manager.dart';
import 'element.dart';
import 'widget.dart';

/// The root element representing the application.
class RootElement extends ComponentElement {
  final Widget _rootWidget;

  RootElement(this._rootWidget) : super(_rootWidget);

  @override
  Widget build() => _rootWidget;
}

/// The main application runner for a Termora UI.
class TermoraApp {
  final Widget child;
  final TerminalBackend? backend;

  TerminalBackend? _activeBackend;
  late final TerminalManager _manager;
  final FocusManager _focusManager = FocusManager();
  final AnsiInputParser _inputParser = AnsiInputParser();

  DoubleBuffer? _doubleBuffer;
  RootElement? _rootElement;
  bool _running = false;
  Completer<void>? _exitCompleter;
  StreamSubscription<List<int>>? _inputSub;

  TermoraApp({required this.child, this.backend});

  /// The active double buffer representing the terminal screen.
  DoubleBuffer get doubleBuffer => _doubleBuffer!;

  /// The root element of this application tree once mounted.
  RootElement? get rootElement => _rootElement;

  /// The focus manager orchestrating keyboard focus.
  FocusManager get focusManager => _focusManager;

  /// Renders a single frame synchronously into the provided or virtual backend.
  ///
  /// Primarily used for headless verification and snapshot testing.
  void renderFrame({TerminalBackend? targetBackend}) {
    final effectiveBackend =
        targetBackend ?? _activeBackend ?? backend ?? VirtualTerminalBackend();
    _activeBackend = effectiveBackend;

    if (_doubleBuffer == null) {
      _doubleBuffer = DoubleBuffer(
        effectiveBackend.width,
        effectiveBackend.height,
      );
    } else if (_doubleBuffer!.width != effectiveBackend.width ||
        _doubleBuffer!.height != effectiveBackend.height) {
      _doubleBuffer!.resize(effectiveBackend.width, effectiveBackend.height);
    }

    _rootElement ??= RootElement(child)..mount(null);

    // Rebuild any dirty elements
    _rebuildTree(_rootElement!);

    // Extract root RenderObject
    final rootRenderObject = _findFirstRenderObject(_rootElement);
    if (rootRenderObject != null) {
      rootRenderObject.layout(
        BoxConstraints.tight(
          Size(effectiveBackend.width, effectiveBackend.height),
        ),
      );
      _doubleBuffer!.clear();
      final context = PaintingContext(_doubleBuffer!.current);
      context.paintChild(rootRenderObject, Offset.zero);
    }

    _doubleBuffer!.render(effectiveBackend);
  }

  /// Dispatches a key event through the application.
  void dispatchKeyEvent(KeyEvent event) {
    if (event.isCtrl && (event.character == 'c' || event.character == 'C')) {
      stop();
      return;
    }

    final handled = _focusManager.dispatchKeyEvent(event);
    if (handled) {
      renderFrame(targetBackend: _activeBackend);
    }
  }

  /// Callback triggered when the terminal window dimensions change.
  void Function(int width, int height)? onResize;

  /// Handles a terminal resize event, resizing the buffer and re-laying out the tree.
  void handleResize(int newWidth, int newHeight) {
    if (_activeBackend is VirtualTerminalBackend) {
      final vb = _activeBackend as VirtualTerminalBackend;
      vb.width = newWidth;
      vb.height = newHeight;
    }
    _doubleBuffer?.resize(newWidth, newHeight);
    final rootRenderObject = _findFirstRenderObject(_rootElement);
    rootRenderObject?.markNeedsLayout();
    onResize?.call(newWidth, newHeight);
    renderFrame(targetBackend: _activeBackend);
  }

  /// Stops the interactive application loop and cleans up terminal resources.
  void stop() {
    if (!_running) return;
    _running = false;
    _inputSub?.cancel();
    if (_exitCompleter != null && !_exitCompleter!.isCompleted) {
      _exitCompleter!.complete();
    }
  }

  /// Runs the interactive terminal application loop.
  Future<void> run() async {
    if (_running) return;
    _running = true;

    final ioBackend = backend ?? IoTerminalBackend();
    _activeBackend = ioBackend;
    _manager = TerminalManager(backend: ioBackend);
    _exitCompleter = Completer<void>();

    await _manager.runSafe(() async {
      _doubleBuffer = DoubleBuffer(ioBackend.width, ioBackend.height);
      renderFrame(targetBackend: ioBackend);

      // Listen for window resize
      _manager.onResize = (newW, newH) {
        handleResize(newW, newH);
      };

      // Listen to raw input bytes and dispatch parsed key events
      _inputSub = ioBackend.input.listen((bytes) {
        final events = _inputParser.parse(bytes);
        for (final event in events) {
          dispatchKeyEvent(event);
        }
      });

      await _exitCompleter!.future;
    });
  }

  void _rebuildTree(Element element) {
    if (element.dirty) {
      element.rebuild();
    }
    element.visitChildren(_rebuildTree);
  }

  RenderObject? _findFirstRenderObject(Element? element) {
    if (element == null) return null;
    if (element is RenderObjectElement) return element.renderObject;
    if (element is ComponentElement) {
      return _findFirstRenderObject(element.child);
    }
    return null;
  }
}
