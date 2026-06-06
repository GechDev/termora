import 'dart:async';

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

  late final TerminalBackend _backend;
  late final TerminalManager _manager;
  DoubleBuffer? _doubleBuffer;
  RootElement? _rootElement;
  bool _running = false;

  TermoraApp({required this.child, this.backend});

  /// The active double buffer representing the terminal screen.
  DoubleBuffer get doubleBuffer => _doubleBuffer!;

  /// The root element of this application tree once mounted.
  RootElement? get rootElement => _rootElement;

  /// Renders a single frame synchronously into the provided or virtual backend.
  ///
  /// Primarily used for headless verification and snapshot testing.
  void renderFrame({TerminalBackend? targetBackend}) {
    final effectiveBackend =
        targetBackend ?? backend ?? VirtualTerminalBackend();

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

  /// Runs the interactive terminal application loop.
  Future<void> run() async {
    if (_running) return;
    _running = true;

    _backend = backend ?? IoTerminalBackend();
    _manager = TerminalManager(backend: _backend);

    await _manager.runSafe(() async {
      _doubleBuffer = DoubleBuffer(_backend.width, _backend.height);
      renderFrame(targetBackend: _backend);

      // Listen for window resize
      _manager.onResize = (newW, newH) {
        _doubleBuffer?.resize(newW, newH);
        renderFrame(targetBackend: _backend);
      };

      // Keep running until stream closes or cancelled
      final completer = Completer<void>();
      await completer.future;
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
