import 'dart:math' as math;

import '../core/build_context.dart';
import '../core/element.dart';
import '../core/widget.dart';
import '../layout/box_constraints.dart';
import '../layout/geometry.dart';
import '../rendering/cell.dart';
import '../rendering/render_object.dart';
import '../style/color.dart';
import '../style/style.dart';

/// Controls scroll position and viewport bounds.
class ScrollController {
  int _offset;
  int _maxScrollExtent = 0;
  int _viewportDimension = 0;
  final List<void Function()> _listeners = [];

  ScrollController({int initialOffset = 0}) : _offset = initialOffset;

  /// Current scroll offset in rows.
  int get offset => _offset;
  set offset(int value) {
    final clamped = value.clamp(0, _maxScrollExtent);
    if (_offset != clamped) {
      _offset = clamped;
      _notifyListeners();
    }
  }

  /// Maximum scrollable extent based on child height minus viewport.
  int get maxScrollExtent => _maxScrollExtent;

  /// Height of the visible scroll viewport.
  int get viewportDimension => _viewportDimension;

  /// Scrolls down by [delta] rows.
  void scrollDown([int delta = 1]) => offset += delta;

  /// Scrolls up by [delta] rows.
  void scrollUp([int delta = 1]) => offset -= delta;

  /// Jumps directly to an offset.
  void jumpTo(int value) => offset = value;

  void addListener(void Function() listener) => _listeners.add(listener);
  void removeListener(void Function() listener) => _listeners.remove(listener);

  void _notifyListeners() {
    for (final listener in List.of(_listeners)) {
      listener();
    }
  }

  void dispose() => _listeners.clear();
}

/// A box in which a single child widget can be scrolled vertically.
class SingleChildScrollView extends RenderObjectWidget {
  final Widget child;
  final ScrollController? controller;
  final bool showScrollBar;

  const SingleChildScrollView({
    super.key,
    required this.child,
    this.controller,
    this.showScrollBar = true,
  });

  @override
  RenderObjectElement createElement() => SingleChildScrollViewElement(this);

  @override
  RenderSingleChildScrollView createRenderObject(BuildContext context) {
    return RenderSingleChildScrollView(
      controller: controller,
      showScrollBar: showScrollBar,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, RenderSingleChildScrollView renderObject) {
    renderObject
      ..controller = controller
      ..showScrollBar = showScrollBar;
  }
}

/// Element for [SingleChildScrollView].
class SingleChildScrollViewElement extends RenderObjectElement {
  SingleChildScrollViewElement(SingleChildScrollView super.widget);

  @override
  SingleChildScrollView get widget => super.widget as SingleChildScrollView;

  @override
  RenderSingleChildScrollView get renderObject =>
      super.renderObject as RenderSingleChildScrollView;

  Element? _childElement;

  @override
  void mount(Element? parent) {
    super.mount(parent);
    _childElement = updateChild(null, widget.child);
    renderObject.child = _findChildRenderObject(_childElement);
  }

  @override
  void update(Widget newWidget) {
    super.update(newWidget);
    final scrollView = newWidget as SingleChildScrollView;
    _childElement = updateChild(_childElement, scrollView.child);
    renderObject.child = _findChildRenderObject(_childElement);
  }

  RenderObject? _findChildRenderObject(Element? element) {
    if (element == null) return null;
    if (element is RenderObjectElement) return element.renderObject;
    if (element is ComponentElement) {
      return _findChildRenderObject(element.child);
    }
    return null;
  }

  @override
  void unmount() {
    _childElement?.unmount();
    _childElement = null;
    super.unmount();
  }

  @override
  void visitChildren(void Function(Element element) visitor) {
    if (_childElement != null) visitor(_childElement!);
  }
}

/// RenderObject that clips and scrolls its single child vertically.
class RenderSingleChildScrollView extends RenderObject {
  RenderObject? _child;
  ScrollController? _controller;
  ScrollController? _internalController;
  bool _showScrollBar;

  RenderSingleChildScrollView({
    ScrollController? controller,
    bool showScrollBar = true,
  })  : _controller = controller,
        _showScrollBar = showScrollBar {
    _initController();
  }

  void _initController() {
    if (_controller == null) {
      _internalController = ScrollController();
    }
    effectiveController.addListener(_onScrollChanged);
  }

  ScrollController get effectiveController =>
      _controller ?? _internalController!;

  set controller(ScrollController? value) {
    if (_controller != value) {
      effectiveController.removeListener(_onScrollChanged);
      _controller = value;
      effectiveController.addListener(_onScrollChanged);
      markNeedsPaint();
    }
  }

  set showScrollBar(bool value) {
    if (_showScrollBar != value) {
      _showScrollBar = value;
      markNeedsPaint();
    }
  }

  RenderObject? get child => _child;
  set child(RenderObject? value) {
    if (_child == value) return;
    _child?.parent = null;
    _child = value;
    _child?.parent = this;
    markNeedsLayout();
  }

  void _onScrollChanged() {
    markNeedsPaint();
  }

  @override
  void performLayout() {
    final viewportWidth = constraints.maxWidth;
    final viewportHeight = constraints.maxHeight;

    if (_child != null) {
      // Child is allowed unconstrained vertical height
      final childWidth =
          _showScrollBar ? math.max(0, viewportWidth - 1) : viewportWidth;
      _child!.layout(BoxConstraints(
        minWidth: 0,
        maxWidth: childWidth,
        minHeight: 0,
        maxHeight: 99999,
      ));

      final childHeight = _child!.size.height;
      effectiveController._viewportDimension = viewportHeight;
      effectiveController._maxScrollExtent =
          math.max(0, childHeight - viewportHeight);
      effectiveController.offset = effectiveController.offset
          .clamp(0, effectiveController._maxScrollExtent);

      size = Size(viewportWidth, viewportHeight);
    } else {
      size = Size(viewportWidth, viewportHeight);
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (_child == null) return;

    final scrollOffset = effectiveController.offset;
    final viewportHeight = size.height;
    final viewportWidth = size.width;

    // Paint child into an offscreen/nested context clipped to viewport
    final childContext = PaintingContext(context.buffer);
    _child!.paint(childContext, Offset(offset.x, offset.y - scrollOffset));

    // Render scrollbar on the rightmost column if enabled and content exceeds viewport
    if (_showScrollBar && effectiveController.maxScrollExtent > 0) {
      final scrollBarX = offset.x + viewportWidth - 1;
      final childHeight = _child!.size.height;

      final thumbHeight =
          math.max(1, (viewportHeight * viewportHeight / childHeight).round());
      final maxThumbY = viewportHeight - thumbHeight;
      final thumbY = effectiveController.maxScrollExtent == 0
          ? 0
          : (maxThumbY * (scrollOffset / effectiveController.maxScrollExtent))
              .round();

      for (var y = 0; y < viewportHeight; y++) {
        final isThumb = y >= thumbY && y < thumbY + thumbHeight;
        final glyph = isThumb ? '█' : '│';
        final style = isThumb
            ? const Style(foregroundColor: Color.brightCyan)
            : const Style(foregroundColor: Color.brightBlack);

        context.buffer.set(
          scrollBarX,
          offset.y + y,
          Cell(character: glyph, style: style),
        );
      }
    }
  }

  @override
  void visitChildren(void Function(RenderObject child) visitor) {
    if (_child != null) visitor(_child!);
  }
}
